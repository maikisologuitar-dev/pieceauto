// scripts/import-fresh-catalogue.js
//
// Import optimisé du catalogue fresh.aateile.com (format Shopify) vers la base
// piecesauto (tables products / product_images / product_categories).
//
// Usage :
//   export DATABASE_URL="postgresql://user:pass@host:port/railway"
//   node scripts/import-fresh-catalogue.js data/produits.json
//
// Optimisations :
//   - Insertions groupées (multi-row) : ~15-20 requêtes au lieu de ~2900.
//   - Une transaction par lot (BATCH_SIZE) : une erreur n'annule qu'un lot,
//     pas tout l'import. Progression conservée entre les lots.
//   - Mapping images/catégories via RETURNING id, slug (pas de désalignement).
//   - Déduplication des slugs en amont (évite l'erreur ON CONFLICT double-row).
//   - Respect de la limite de 65535 paramètres de node-postgres.
//   - Ctrl+C propre : termine le lot en cours puis s'arrête sans rollback.
//   - Réexécutable : upsert sur slug, images remplacées, lien catégorie idempotent.

const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

const BATCH_SIZE = 100; // produits par transaction
const CATEGORY_NAME = "Accessoires";
const CATEGORY_SLUG = "accessoires";

// ---------------------------------------------------------------------------
// Lecture + validation de l'entrée
// ---------------------------------------------------------------------------
const inputPath = process.argv[2];
if (!inputPath) {
  console.error("Usage: node scripts/import-fresh-catalogue.js <chemin-vers-produits.json>");
  process.exit(1);
}

let produits;
try {
  produits = JSON.parse(fs.readFileSync(path.resolve(inputPath), "utf-8"));
} catch (err) {
  console.error("Impossible de lire/parser le JSON :", err.message);
  process.exit(1);
}
if (!Array.isArray(produits)) {
  console.error("Le fichier JSON doit contenir un tableau de produits.");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Normalisation + déduplication (par slug, on garde la dernière occurrence)
// ---------------------------------------------------------------------------
function toPriceCents(p) {
  if (p === null || p === undefined || isNaN(p)) return 0;
  return Math.round(Number(p) * 100);
}

function normalize(p) {
  const features = [];
  if (p.type) features.push(`Type: ${p.type}`);
  if (p.tags) features.push(`Tags: ${p.tags}`);

  const images = [];
  if (p.image_principale) images.push(p.image_principale.trim());
  if (p.toutes_images) {
    p.toutes_images
      .split("|")
      .map((u) => u.trim())
      .filter(Boolean)
      .forEach((u) => {
        if (!images.includes(u)) images.push(u);
      });
  }

  return {
    slug: p.handle,
    title: (p.titre || "").trim(),
    reference: p.id ? String(p.id) : null,
    brand: p.vendeur || null,
    price_cents: toPriceCents(p.prix_min),
    currency: (p.devise || "EUR").toUpperCase(),
    features: JSON.stringify(features),
    stock_status: p.disponible ? "en_stock" : "rupture_stock",
    source_url: p.url || null,
    images,
  };
}

const seen = new Map();
let skippedInvalid = 0;
for (const p of produits) {
  if (!p.handle || !p.titre) {
    skippedInvalid++;
    continue;
  }
  seen.set(p.handle, normalize(p)); // dernière occurrence gagne
}
const clean = [...seen.values()];
const dupCount = produits.length - skippedInvalid - clean.length;

console.log(
  `Fichier : ${produits.length} produits | valides & uniques : ${clean.length}` +
    (dupCount > 0 ? ` | doublons de slug fusionnés : ${dupCount}` : "") +
    (skippedInvalid > 0 ? ` | ignorés (handle/titre manquant) : ${skippedInvalid}` : "")
);

// ---------------------------------------------------------------------------
// Connexion
// ---------------------------------------------------------------------------
const client = process.env.DATABASE_URL
  ? new Client({
      connectionString: process.env.DATABASE_URL,
      ssl: /railway|rlwy\.net/.test(process.env.DATABASE_URL)
        ? { rejectUnauthorized: false }
        : undefined,
    })
  : new Client({
      host: process.env.PGHOST || "localhost",
      port: process.env.PGPORT || 5432,
      database: process.env.PGDATABASE || "piecesauto",
      user: process.env.PGUSER || "postgres",
      password: process.env.PGPASSWORD || "postgres",
    });

// ---------------------------------------------------------------------------
// Arrêt propre : on demande l'arrêt, la boucle finit le lot courant puis stoppe
// ---------------------------------------------------------------------------
let stopRequested = false;
process.on("SIGINT", () => {
  if (stopRequested) {
    console.log("\nArrêt forcé.");
    process.exit(1);
  }
  stopRequested = true;
  console.log("\nArrêt demandé — le lot en cours se termine proprement, patiente…");
});

// ---------------------------------------------------------------------------
// Helpers de construction de requêtes multi-lignes
// ---------------------------------------------------------------------------
// Construit "($1,$2,...),($n,...)" et le tableau de valeurs aplati.
function buildValues(rows, cols) {
  const params = [];
  const tuples = rows.map((row) => {
    const placeholders = cols.map((col) => {
      params.push(typeof col === "function" ? col(row) : row[col]);
      return `$${params.length}`;
    });
    return `(${placeholders.join(",")})`;
  });
  return { text: tuples.join(","), params };
}

async function getOrCreateCategoryId() {
  const existing = await client.query(`SELECT id FROM categories WHERE slug = $1`, [CATEGORY_SLUG]);
  if (existing.rows.length > 0) return existing.rows[0].id;
  const inserted = await client.query(
    `INSERT INTO categories (name, slug) VALUES ($1, $2)
     ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
     RETURNING id`,
    [CATEGORY_NAME, CATEGORY_SLUG]
  );
  return inserted.rows[0].id;
}

// ---------------------------------------------------------------------------
// Traitement d'un lot dans une transaction
// ---------------------------------------------------------------------------
async function processBatch(batch, categoryId) {
  await client.query("BEGIN");
  try {
    // 1) Upsert produits (multi-row) + récupération des ids par slug.
    //    On passe par une CTE VALUES typée pour caster proprement les colonnes.
    const cols = [
      "slug",
      "title",
      "reference",
      "brand",
      "price_cents",
      "currency",
      "features",
      "stock_status",
      "source_url",
    ];
    const { text, params } = buildValues(batch, cols);
    const upsertSql = `
      INSERT INTO products
        (slug, title, reference, brand, price_cents, currency, features, stock_status, source_url, updated_at)
      SELECT v.slug, v.title, v.reference, v.brand,
             v.price_cents::int, v.currency, v.features::jsonb,
             v.stock_status, v.source_url, now()
      FROM (VALUES ${text}) AS v(slug, title, reference, brand, price_cents, currency, features, stock_status, source_url)
      ON CONFLICT (slug) DO UPDATE SET
        title        = EXCLUDED.title,
        reference    = EXCLUDED.reference,
        brand        = EXCLUDED.brand,
        price_cents  = EXCLUDED.price_cents,
        currency     = EXCLUDED.currency,
        features     = EXCLUDED.features,
        stock_status = EXCLUDED.stock_status,
        source_url   = EXCLUDED.source_url,
        updated_at   = now()
      RETURNING id, slug`;
    const upserted = await client.query(upsertSql, params);

    const idBySlug = new Map(upserted.rows.map((r) => [r.slug, r.id]));
    const ids = [...idBySlug.values()];

    // 2) Remplacement des images : suppression groupée puis insertion groupée
    if (ids.length > 0) {
      await client.query(`DELETE FROM product_images WHERE product_id = ANY($1::int[])`, [ids]);
    }

    const imageRows = [];
    for (const p of batch) {
      const pid = idBySlug.get(p.slug);
      if (!pid) continue; // sécurité : ne devrait pas arriver
      p.images.forEach((url, position) => imageRows.push({ product_id: pid, url, position }));
    }
    if (imageRows.length > 0) {
      // 3 params/ligne → largement sous la limite de 65535
      const { text: imgText, params: imgParams } = buildValues(imageRows, [
        "product_id",
        "url",
        "position",
      ]);
      await client.query(
        `INSERT INTO product_images (product_id, url, "position") VALUES ${imgText}`,
        imgParams
      );
    }

    // 3) Lien catégorie (idempotent)
    if (ids.length > 0) {
      const catRows = ids.map((product_id) => ({ product_id, category_id: categoryId }));
      const { text: catText, params: catParams } = buildValues(catRows, [
        "product_id",
        "category_id",
      ]);
      await client.query(
        `INSERT INTO product_categories (product_id, category_id) VALUES ${catText}
         ON CONFLICT DO NOTHING`,
        catParams
      );
    }

    await client.query("COMMIT");
    return { count: upserted.rows.length, images: imageRows.length };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  }
}

// ---------------------------------------------------------------------------
// Boucle principale
// ---------------------------------------------------------------------------
async function main() {
  const t0 = Date.now();
  await client.connect();
  console.log("Connecté.");

  const categoryId = await getOrCreateCategoryId();
  console.log(`Catégorie "${CATEGORY_NAME}" prête (id=${categoryId}).`);

  let processed = 0;
  let imagesTotal = 0;
  let batchErrors = 0;
  const total = clean.length;
  const nbBatches = Math.ceil(clean.length / BATCH_SIZE);

  for (let i = 0; i < clean.length; i += BATCH_SIZE) {
    if (stopRequested) {
      console.log(`Arrêt avant le lot suivant. ${processed}/${total} déjà committés.`);
      break;
    }
    const batch = clean.slice(i, i + BATCH_SIZE);
    const batchNo = Math.floor(i / BATCH_SIZE) + 1;
    try {
      const res = await processBatch(batch, categoryId);
      processed += res.count;
      imagesTotal += res.images;
      console.log(
        `Lot ${batchNo}/${nbBatches} OK — ${res.count} produits, ${res.images} images ` +
          `(total ${processed}/${total})`
      );
    } catch (err) {
      batchErrors++;
      console.error(`Lot ${batchNo}/${nbBatches} ÉCHOUÉ (annulé) : ${err.message}`);
    }
  }

  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("---");
  console.log(
    `Terminé en ${secs}s. Produits importés : ${processed}/${total} | ` +
      `Images : ${imagesTotal} | Lots en erreur : ${batchErrors}`
  );

  await client.end();
  process.exit(batchErrors > 0 ? 1 : 0);
}

main().catch(async (err) => {
  console.error("Erreur fatale :", err);
  try {
    await client.end();
  } catch (_) {}
  process.exit(1);
});