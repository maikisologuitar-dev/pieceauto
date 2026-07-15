/**
 * admin.js — Routes back-office (montées sous /api/admin dans server.js)
 */

const crypto = require("crypto");
const { PDFDocument, StandardFonts, rgb, PDFName, PDFString } = require("pdf-lib");

// ---------- Annotation de lien cliquable ----------
function addLinkAnnotation(pdfDoc, page, rect, url) {
  const linkAnnot = pdfDoc.context.obj({
    Type: "Annot",
    Subtype: "Link",
    Rect: rect,
    Border: [0, 0, 0],
    A: {
      Type: "Action",
      S: "URI",
      URI: PDFString.of(url),
    },
  });
  const linkRef = pdfDoc.context.register(linkAnnot);
  const existing = page.node.lookup(PDFName.of("Annots"));
  if (existing) {
    existing.push(linkRef);
  } else {
    page.node.set(PDFName.of("Annots"), pdfDoc.context.obj([linkRef]));
  }
}

const JWT_SECRET = process.env.JWT_SECRET || "change-me-en-production-piecesauto";
const TOKEN_TTL_SECONDS = 60 * 60 * 8; // 8 heures

// ---------- JWT maison (HMAC-SHA256) ----------
function b64url(input) {
  return Buffer.from(input).toString("base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}
function b64urlJson(obj) { return b64url(JSON.stringify(obj)); }

function signToken(payload) {
  const header = { alg: "HS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const body = { ...payload, iat: now, exp: now + TOKEN_TTL_SECONDS };
  const head = b64urlJson(header);
  const data = b64urlJson(body);
  const sig = crypto.createHmac("sha256", JWT_SECRET).update(`${head}.${data}`).digest("base64")
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  return `${head}.${data}.${sig}`;
}

function verifyToken(token) {
  try {
    const [head, data, sig] = token.split(".");
    if (!head || !data || !sig) return null;
    const expected = crypto.createHmac("sha256", JWT_SECRET).update(`${head}.${data}`).digest("base64")
      .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
    if (sig !== expected) return null;
    const payload = JSON.parse(Buffer.from(data, "base64").toString("utf-8"));
    if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

function hashPassword(password, salt) {
  return crypto.pbkdf2Sync(password, salt, 120000, 64, "sha512").toString("hex");
}

// ---------- Statuts de commande ----------
const ORDER_STATUSES = ["en_attente", "facturee", "payee", "expediee", "annulee"];
const PAYMENT_LABELS = {
  virement: "Virement bancaire",
  cheque: "Chèque",
  livraison: "Règlement à la livraison",
  especes: "Espèces au retrait",
};

function euro(cents) {
  return (cents / 100).toFixed(2).replace(".", ",") + " €";
}

// ---------- Coordonnées bancaires (RIB) — une seule ligne, id fixe = 1 ----------
async function getPaymentSettings(pool) {
  const r = await pool.query("SELECT * FROM payment_settings WHERE id = 1");
  return r.rows[0] || null;
}

// ═══════════════════════════════════════════════════════════════════════════
//  INFORMATIONS LÉGALES DE L'ENTREPRISE (affichées sur chaque facture)
//  >>> À COMPLÉTER avec les vraies valeurs <<<
//  Le SIRET doit être le numéro d'immatriculation RÉEL et vérifiable.
// ═══════════════════════════════════════════════════════════════════════════
const COMPANY = {
  name: "PiècesAuto",
  tagline: "Pièces et équipement automobile",
  address: "Avenue Émile Sari, 20200 Bastia, France",
  phone: "",   // ex. "+33 4 95 00 00 00"
  email: "",   // ex. "contact@pieceautocorse.com"
  siret: "",   // ← SIRET RÉEL (14 chiffres)
  tva: "",     // ex. "FR00 000000000"
  rcs: "",     // ex. "RCS Bastia 000 000 000"
};

// ---------- Génération facture PDF (mise en page professionnelle) ----------
async function buildInvoicePdf(order, items, bank = null) {
  const pdf = await PDFDocument.create();
  const page = pdf.addPage([595, 842]); // A4
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const { width, height } = page.getSize();

  // Palette
  const green = rgb(0.06, 0.32, 0.20);
  const dark = rgb(0.12, 0.16, 0.21);
  const gray = rgb(0.42, 0.45, 0.50);
  const lightBg = rgb(0.96, 0.97, 0.96);
  const white = rgb(1, 1, 1);

  const M = 45;
  const RIGHT = width - M;
  let y = height - 50;

  const text = (s, x, yy, size, f = font, color = dark) =>
    page.drawText(String(s ?? ""), { x, y: yy, size, font: f, color });
  const textRight = (s, xRight, yy, size, f = font, color = dark) => {
    const w = f.widthOfTextAtSize(String(s ?? ""), size);
    page.drawText(String(s ?? ""), { x: xRight - w, y: yy, size, font: f, color });
  };

  // En-tête
  text(COMPANY.name, M, y, 22, bold, green);
  textRight("FACTURE", RIGHT, y, 20, bold, dark);
  y -= 16;
  text(COMPANY.tagline, M, y, 9, font, gray);
  textRight(order.order_number, RIGHT, y, 11, bold, green);
  y -= 14;
  const dateStr = new Date(order.created_at).toLocaleDateString("fr-FR");
  textRight(`Date : ${dateStr}`, RIGHT, y, 9, font, gray);

  // Trait de séparation
  y -= 10;
  page.drawRectangle({ x: M, y, width: width - 2 * M, height: 2, color: green });
  y -= 22;

  // Mentions légales entreprise
  const legal = [
    COMPANY.address,
    [COMPANY.phone && `Tél : ${COMPANY.phone}`, COMPANY.email && `Email : ${COMPANY.email}`].filter(Boolean).join("   "),
    [
      COMPANY.siret ? `SIRET : ${COMPANY.siret}` : "SIRET : — à compléter —",
      COMPANY.tva ? `TVA : ${COMPANY.tva}` : "",
      COMPANY.rcs || "",
    ].filter(Boolean).join("   |   "),
  ].filter(Boolean);
  for (const l of legal) { text(l, M, y, 8.5, font, gray); y -= 12; }
  y -= 12;

  // Bloc Client (encadré)
  const boxTop = y;
  const boxH = 74;
  page.drawRectangle({
    x: M, y: boxTop - boxH, width: width - 2 * M, height: boxH,
    color: lightBg, borderColor: rgb(0.88, 0.90, 0.89), borderWidth: 1,
  });
  let cy = boxTop - 16;
  text("FACTURÉ À", M + 12, cy, 8, bold, gray); cy -= 14;
  text(order.customer_name, M + 12, cy, 11, bold, dark); cy -= 13;
  const clientLines = [
    order.address_line,
    `${order.postal_code} ${order.city}`,
    order.country,
    [order.customer_email, order.customer_phone].filter(Boolean).join("  ·  "),
  ].filter(Boolean);
  for (const l of clientLines) { text(l, M + 12, cy, 9, font, dark); cy -= 12; }
  y = boxTop - boxH - 24;

  // Tableau : en-tête
  const colX = { desig: M + 8, ref: 305, qty: 385, pu: 430, total: RIGHT };
  page.drawRectangle({ x: M, y: y - 6, width: width - 2 * M, height: 24, color: green });
  const headY = y + 2;
  text("DÉSIGNATION", colX.desig, headY, 9, bold, white);
  text("RÉF.", colX.ref, headY, 9, bold, white);
  text("QTÉ", colX.qty, headY, 9, bold, white);
  text("P.U.", colX.pu, headY, 9, bold, white);
  textRight("MONTANT", colX.total, headY, 9, bold, white);
  y -= 24;

  // Lignes articles
  let totalHT = 0;
  let rowIndex = 0;
  const drawRow = (desig, ref, qty, pu, montant) => {
    if (rowIndex % 2 === 1) {
      page.drawRectangle({ x: M, y: y - 5, width: width - 2 * M, height: 18, color: lightBg });
    }
    const d = desig.length > 46 ? desig.slice(0, 44) + "…" : desig;
    text(d, colX.desig, y, 9, font, dark);
    text(ref || "-", colX.ref, y, 9, font, gray);
    text(String(qty), colX.qty, y, 9, font, dark);
    text(pu, colX.pu, y, 9, font, dark);
    textRight(montant, colX.total, y, 9, font, dark);
    y -= 18;
    rowIndex++;
    if (y < 140) { y = height - 60; pdf.addPage([595, 842]); }
  };

  for (const it of items) {
    const lineTotal = it.unit_cents * it.quantity;
    totalHT += lineTotal;
    drawRow(it.title, it.reference, it.quantity, euro(it.unit_cents), euro(lineTotal));
  }

  // Ligne livraison
  const deliveryFee = Number(order.delivery_fee_cents) || 0;
  if (deliveryFee > 0) {
    const km = Number(order.delivery_km) || 0;
    const label = km > 0 ? `Frais de livraison (${km.toFixed(1)} km)` : "Frais de livraison";
    totalHT += deliveryFee;
    drawRow(label, "-", 1, euro(deliveryFee), euro(deliveryFee));
  }

  // Encadré totaux
  y -= 8;
  const totalsX = 360;
  page.drawLine({ start: { x: totalsX, y: y + 6 }, end: { x: RIGHT, y: y + 6 }, thickness: 1, color: rgb(0.85, 0.87, 0.86) });
  y -= 6;
  const totalTTC = totalHT;
  const ht = Math.round(totalTTC / 1.2);
  const tva = totalTTC - ht;
  text("Total HT", totalsX, y, 10, font, gray);
  textRight(euro(ht), RIGHT, y, 10, font, dark);
  y -= 16;
  text("TVA 20 %", totalsX, y, 10, font, gray);
  textRight(euro(tva), RIGHT, y, 10, font, dark);
  y -= 8;
  page.drawRectangle({ x: totalsX - 8, y: y - 20, width: RIGHT - totalsX + 8, height: 26, color: green });
  y -= 14;
  text("TOTAL TTC", totalsX, y, 12, bold, white);
  textRight(euro(totalTTC), RIGHT, y, 12, bold, white);
  y -= 34;

  // Conditions de règlement
  text("Mode de règlement : " + (PAYMENT_LABELS[order.payment_method] || order.payment_method),
    M, y, 10, bold, dark);
  y -= 22;

  const mode = bank && bank.payment_mode === "lien" ? "lien" : "rib";
  if (mode === "lien" && bank && bank.payment_link_url) {
    page.drawLine({ start: { x: M, y: y + 10 }, end: { x: RIGHT, y: y + 10 }, thickness: 1, color: rgb(0.85, 0.87, 0.86) });
    text("Règlement en ligne", M, y, 10, bold, dark); y -= 16;
    const label = bank.payment_link_label || "Payer";
    text(label, M, y, 10, bold, rgb(0.06, 0.35, 0.75));
    const tw = bold.widthOfTextAtSize(label, 10);
    addLinkAnnotation(pdf, page, [M, y - 3, M + tw, y + 11], bank.payment_link_url);
    y -= 14;
    text(bank.payment_link_url, M, y, 8, font, gray); y -= 13;
    text("Une fois le paiement effectué, téléversez votre preuve de paiement sur la plateforme.", M, y, 8, font, gray);
  } else if (bank && (bank.agency_name || bank.iban || bank.bank_name)) {
    const bankLines = [
      bank.bank_name ? `Banque : ${bank.bank_name}` : null,
      bank.agency_name ? `Agence : ${bank.agency_name}` : null,
      bank.account_holder ? `Titulaire : ${bank.account_holder}` : null,
      bank.iban ? `IBAN : ${bank.iban}` : null,
      bank.bic ? `BIC : ${bank.bic}` : null,
    ].filter(Boolean);
    const bh = 20 + bankLines.length * 13;
    page.drawRectangle({
      x: M, y: y - bh + 8, width: width - 2 * M, height: bh,
      color: lightBg, borderColor: rgb(0.88, 0.90, 0.89), borderWidth: 1,
    });
    text("COORDONNÉES BANCAIRES (VIREMENT)", M + 12, y, 9, bold, green); y -= 16;
    for (const l of bankLines) { text(l, M + 12, y, 9, font, dark); y -= 13; }
    y -= 6;
  }

  // Pied de page
  const footY = 54;
  page.drawLine({ start: { x: M, y: footY + 18 }, end: { x: RIGHT, y: footY + 18 }, thickness: 1, color: rgb(0.85, 0.87, 0.86) });
  const thanks = "Merci pour votre confiance !";
  const tw2 = bold.widthOfTextAtSize(thanks, 10);
  text(thanks, (width - tw2) / 2, footY, 10, bold, green);
  const sub = "Nous restons à votre disposition pour toute information complémentaire.";
  const sw = font.widthOfTextAtSize(sub, 8);
  text(sub, (width - sw) / 2, footY - 13, 8, font, gray);

  return pdf.save();
}

// ---------- Montage des routes ----------
module.exports = function registerAdminRoutes(app, pool) {
  function requireAuth(req, res, next) {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;
    const payload = token && verifyToken(token);
    if (!payload) return res.status(401).json({ error: "Non authentifié" });
    req.admin = payload;
    next();
  }

  // --- Login ---
  app.post("/api/admin/login", async (req, res) => {
    const { email, password } = req.body || {};
    if (!email || !password) return res.status(400).json({ error: "Email et mot de passe requis" });
    try {
      const r = await pool.query("SELECT * FROM admin_users WHERE email = $1", [email.toLowerCase()]);
      if (!r.rows.length) return res.status(401).json({ error: "Identifiants invalides" });
      const u = r.rows[0];
      const hash = hashPassword(password, u.password_salt);
      if (hash !== u.password_hash) return res.status(401).json({ error: "Identifiants invalides" });
      const token = signToken({ sub: u.id, email: u.email, name: u.name });
      res.json({ token, name: u.name, email: u.email });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Dashboard stats ---
  app.get("/api/admin/stats", requireAuth, async (_req, res) => {
    try {
      const [orders, revenue, products, pending] = await Promise.all([
        pool.query("SELECT count(*)::int AS n FROM orders"),
        pool.query("SELECT COALESCE(sum(total_cents),0)::int AS n FROM orders WHERE status IN ('payee','expediee')"),
        pool.query("SELECT count(*)::int AS n FROM products"),
        pool.query("SELECT count(*)::int AS n FROM orders WHERE status = 'en_attente'"),
      ]);
      res.json({
        orders: orders.rows[0].n,
        revenue_cents: revenue.rows[0].n,
        products: products.rows[0].n,
        pending: pending.rows[0].n,
      });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Liste commandes ---
  app.get("/api/admin/orders", requireAuth, async (req, res) => {
    const status = (req.query.status || "").trim();
    const params = [];
    let where = "";
    if (status && ORDER_STATUSES.includes(status)) {
      params.push(status);
      where = "WHERE status = $1";
    }
    try {
      const r = await pool.query(
        `SELECT id, order_number, customer_name, customer_email, payment_method,
                status, total_cents, created_at,
                (proof_url IS NOT NULL) AS has_proof, proof_uploaded_at
         FROM orders ${where} ORDER BY id DESC LIMIT 200`, params
      );
      res.json(r.rows);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Détail commande ---
  app.get("/api/admin/orders/:id", requireAuth, async (req, res) => {
    try {
      const o = await pool.query("SELECT * FROM orders WHERE id = $1", [req.params.id]);
      if (!o.rows.length) return res.status(404).json({ error: "Commande introuvable" });
      const items = await pool.query(
        "SELECT * FROM order_items WHERE order_id = $1 ORDER BY id", [req.params.id]
      );
      res.json({ ...o.rows[0], items: items.rows, statuses: ORDER_STATUSES });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Changer statut ---
  app.patch("/api/admin/orders/:id", requireAuth, async (req, res) => {
    const { status } = req.body || {};
    if (!ORDER_STATUSES.includes(status)) {
      return res.status(400).json({ error: "Statut invalide" });
    }
    try {
      const invoicedClause = status === "facturee" ? ", invoiced_at = COALESCE(invoiced_at, now())" : "";
      const r = await pool.query(
        `UPDATE orders SET status = $1 ${invoicedClause} WHERE id = $2 RETURNING id, status`,
        [status, req.params.id]
      );
      if (!r.rows.length) return res.status(404).json({ error: "Commande introuvable" });
      res.json(r.rows[0]);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Facture PDF ---
  app.get("/api/admin/orders/:id/invoice", requireAuth, async (req, res) => {
    try {
      const o = await pool.query("SELECT * FROM orders WHERE id = $1", [req.params.id]);
      if (!o.rows.length) return res.status(404).json({ error: "Commande introuvable" });
      const items = await pool.query(
        "SELECT * FROM order_items WHERE order_id = $1 ORDER BY id", [req.params.id]
      );
      const bank = await getPaymentSettings(pool);
      const pdfBytes = await buildInvoicePdf(o.rows[0], items.rows, bank);
      res.setHeader("Content-Type", "application/pdf");
      res.setHeader("Content-Disposition", `inline; filename="facture-${o.rows[0].order_number}.pdf"`);
      res.send(Buffer.from(pdfBytes));
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Liste produits (admin) ---
  app.get("/api/admin/products", requireAuth, async (req, res) => {
    const q = (req.query.q || "").trim();
    const params = [];
    let where = "";
    if (q) {
      params.push(`%${q}%`);
      where = "WHERE title ILIKE $1 OR reference ILIKE $1";
    }
    try {
      const r = await pool.query(
        `SELECT id, slug, title, reference, brand, price_cents, stock_status
         FROM products ${where} ORDER BY title ASC LIMIT 500`, params
      );
      res.json(r.rows);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // --- Modifier un produit (prix / stock / textes) ---
  app.patch("/api/admin/products/:id", requireAuth, async (req, res) => {
    const { price_eur, stock_status, title, short_desc, long_desc, brand } = req.body || {};
    const sets = [];
    const params = [];
    let i = 1;

    if (price_eur !== undefined && price_eur !== null && price_eur !== "") {
      const cents = Math.round(Number(String(price_eur).replace(",", ".")) * 100);
      if (Number.isNaN(cents) || cents < 0) return res.status(400).json({ error: "Prix invalide" });
      sets.push(`price_cents = $${i++}`); params.push(cents);
    }
    if (stock_status && ["en_stock", "rupture", "sur_commande"].includes(stock_status)) {
      sets.push(`stock_status = $${i++}`); params.push(stock_status);
    }
    if (title) { sets.push(`title = $${i++}`); params.push(title); }
    if (short_desc !== undefined) { sets.push(`short_desc = $${i++}`); params.push(short_desc); }
    if (long_desc !== undefined) { sets.push(`long_desc = $${i++}`); params.push(long_desc); }
    if (brand !== undefined) { sets.push(`brand = $${i++}`); params.push(brand ? String(brand).trim() : null); }

    if (!sets.length) return res.status(400).json({ error: "Rien à modifier" });
    sets.push(`updated_at = now()`);
    params.push(req.params.id);

    try {
      const r = await pool.query(
        `UPDATE products SET ${sets.join(", ")} WHERE id = $${i} RETURNING id, price_cents, stock_status`,
        params
      );
      if (!r.rows.length) return res.status(404).json({ error: "Produit introuvable" });
      res.json(r.rows[0]);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // slugify stable
  function slugifyProduct(name) {
    return String(name || "")
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
  }

  async function uniqueSlug(client, base) {
    let slug = base || "produit";
    let n = 1;
    // eslint-disable-next-line no-constant-condition
    while (true) {
      const r = await client.query("SELECT 1 FROM products WHERE slug = $1", [slug]);
      if (!r.rows.length) return slug;
      n += 1;
      slug = `${base}-${n}`;
    }
  }

  app.get("/api/admin/categories", requireAuth, async (_req, res) => {
    try {
      const r = await pool.query(
        `SELECT c.id, c.name, c.slug, c.parent_id, c.image_url, COUNT(pc.product_id)::int AS product_count
         FROM categories c
         LEFT JOIN product_categories pc ON pc.category_id = c.id
         GROUP BY c.id
         ORDER BY (c.parent_id IS NOT NULL), c.name ASC`
      );
      res.json(r.rows);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.get("/api/admin/brands", requireAuth, async (_req, res) => {
    try {
      const r = await pool.query(
        `SELECT brand AS name, COUNT(*)::int AS product_count
         FROM products
         WHERE brand IS NOT NULL AND brand <> ''
         GROUP BY brand
         ORDER BY name ASC`
      );
      res.json(r.rows);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.post("/api/admin/products", requireAuth, async (req, res) => {
    const {
      title, brand, reference, price_eur, currency, stock_status,
      short_desc, long_desc, category_ids, images,
    } = req.body || {};

    if (!title || !String(title).trim()) {
      return res.status(400).json({ error: "Le titre est obligatoire." });
    }

    let priceCents = 0;
    if (price_eur !== undefined && price_eur !== null && price_eur !== "") {
      priceCents = Math.round(Number(String(price_eur).replace(",", ".")) * 100);
      if (Number.isNaN(priceCents) || priceCents < 0) {
        return res.status(400).json({ error: "Prix invalide." });
      }
    }

    const stock = ["en_stock", "rupture", "sur_commande"].includes(stock_status)
      ? stock_status : "en_stock";

    const cats = Array.isArray(category_ids)
      ? category_ids.map((x) => parseInt(x)).filter((x) => Number.isInteger(x)) : [];
    const imgs = Array.isArray(images)
      ? images.map((u) => String(u).trim()).filter(Boolean) : [];

    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const slug = await uniqueSlug(client, slugifyProduct(title));
      const ins = await client.query(
        `INSERT INTO products
           (slug, title, reference, brand, price_cents, currency, short_desc, long_desc,
            features, stock_status, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'[]'::jsonb,$9, now())
         RETURNING id, slug`,
        [
          slug, String(title).trim(),
          reference ? String(reference).trim() : null,
          brand ? String(brand).trim() : null,
          priceCents, (currency || "EUR").toUpperCase(),
          short_desc ? String(short_desc) : null,
          long_desc ? String(long_desc) : null,
          stock,
        ]
      );
      const productId = ins.rows[0].id;
      for (let i = 0; i < imgs.length; i++) {
        await client.query(
          `INSERT INTO product_images (product_id, url, "position") VALUES ($1,$2,$3)`,
          [productId, imgs[i], i]
        );
      }
      for (const cid of cats) {
        await client.query(
          `INSERT INTO product_categories (product_id, category_id)
           VALUES ($1,$2) ON CONFLICT DO NOTHING`,
          [productId, cid]
        );
      }
      await client.query("COMMIT");
      res.status(201).json({ id: productId, slug: ins.rows[0].slug });
    } catch (e) {
      await client.query("ROLLBACK");
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  const multer = require("multer");
  const cloudinary = require("cloudinary").v2;

  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });

  const uploadMem = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 8 * 1024 * 1024, files: 8 },
    fileFilter: (_req, file, cb) => {
      if (/^image\//.test(file.mimetype)) return cb(null, true);
      cb(new Error("Seules les images sont acceptées."));
    },
  });

  function uploadBufferToCloudinary(buffer) {
    return new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: "piecesauto", resource_type: "image" },
        (err, result) => (err ? reject(err) : resolve(result.secure_url))
      );
      stream.end(buffer);
    });
  }

  app.post("/api/admin/upload", requireAuth, (req, res) => {
    uploadMem.array("files", 8)(req, res, async (mErr) => {
      if (mErr) return res.status(400).json({ error: mErr.message });
      if (!req.files || !req.files.length) {
        return res.status(400).json({ error: "Aucun fichier reçu." });
      }
      if (!process.env.CLOUDINARY_CLOUD_NAME) {
        return res.status(500).json({ error: "Cloudinary non configuré (variables d'env manquantes)." });
      }
      try {
        const urls = [];
        for (const f of req.files) {
          urls.push(await uploadBufferToCloudinary(f.buffer));
        }
        res.json({ urls });
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });
  });

  app.get("/api/admin/products/:id/images", requireAuth, async (req, res) => {
    try {
      const r = await pool.query(
        `SELECT url FROM product_images WHERE product_id = $1 ORDER BY "position", id`,
        [req.params.id]
      );
      res.json({ images: r.rows.map((x) => x.url) });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.put("/api/admin/products/:id/images", requireAuth, async (req, res) => {
    const { images } = req.body || {};
    if (!Array.isArray(images)) {
      return res.status(400).json({ error: "Le champ 'images' doit être un tableau." });
    }
    const urls = images.map((u) => String(u).trim()).filter(Boolean);
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const p = await client.query("SELECT id FROM products WHERE id = $1", [req.params.id]);
      if (!p.rows.length) {
        await client.query("ROLLBACK");
        return res.status(404).json({ error: "Produit introuvable" });
      }
      await client.query("DELETE FROM product_images WHERE product_id = $1", [req.params.id]);
      for (let i = 0; i < urls.length; i++) {
        await client.query(
          `INSERT INTO product_images (product_id, url, "position") VALUES ($1, $2, $3)`,
          [req.params.id, urls[i], i]
        );
      }
      await client.query("UPDATE products SET updated_at = now() WHERE id = $1", [req.params.id]);
      await client.query("COMMIT");
      res.json({ id: Number(req.params.id), images: urls });
    } catch (e) {
      await client.query("ROLLBACK");
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  app.get("/api/admin/products/:id/categories", requireAuth, async (req, res) => {
    try {
      const r = await pool.query(
        `SELECT c.id, c.name
         FROM categories c
         JOIN product_categories pc ON pc.category_id = c.id
         WHERE pc.product_id = $1
         ORDER BY c.name`,
        [req.params.id]
      );
      res.json({ category_ids: r.rows.map((x) => x.id), categories: r.rows });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.put("/api/admin/products/:id/categories", requireAuth, async (req, res) => {
    const { category_ids } = req.body || {};
    if (!Array.isArray(category_ids)) {
      return res.status(400).json({ error: "Le champ 'category_ids' doit être un tableau." });
    }
    const ids = category_ids.map((x) => parseInt(x)).filter((x) => Number.isInteger(x));
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const p = await client.query("SELECT id FROM products WHERE id = $1", [req.params.id]);
      if (!p.rows.length) {
        await client.query("ROLLBACK");
        return res.status(404).json({ error: "Produit introuvable" });
      }
      await client.query("DELETE FROM product_categories WHERE product_id = $1", [req.params.id]);
      for (const cid of ids) {
        await client.query(
          `INSERT INTO product_categories (product_id, category_id)
           VALUES ($1, $2) ON CONFLICT DO NOTHING`,
          [req.params.id, cid]
        );
      }
      await client.query("COMMIT");
      res.json({ id: Number(req.params.id), category_ids: ids });
    } catch (e) {
      await client.query("ROLLBACK");
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  app.patch("/api/admin/categories/:id", requireAuth, async (req, res) => {
    const { image_url } = req.body || {};
    try {
      const r = await pool.query(
        `UPDATE categories SET image_url = $1 WHERE id = $2
         RETURNING id, name, slug, image_url`,
        [image_url ? String(image_url).trim() : null, req.params.id]
      );
      if (!r.rows.length) return res.status(404).json({ error: "Rayon introuvable" });
      res.json(r.rows[0]);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.get("/api/admin/payment-info", requireAuth, async (_req, res) => {
    try {
      const bank = await getPaymentSettings(pool);
      res.json(bank || {});
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.put("/api/admin/payment-info", requireAuth, async (req, res) => {
    const {
      payment_mode, bank_name, agency_name, account_holder, iban, bic,
      payment_link_url, payment_link_label,
    } = req.body || {};

    if (payment_mode && !["rib", "lien"].includes(payment_mode)) {
      return res.status(400).json({ error: "payment_mode doit être 'rib' ou 'lien'." });
    }
    if (payment_mode === "lien" && !payment_link_url) {
      return res.status(400).json({ error: "Un lien de paiement est requis pour activer ce mode." });
    }

    try {
      const current = await getPaymentSettings(pool);
      const next = {
        payment_mode: payment_mode !== undefined ? payment_mode : (current?.payment_mode || "rib"),
        bank_name: bank_name !== undefined ? (bank_name ? String(bank_name).trim() : null) : current?.bank_name ?? null,
        agency_name: agency_name !== undefined ? (agency_name ? String(agency_name).trim() : null) : current?.agency_name ?? null,
        account_holder: account_holder !== undefined ? (account_holder ? String(account_holder).trim() : null) : current?.account_holder ?? null,
        iban: iban !== undefined ? (iban ? String(iban).trim() : null) : current?.iban ?? null,
        bic: bic !== undefined ? (bic ? String(bic).trim() : null) : current?.bic ?? null,
        payment_link_url: payment_link_url !== undefined ? (payment_link_url ? String(payment_link_url).trim() : null) : current?.payment_link_url ?? null,
        payment_link_label: payment_link_label !== undefined ? (payment_link_label ? String(payment_link_label).trim() : null) : current?.payment_link_label ?? null,
      };

      const r = await pool.query(
        `INSERT INTO payment_settings
           (id, payment_mode, bank_name, agency_name, account_holder, iban, bic,
            payment_link_url, payment_link_label, updated_at)
         VALUES (1, $1, $2, $3, $4, $5, $6, $7, $8, now())
         ON CONFLICT (id) DO UPDATE SET
           payment_mode = EXCLUDED.payment_mode,
           bank_name = EXCLUDED.bank_name,
           agency_name = EXCLUDED.agency_name,
           account_holder = EXCLUDED.account_holder,
           iban = EXCLUDED.iban,
           bic = EXCLUDED.bic,
           payment_link_url = EXCLUDED.payment_link_url,
           payment_link_label = EXCLUDED.payment_link_label,
           updated_at = now()
         RETURNING *`,
        [
          next.payment_mode, next.bank_name, next.agency_name, next.account_holder,
          next.iban, next.bic, next.payment_link_url, next.payment_link_label,
        ]
      );
      res.json(r.rows[0]);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.delete("/api/admin/products/:id", requireAuth, async (req, res) => {
    try {
      const r = await pool.query(
        "DELETE FROM products WHERE id = $1 RETURNING id",
        [req.params.id]
      );
      if (!r.rows.length) return res.status(404).json({ error: "Produit introuvable" });
      res.json({ id: r.rows[0].id, deleted: true });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

};
// ---------------------------------------------------------------- //
// Export de la génération PDF pour réutilisation côté public
module.exports.buildInvoicePdf = buildInvoicePdf;