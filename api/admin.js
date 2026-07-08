/**
 * admin.js — Routes back-office (montées sous /api/admin dans server.js)
 *
 * Auth : login par email/mot de passe (PBKDF2) -> renvoie un JWT signé
 * maison (HMAC-SHA256, sans dépendance externe). Le token est ensuite
 * exigé dans l'en-tête Authorization: Bearer <token> pour toutes les
 * routes /api/admin/* (sauf /login).
 *
 * Fonctionnalités :
 *   POST /api/admin/login
 *   GET  /api/admin/orders            liste des commandes
 *   GET  /api/admin/orders/:id        détail d'une commande + lignes
 *   PATCH /api/admin/orders/:id       change le statut
 *   GET  /api/admin/orders/:id/invoice  facture PDF (pdf-lib)
 *   GET  /api/admin/products          liste produits (pagination/recherche)
 *   PATCH /api/admin/products/:id     modifie prix / stock / textes
 *   GET  /api/admin/stats             quelques chiffres pour le dashboard
 */

const crypto = require("crypto");
const { PDFDocument, StandardFonts, rgb } = require("pdf-lib");

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

// ---------- Génération facture PDF ----------
async function buildInvoicePdf(order, items) {
  const pdf = await PDFDocument.create();
  const page = pdf.addPage([595, 842]); // A4
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const { height } = page.getSize();
  const orange = rgb(0.91, 0.35, 0.05);
  const dark = rgb(0.08, 0.09, 0.11);
  const gray = rgb(0.42, 0.45, 0.5);

  let y = height - 60;
  const M = 50;

  // En-tête
  page.drawText("PiècesAuto", { x: M, y, size: 24, font: bold, color: dark });
  page.drawText("FACTURE", { x: 420, y, size: 22, font: bold, color: orange });
  y -= 22;
  page.drawText("Pièces et équipement automobile", { x: M, y, size: 9, font, color: gray });
  page.drawText(order.order_number, { x: 420, y, size: 11, font, color: dark });
  y -= 40;

  // Client
  page.drawText("Facturé à :", { x: M, y, size: 10, font: bold, color: dark });
  const dateStr = new Date(order.created_at).toLocaleDateString("fr-FR");
  page.drawText(`Date : ${dateStr}`, { x: 420, y, size: 10, font, color: dark });
  y -= 16;
  const clientLines = [
    order.customer_name,
    order.address_line,
    `${order.postal_code} ${order.city}`,
    order.country,
    order.customer_email,
    order.customer_phone || "",
  ].filter(Boolean);
  for (const line of clientLines) {
    page.drawText(line, { x: M, y, size: 10, font, color: dark });
    y -= 14;
  }
  y -= 20;

  // Tableau : en-tête
  const colX = { desig: M, ref: 300, qty: 380, pu: 430, total: 500 };
  page.drawRectangle({ x: M - 5, y: y - 4, width: 505, height: 22, color: dark });
  page.drawText("Désignation", { x: colX.desig, y: y + 3, size: 9, font: bold, color: rgb(1, 1, 1) });
  page.drawText("Réf.", { x: colX.ref, y: y + 3, size: 9, font: bold, color: rgb(1, 1, 1) });
  page.drawText("Qté", { x: colX.qty, y: y + 3, size: 9, font: bold, color: rgb(1, 1, 1) });
  page.drawText("P.U.", { x: colX.pu, y: y + 3, size: 9, font: bold, color: rgb(1, 1, 1) });
  page.drawText("Total", { x: colX.total, y: y + 3, size: 9, font: bold, color: rgb(1, 1, 1) });
  y -= 22;

  // Lignes
  let totalHT = 0;
  for (const it of items) {
    const lineTotal = it.unit_cents * it.quantity;
    totalHT += lineTotal;
    const title = it.title.length > 42 ? it.title.slice(0, 40) + "…" : it.title;
    page.drawText(title, { x: colX.desig, y, size: 9, font, color: dark });
    page.drawText(it.reference || "-", { x: colX.ref, y, size: 9, font, color: gray });
    page.drawText(String(it.quantity), { x: colX.qty, y, size: 9, font, color: dark });
    page.drawText(euro(it.unit_cents), { x: colX.pu, y, size: 9, font, color: dark });
    page.drawText(euro(lineTotal), { x: colX.total, y, size: 9, font, color: dark });
    y -= 18;
    if (y < 120) { y = height - 60; pdf.addPage([595, 842]); }
  }

  // Totaux (TVA 20 % incluse, prix TTC)
  y -= 10;
  page.drawLine({ start: { x: 380, y }, end: { x: 545, y }, thickness: 1, color: gray });
  y -= 18;
  const totalTTC = totalHT;
  const ht = Math.round(totalTTC / 1.2);
  const tva = totalTTC - ht;
  page.drawText("Total HT :", { x: 400, y, size: 10, font, color: dark });
  page.drawText(euro(ht), { x: 500, y, size: 10, font, color: dark });
  y -= 16;
  page.drawText("TVA 20 % :", { x: 400, y, size: 10, font, color: dark });
  page.drawText(euro(tva), { x: 500, y, size: 10, font, color: dark });
  y -= 18;
  page.drawText("TOTAL TTC :", { x: 400, y, size: 12, font: bold, color: orange });
  page.drawText(euro(totalTTC), { x: 500, y, size: 12, font: bold, color: orange });

  // Mode de règlement
  y -= 40;
  page.drawText(`Mode de règlement : ${PAYMENT_LABELS[order.payment_method] || order.payment_method}`,
    { x: M, y, size: 10, font: bold, color: dark });
  y -= 30;
  page.drawText("Merci de votre confiance. Facture à régler selon les modalités convenues.",
    { x: M, y, size: 9, font, color: gray });

  return pdf.save();
}

// ---------- Montage des routes ----------
module.exports = function registerAdminRoutes(app, pool) {
  // Middleware d'authentification
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
                status, total_cents, created_at
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
      const pdfBytes = await buildInvoicePdf(o.rows[0], items.rows);
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
    const { price_eur, stock_status, title, short_desc, long_desc } = req.body || {};
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
};
