#!/usr/bin/env node
/**
 * import-scraped.js — Importe le catalogue scrapé (pieces_auto_produits.json)
 * dans PostgreSQL, avec nettoyage des données.
 *
 * Usage (depuis la racine du projet) :
 *    node scripts/import-scraped.js data/pieces_auto_produits.json
 *
 * Variables d'environnement (ou valeurs par défaut ci-dessous) :
 *    PGHOST=localhost PGPORT=5432 PGDATABASE=piecesauto PGUSER=postgres PGPASSWORD=...
 */

const fs = require("fs");
const path = require("path");
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.PGHOST || "localhost",
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE || "piecesauto",
  user: process.env.PGUSER || "postgres",
  password: process.env.PGPASSWORD || "postgres",
});

// ---------- Nettoyage ----------

// Éléments de menu qui ont pollué le scraping (à exclure)
const JUNK = [
  "se connecter", "s’enregistrer", "s'enregistrer", "mot de passe oublié",
  "mon compte", "panier", "commande", "connexion",
];

const isJunk = (s) => {
  const t = (s || "").toLowerCase().trim();
  return !t || JUNK.some((j) => t.includes(j));
};

function slugFromUrl(url) {
  try {
    const parts = new URL(url).pathname.split("/").filter(Boolean);
    return decodeURIComponent(parts[parts.length - 1]).toLowerCase();
  } catch {
    return null;
  }
}

function slugify(s) {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 120);
}

function cleanFeatures(features) {
  return (features || []).filter((f) => !isJunk(f)).slice(0, 12);
}

function cleanCategories(categories) {
  // Le scraping a parfois attrapé tout le menu latéral ; on garde des noms
  // plausibles (pas de junk, longueur raisonnable) et on limite à 6.
  return (categories || [])
    .filter((c) => !isJunk(c) && c.length >= 3 && c.length <= 60)
    .slice(0, 6);
}

function cleanImages(images) {
  // Écarte les miniatures -200x200 si une version pleine taille existe,
  // déduplique, limite à 6.
  const all = (images || []).filter((u) => /\/wp-content\/uploads\//.test(u));
  const fullSize = all.filter((u) => !/-\d+x\d+\.(jpg|jpeg|png|webp)$/i.test(u));
  const chosen = fullSize.length ? fullSize : all;
  return [...new Set(chosen)].slice(0, 6);
}

// ---------- Import ----------

async function upsertCategory(client, name) {
  const slug = slugify(name);
  const r = await client.query(
    `INSERT INTO categories (name, slug) VALUES ($1, $2)
     ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
     RETURNING id`,
    [name, slug]
  );
  return r.rows[0].id;
}

async function main() {
  const file = process.argv[2] || path.join(__dirname, "..", "data", "pieces_auto_produits.json");
  if (!fs.existsSync(file)) {
    console.error(`[!] Fichier introuvable : ${file}`);
    process.exit(1);
  }

  const raw = JSON.parse(fs.readFileSync(file, "utf-8"));
  console.log(`[*] ${raw.length} produits dans le fichier.`);

  const client = await pool.connect();
  let imported = 0, skipped = 0, priceZero = 0;

  try {
    for (const p of raw) {
      const slug = slugFromUrl(p.url) || slugify(p.titre || "");
      if (!slug || !p.titre) { skipped++; continue; }

      const priceCents = Math.round((p.prix_numerique || 0) * 100);
      if (priceCents === 0) priceZero++;

      await client.query("BEGIN");
      try {
        const res = await client.query(
          `INSERT INTO products
             (slug, title, reference, brand, price_cents, short_desc, long_desc, features, source_url)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
           ON CONFLICT (slug) DO UPDATE SET
             title = EXCLUDED.title,
             reference = EXCLUDED.reference,
             brand = EXCLUDED.brand,
             short_desc = EXCLUDED.short_desc,
             long_desc = EXCLUDED.long_desc,
             features = EXCLUDED.features,
             source_url = EXCLUDED.source_url,
             updated_at = now()
           RETURNING id`,
          [
            slug,
            p.titre.trim(),
            p.reference || null,
            p.marque || null,
            priceCents,
            p.description_courte || null,
            p.description_longue || null,
            JSON.stringify(cleanFeatures(p.caracteristiques)),
            p.url,
          ]
        );
        const productId = res.rows[0].id;

        // Images (on remplace à chaque import)
        await client.query("DELETE FROM product_images WHERE product_id = $1", [productId]);
        const images = cleanImages(p.images);
        for (let i = 0; i < images.length; i++) {
          await client.query(
            "INSERT INTO product_images (product_id, url, position) VALUES ($1,$2,$3)",
            [productId, images[i], i]
          );
        }

        // Catégories
        await client.query("DELETE FROM product_categories WHERE product_id = $1", [productId]);
        for (const catName of cleanCategories(p.categories)) {
          const catId = await upsertCategory(client, catName.trim());
          await client.query(
            `INSERT INTO product_categories (product_id, category_id)
             VALUES ($1,$2) ON CONFLICT DO NOTHING`,
            [productId, catId]
          );
        }

        await client.query("COMMIT");
        imported++;
      } catch (err) {
        await client.query("ROLLBACK");
        console.error(`  [!] Échec pour ${slug}: ${err.message}`);
        skipped++;
      }
    }
  } finally {
    client.release();
    await pool.end();
  }

  console.log(`\n[✓] Import terminé : ${imported} produits importés, ${skipped} ignorés.`);
  if (priceZero) {
    console.log(`[!] ${priceZero} produits ont un prix à 0 € (le site source masquait les prix).`);
    console.log(`    Ils s'afficheront en "Prix sur demande" sur la vitrine.`);
    console.log(`    Pour fixer un prix :  UPDATE products SET price_cents = 1990 WHERE reference = 'XXXX';`);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
