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

  const where = [];
  const params = [];

  if (q) {
    params.push(`%${q}%`);
    where.push(`(p.title ILIKE $${params.length} OR p.reference ILIKE $${params.length})`);
  }
  if (category) {
    params.push(category);
    where.push(`EXISTS (
      SELECT 1 FROM product_categories pc
      JOIN categories c ON c.id = pc.category_id
      WHERE pc.product_id = p.id AND c.slug = $${params.length}
    )`);
  }
  const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";

  try {
    const countRes = await pool.query(
      `SELECT COUNT(*)::int AS total FROM products p ${whereSql}`, params
    );

    params.push(limit, offset);
    const rows = await pool.query(
      `SELECT p.id, p.slug, p.title, p.reference, p.brand, p.price_cents, p.stock_status,
              (SELECT url FROM product_images i WHERE i.product_id = p.id ORDER BY position LIMIT 1) AS image
       FROM products p
       ${whereSql}
       ORDER BY p.title ASC
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
// Catégories avec une image représentative (pour les tuiles de l'accueil)
app.get("/api/categories/featured", async (req, res) => {
  const limit = Math.min(12, Math.max(1, parseInt(req.query.limit) || 10));
  try {
    const r = await pool.query(
      `SELECT c.id, c.name, c.slug, COUNT(pc.product_id)::int AS product_count,
              (
                SELECT i.url
                FROM product_categories pc2
                JOIN product_images i ON i.product_id = pc2.product_id
                WHERE pc2.category_id = c.id
                ORDER BY i.position
                LIMIT 1
              ) AS image
       FROM categories c
       JOIN product_categories pc ON pc.category_id = c.id
       GROUP BY c.id
       HAVING COUNT(pc.product_id) > 0
       ORDER BY product_count DESC, c.name ASC
       LIMIT $1`, [limit]
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Catégories (avec compte de produits)
app.get("/api/categories", async (_req, res) => {
  try {
    const r = await pool.query(
      `SELECT c.id, c.name, c.slug, COUNT(pc.product_id)::int AS product_count
       FROM categories c
       LEFT JOIN product_categories pc ON pc.category_id = c.id
       GROUP BY c.id
       HAVING COUNT(pc.product_id) > 0
       ORDER BY product_count DESC, c.name ASC`
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ------------------------------------------------------------------ //
// Création de commande (règlement hors-ligne : virement, chèque,
// à la livraison, espèces — la facture est envoyée manuellement)
const PAYMENT_METHODS = ["virement", "cheque", "livraison", "especes"];

app.post("/api/orders", async (req, res) => {
  const { customer, payment_method, items, note } = req.body || {};

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

    const seq = await client.query("SELECT nextval('order_number_seq') AS n");
    const orderNumber = `CMD-${new Date().getFullYear()}-${String(seq.rows[0].n).padStart(6, "0")}`;

    const orderRes = await client.query(
      `INSERT INTO orders
         (order_number, customer_name, customer_email, customer_phone,
          address_line, postal_code, city, country, payment_method, total_cents, note)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       RETURNING id, order_number, created_at`,
      [
        orderNumber, customer.name, customer.email, customer.phone || null,
        customer.address_line, customer.postal_code, customer.city,
        customer.country || "France", payment_method, total, note || null,
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
      payment_method,
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
app.listen(PORT, "0.0.0.0", () => {
  console.log(`[✓] API PiècesAuto démarrée : http://0.0.0.0:${PORT}`);
  console.log(`    Test : http://localhost:${PORT}/health`);
});

