#!/usr/bin/env node
/**
 * upload-cloudinary.js — Envoie les images locales (web/public/media/) vers
 * Cloudinary et met à jour product_images.url avec les URLs Cloudinary.
 *
 * IMPORTANT : ce script écrit dans la base pointée par DATABASE_URL.
 * Pour la production, mettez l'URL Railway :
 *
 *   CLOUDINARY_CLOUD_NAME=jewjfeup
 *   CLOUDINARY_API_KEY=482597444985228
 *   CLOUDINARY_API_SECRET=iRKHaoN1HprLbgH7TGwv-l2q4U4
 *   DATABASE_URL='postgresql://postgres:JYIucHENsytxkjTmohsajeGZrPhXgepU@hayabusa.proxy.rlwy.net:47097/railway' \
 *   node scripts/upload-cloudinary.js
 *
 * - Réexécutable : saute les images déjà sur Cloudinary (url commençant par http et contenant 'cloudinary').
 * - Idempotent : réutilise un public_id stable (media/<product_id>/<position>),
 *   donc relancer ne crée pas de doublons.
 *
 * Prérequis :  npm install cloudinary pg   (dans le dossier du projet ou racine)
 */

const fs = require("fs");
const path = require("path");
const { Pool } = require("pg");
const cloudinary = require("cloudinary").v2;

// --- Connexion base : priorité à DATABASE_URL (Railway), sinon locale ---
const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } }
    : {
        host: process.env.PGHOST || "localhost",
        port: Number(process.env.PGPORT || 5432),
        database: process.env.PGDATABASE || "piecesauto",
        user: process.env.PGUSER || "postgres",
        password: process.env.PGPASSWORD || "postgres",
      }
);

// --- Config Cloudinary ---
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

const MEDIA_DIR = path.join(__dirname, "..", "web", "public", "media");
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function checkConfig() {
  const missing = [];
  if (!process.env.CLOUDINARY_CLOUD_NAME) missing.push("CLOUDINARY_CLOUD_NAME");
  if (!process.env.CLOUDINARY_API_KEY) missing.push("CLOUDINARY_API_KEY");
  if (!process.env.CLOUDINARY_API_SECRET) missing.push("CLOUDINARY_API_SECRET");
  if (missing.length) {
    console.error(`[!] Variables manquantes : ${missing.join(", ")}`);
    process.exit(1);
  }
}

async function main() {
  checkConfig();

  const client = await pool.connect();
  let rows;
  try {
    rows = (await client.query(
      "SELECT id, product_id, url, position FROM product_images ORDER BY product_id, position"
    )).rows;
  } finally {
    client.release();
  }

  console.log(`[*] ${rows.length} images à traiter.\n`);
  let uploaded = 0, skipped = 0, missing = 0, failed = 0;

  for (let i = 0; i < rows.length; i++) {
    const img = rows[i];

    // Déjà sur Cloudinary ? on saute.
    if (/^https?:\/\/.*cloudinary/.test(img.url)) { skipped++; continue; }

    // Retrouve le fichier local. L'URL en base est du type /media/<pid>/<pos>.<ext>
    const rel = img.url.replace(/^\/media\//, "");
    const localPath = path.join(MEDIA_DIR, rel);

    if (!fs.existsSync(localPath)) {
      console.log(`  [${i + 1}/${rows.length}] fichier absent : ${img.url} — ignoré`);
      missing++;
      continue;
    }

    const publicId = `media/${img.product_id}/${img.position}`;
    process.stdout.write(`  [${i + 1}/${rows.length}] produit ${img.product_id} img ${img.position}… `);

    try {
      const res = await cloudinary.uploader.upload(localPath, {
        public_id: publicId,
        overwrite: true,
        resource_type: "image",
      });
      const client2 = await pool.connect();
      try {
        await client2.query("UPDATE product_images SET url = $1 WHERE id = $2", [res.secure_url, img.id]);
      } finally {
        client2.release();
      }
      console.log("✓");
      uploaded++;
    } catch (err) {
      console.log(`✗ ${err.message}`);
      failed++;
    }
    await sleep(150);
  }

  await pool.end();
  console.log(`\n[✓] Terminé : ${uploaded} envoyées, ${skipped} déjà sur Cloudinary, ${missing} fichiers absents, ${failed} échecs.`);
  if (failed) console.log(`[!] Relancez la même commande pour ne retenter que les échecs.`);
}

main().catch((e) => { console.error(e); process.exit(1); });
