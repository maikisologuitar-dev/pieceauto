/**
 * server.js — API Express du catalogue PiècesAuto
 *
 * Endpoints :
 *   GET  /health
 *   GET  /api/products?page=1&limit=12&q=filtre&category=slug
 *   GET  /api/products/:slug
 *   GET  /api/categories
 *   POST /api/orders          (commande avec règlement hors-ligne)
 *
 * Démarrage :  node server.js   (port 4000 par défaut)
 */

const express = require("express");
const cors = require("cors");
const crypto = require("crypto");
const multer = require("multer");
const cloudinary = require("cloudinary").v2;
const { Pool } = require("pg");

const app = express();
app.use(cors());
app.use(express.json());

// Connexion : priorité à DATABASE_URL (Railway/production), sinon variables
// séparées (développement local).
const pool = new Pool(
  process.env.DATABASE_URL
    ? {
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false },
      }
    : {
        host: process.env.PGHOST || "localhost",
        port: Number(process.env.PGPORT || 5432),
        database: process.env.PGDATABASE || "piecesauto",
        user: process.env.PGUSER || "postgres",
        password: process.env.PGPASSWORD || "postgres",
      }
);

const PORT = Number(process.env.PORT || 4000);

// Routes back-office (login, commandes, produits, factures PDF)
const registerAdminRoutes = require("./admin");
registerAdminRoutes(app, pool);
// Réutilise la génération PDF de l'admin pour le reçu client public
const { buildInvoicePdf } = registerAdminRoutes;

// ------------------------------------------------------------------ //
// Upload public de la preuve de paiement (capture / reçu du virement).
// Même compte Cloudinary que le back-office, dossier séparé.
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const uploadProofMem = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024, files: 1 },
  fileFilter: (_req, file, cb) => {
    if (/^image\//.test(file.mimetype) || file.mimetype === "application/pdf") return cb(null, true);
    cb(new Error("Seules les images ou un PDF sont acceptés."));
  },
});

function uploadProofToCloudinary(buffer) {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder: "piecesauto/preuves-paiement", resource_type: "auto" },
      (err, result) => (err ? reject(err) : resolve(result.secure_url))
    );
    stream.end(buffer);
  });
}

// ------------------------------------------------------------------ //
app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", db: "connected" });
  } catch (e) {
    res.status(500).json({ status: "error", db: e.message });
  }
});

// ------------------------------------------------------------------ //
// Liste des produits (pagination + recherche + filtre catégorie)
app.get("/api/products", async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.min(48, Math.max(1, parseInt(req.query.limit) || 12));
  const offset = (page - 1) * limit;
  const q = (req.query.q || "").trim();
  const category = (req.query.category || "").trim();
  const brand = (req.query.brand || "").trim();

  const where = [];
  const params = [];

  if (q) {
    params.push(`%${q}%`);
    where.push(`(p.title ILIKE $${params.length} OR p.reference ILIKE $${params.length})`);
  }
  if (category) {
    params.push(category);
    // Filtre hiérarchique : si `category` est une FAMILLE, on inclut aussi les
    // produits de tous ses rayons enfants. Si c'est un rayon, seul lui compte.
    where.push(`EXISTS (
      SELECT 1 FROM product_categories pc
      WHERE pc.product_id = p.id
        AND pc.category_id IN (
          WITH RECURSIVE tree AS (
            SELECT id FROM categories WHERE slug = $${params.length}
            UNION ALL
            SELECT c.id FROM categories c JOIN tree t ON c.parent_id = t.id
          )
          SELECT id FROM tree
        )
    )`);
  }
  if (brand) {
    params.push(brand);
    where.push(`p.brand = $${params.length}`);
  }
  const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";

  try {
    const countRes = await pool.query(
      `SELECT COUNT(*)::int AS total FROM products p ${whereSql}`, params
    );

    // Tri "round-robin" par marque : on numérote chaque produit à l'intérieur de
    // sa marque (rang 1, 2, 3…) puis on trie par ce rang. On obtient le 1er produit
    // de chaque marque, puis le 2e de chaque marque, etc. — les marques s'alternent
    // au lieu de former de longs blocs identiques. Sans marque = rejeté en fin.
    // Le tri reste 100 % déterministe (stable) grâce au title puis à l'id.
    const sort = (req.query.sort || "").trim();
    const orderSql =
      sort === "title"
        ? "ORDER BY p.title ASC, p.id ASC"
        : sort === "price"
        ? "ORDER BY p.price_cents ASC, p.title ASC"
        : `ORDER BY
             ROW_NUMBER() OVER (
               PARTITION BY COALESCE(p.brand, '~') ORDER BY p.title ASC, p.id ASC
             ) ASC,
             (p.brand IS NULL) ASC,
             p.brand ASC,
             p.title ASC`;

    params.push(limit, offset);
    const rows = await pool.query(
      `SELECT p.id, p.slug, p.title, p.reference, p.brand, p.price_cents, p.stock_status,
              (SELECT url FROM product_images i WHERE i.product_id = p.id ORDER BY position LIMIT 1) AS image
       FROM products p
       ${whereSql}
       ${orderSql}
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );

    res.json({
      page,
      limit,
      total: countRes.rows[0].total,
      pages: Math.ceil(countRes.rows[0].total / limit),
      products: rows.rows,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Fiche produit
app.get("/api/products/:slug", async (req, res) => {
  try {
    const r = await pool.query("SELECT * FROM products WHERE slug = $1", [req.params.slug]);
    if (!r.rows.length) return res.status(404).json({ error: "Produit introuvable" });
    const product = r.rows[0];

    const imgs = await pool.query(
      "SELECT url FROM product_images WHERE product_id = $1 ORDER BY position", [product.id]
    );
    const cats = await pool.query(
      `SELECT c.name, c.slug FROM categories c
       JOIN product_categories pc ON pc.category_id = c.id
       WHERE pc.product_id = $1 ORDER BY c.name`, [product.id]
    );

    res.json({ ...product, images: imgs.rows.map((x) => x.url), categories: cats.rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Catégories mises en avant sur l'accueil : les FAMILLES (niveau 1), avec
// leur image d'ambiance (ou à défaut une photo d'un produit de la famille)
// et le nombre total de produits (rayons enfants inclus).
app.get("/api/categories/featured", async (req, res) => {
  const limit = Math.min(20, Math.max(1, parseInt(req.query.limit) || 12));
  try {
    const r = await pool.query(
      `WITH fam AS (
         SELECT c.id, c.name, c.slug, c.image_url
         FROM categories c
         WHERE c.parent_id IS NULL
       ),
       -- tous les descendants de chaque famille (elle-même incluse)
       scope AS (
         SELECT f.id AS family_id, f.id AS cat_id FROM fam f
         UNION ALL
         SELECT f.id, ch.id FROM fam f JOIN categories ch ON ch.parent_id = f.id
       )
       SELECT f.id, f.name, f.slug,
              COALESCE(COUNT(pc.product_id), 0)::int AS product_count,
              COALESCE(
                f.image_url,
                (
                  SELECT i.url
                  FROM scope s2
                  JOIN product_categories pc2 ON pc2.category_id = s2.cat_id
                  JOIN product_images i ON i.product_id = pc2.product_id
                  WHERE s2.family_id = f.id
                  ORDER BY i.position
                  LIMIT 1
                )
              ) AS image
       FROM fam f
       LEFT JOIN scope s ON s.family_id = f.id
       LEFT JOIN product_categories pc ON pc.category_id = s.cat_id
       GROUP BY f.id, f.name, f.slug, f.image_url
       ORDER BY product_count DESC, f.name ASC
       LIMIT $1`, [limit]
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Catégories : hiérarchie familles -> rayons, avec comptes de produits.
app.get("/api/categories", async (req, res) => {
  const flat = req.query.flat === "1";
  const nonEmpty = req.query.nonempty === "1";
  try {
    const r = await pool.query(
      `WITH direct AS (
         SELECT c.id, COUNT(pc.product_id)::int AS n
         FROM categories c
         LEFT JOIN product_categories pc ON pc.category_id = c.id
         GROUP BY c.id
       )
       SELECT c.id, c.name, c.slug, c.parent_id, c.image_url,
              d.n AS own_count,
              (d.n + COALESCE((
                 SELECT SUM(d2.n)::int
                 FROM categories ch
                 JOIN direct d2 ON d2.id = ch.id
                 WHERE ch.parent_id = c.id
              ), 0))::int AS product_count
       FROM categories c
       JOIN direct d ON d.id = c.id
       ORDER BY (c.parent_id IS NOT NULL), c.name ASC`
    );

    let rows = r.rows;
    if (nonEmpty) rows = rows.filter((c) => c.product_count > 0);

    if (flat) return res.json(rows);

    const families = rows.filter((c) => c.parent_id === null);
    const byParent = new Map();
    for (const c of rows) {
      if (c.parent_id === null) continue;
      if (!byParent.has(c.parent_id)) byParent.set(c.parent_id, []);
      byParent.get(c.parent_id).push(c);
    }
    const tree = families.map((f) => ({ ...f, children: byParent.get(f.id) || [] }));
    res.json(tree);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Marques commerciales (avec compte de produits) pour le filtre du catalogue
app.get("/api/brands", async (_req, res) => {
  try {
    const r = await pool.query(
      `SELECT brand AS name, COUNT(*)::int AS product_count
       FROM products
       WHERE brand IS NOT NULL AND brand <> ''
       GROUP BY brand
       ORDER BY product_count DESC, brand ASC`
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Coordonnées bancaires (RIB) affichées au client sur la page de
// confirmation, pour effectuer le virement.
app.get("/api/payment-info", async (_req, res) => {
  try {
    const r = await pool.query(
      `SELECT payment_mode, bank_name, agency_name, account_holder, iban, bic,
              payment_link_url, payment_link_label
       FROM payment_settings WHERE id = 1`
    );
    const row = r.rows[0] || {};
    const mode = row.payment_mode === "lien" ? "lien" : "rib";
    if (mode === "lien") {
      res.json({
        mode,
        payment_link_url: row.payment_link_url || null,
        payment_link_label: row.payment_link_label || "Payer",
      });
    } else {
      res.json({
        mode,
        bank_name: row.bank_name || null,
        agency_name: row.agency_name || null,
        account_holder: row.account_holder || null,
        iban: row.iban || null,
        bic: row.bic || null,
      });
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Création de commande (règlement par virement bancaire uniquement)
const PAYMENT_METHODS = ["virement"];

app.post("/api/orders", async (req, res) => {
  // MODIF LIVRAISON : on lit aussi delivery_km / delivery_fee_cents du payload.
  const { customer, payment_method, items, note, delivery_km, delivery_fee_cents } = req.body || {};

  if (!customer || !customer.name || !customer.email || !customer.address_line ||
      !customer.postal_code || !customer.city) {
    return res.status(400).json({ error: "Coordonnées client incomplètes." });
  }
  if (!PAYMENT_METHODS.includes(payment_method)) {
    return res.status(400).json({ error: "Mode de règlement invalide." });
  }
  if (!Array.isArray(items) || !items.length) {
    return res.status(400).json({ error: "Panier vide." });
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // Recharge les produits côté serveur (ne jamais faire confiance aux prix du client)
    let total = 0;
    const lines = [];
    for (const it of items) {
      const qty = Math.max(1, parseInt(it.quantity) || 1);
      const r = await client.query(
        "SELECT id, title, reference, price_cents FROM products WHERE id = $1", [it.product_id]
      );
      if (!r.rows.length) throw new Error(`Produit ${it.product_id} introuvable`);
      const p = r.rows[0];
      total += p.price_cents * qty;
      lines.push({ ...p, quantity: qty });
    }

    // MODIF LIVRAISON : frais de livraison (calculés côté client, transmis dans
    // le payload) sécurisés puis ajoutés au total dû.
    const deliveryKm = Math.max(0, Number(delivery_km) || 0);
    const deliveryFeeCents = Math.max(0, Math.round(Number(delivery_fee_cents) || 0));
    total += deliveryFeeCents;

    const seq = await client.query("SELECT nextval('order_number_seq') AS n");
    const orderNumber = `CMD-${new Date().getFullYear()}-${String(seq.rows[0].n).padStart(6, "0")}`;

    // Jeton public imprévisible : permet au client de télécharger SON reçu.
    const publicToken = crypto.randomBytes(24).toString("hex");

    // MODIF LIVRAISON : deux colonnes en plus (delivery_km, delivery_fee_cents).
    const orderRes = await client.query(
      `INSERT INTO orders
         (order_number, customer_name, customer_email, customer_phone,
          address_line, postal_code, city, country, payment_method, total_cents, note,
          public_token, delivery_km, delivery_fee_cents)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
       RETURNING id, order_number, created_at`,
      [
        orderNumber, customer.name, customer.email, customer.phone || null,
        customer.address_line, customer.postal_code, customer.city,
        customer.country || "France", payment_method, total, note || null,
        publicToken, deliveryKm, deliveryFeeCents,
      ]
    );
    const orderId = orderRes.rows[0].id;

    for (const l of lines) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, title, reference, unit_cents, quantity)
         VALUES ($1,$2,$3,$4,$5,$6)`,
        [orderId, l.id, l.title, l.reference, l.price_cents, l.quantity]
      );
    }

    await client.query("COMMIT");
    res.status(201).json({
      order_number: orderRes.rows[0].order_number,
      total_cents: total,
      delivery_km: deliveryKm,
      delivery_fee_cents: deliveryFeeCents,
      payment_method,
      public_token: publicToken,
      message: "Commande enregistrée. La facture vous sera transmise par email.",
    });
  } catch (e) {
    await client.query("ROLLBACK");
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

// ------------------------------------------------------------------ //
// Upload de la preuve de paiement — route PUBLIQUE sécurisée par jeton.
app.post("/api/orders/:number/proof", (req, res) => {
  uploadProofMem.single("file")(req, res, async (mErr) => {
    if (mErr) return res.status(400).json({ error: mErr.message });

    const number = req.params.number;
    const token = (req.query.token || "").trim();
    if (!token) return res.status(400).json({ error: "Jeton manquant." });
    if (!req.file) return res.status(400).json({ error: "Aucun fichier reçu." });
    if (!process.env.CLOUDINARY_CLOUD_NAME) {
      return res.status(500).json({ error: "Cloudinary non configuré (variables d'env manquantes)." });
    }

    try {
      const o = await pool.query("SELECT * FROM orders WHERE order_number = $1", [number]);
      if (!o.rows.length) return res.status(404).json({ error: "Commande introuvable." });
      const order = o.rows[0];

      const expected = order.public_token || "";
      const a = Buffer.from(token);
      const b = Buffer.from(expected);
      const ok = expected && a.length === b.length && crypto.timingSafeEqual(a, b);
      if (!ok) return res.status(403).json({ error: "Accès refusé." });

      const url = await uploadProofToCloudinary(req.file.buffer);
      await pool.query(
        "UPDATE orders SET proof_url = $1, proof_uploaded_at = now() WHERE id = $2",
        [url, order.id]
      );
      res.json({ ok: true, proof_url: url });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
});

// ------------------------------------------------------------------ //
// Reçu PDF client — route PUBLIQUE sécurisée par jeton.
app.get("/api/orders/:number/receipt", async (req, res) => {
  const number = req.params.number;
  const token = (req.query.token || "").trim();
  if (!token) return res.status(400).json({ error: "Jeton manquant." });

  try {
    const o = await pool.query(
      "SELECT * FROM orders WHERE order_number = $1", [number]
    );
    if (!o.rows.length) return res.status(404).json({ error: "Commande introuvable." });

    const order = o.rows[0];
    const expected = order.public_token || "";
    const a = Buffer.from(token);
    const b = Buffer.from(expected);
    const ok = expected && a.length === b.length && crypto.timingSafeEqual(a, b);
    if (!ok) return res.status(403).json({ error: "Accès refusé." });

    const items = await pool.query(
      "SELECT * FROM order_items WHERE order_id = $1 ORDER BY id", [order.id]
    );
    const bankRes = await pool.query("SELECT * FROM payment_settings WHERE id = 1");
    const pdfBytes = await buildInvoicePdf(order, items.rows, bankRes.rows[0] || null);
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `inline; filename="recu-${number}.pdf"`);
    res.send(Buffer.from(pdfBytes));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
app.listen(PORT, () => {
  console.log(`[✓] API PiècesAuto démarrée : http://localhost:${PORT}`);
  console.log(`    Test : http://localhost:${PORT}/health`);
});