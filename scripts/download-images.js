#!/usr/bin/env node
/**
 * download-images.js — Télécharge en local les images produits stockées en base
 * (URLs distantes pieces-auto.fr) pour ne plus dépendre du site source et
 * contourner sa protection anti-hotlink / rate-limiting.
 *
 * - Envoie un Referer du site source (satisfait l'anti-hotlink).
 * - Attend une pause entre chaque image (évite le rate-limit qui renvoie 403).
 * - Enregistre dans web/public/media/<product_id>/<position>.<ext>
 * - Met à jour product_images.url vers le chemin local /media/...
 * - Réexécutable : saute les images déjà téléchargées. NE PAS interrompre
 *   en cours de route avec Ctrl+C — laissez-le aller jusqu'au bout, puis
 *   relancez-le si besoin pour ne retenter que les échecs.
 *
 * Usage (depuis la racine du projet) :
 *    PGPASSWORD='...' node scripts/download-images.js
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

const PUBLIC_DIR = path.join(__dirname, "..", "web", "public", "media");
const REFERER = "https://pieces-auto.fr/";
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36";

// Pause entre CHAQUE image (succès ou non) pour ne pas déclencher le
// rate-limit anti-hotlink du site source. Réglable via DOWNLOAD_DELAY_MS.
const DELAY_MS = Number(process.env.DOWNLOAD_DELAY_MS || 1200);

function extFromUrl(url) {
  const m = url.split("?")[0].match(/\.(jpg|jpeg|png|webp|gif)$/i);
  return m ? m[1].toLowerCase() : "jpg";
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function downloadOne(url, destPath, retries = 4) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const res = await fetch(url, {
        headers: {
          "User-Agent": USER_AGENT,
          Referer: REFERER,
          Accept: "image/avif,image/webp,image/png,image/*,*/*;q=0.8",
        },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const buf = Buffer.from(await res.arrayBuffer());
      if (buf.length < 100) throw new Error("fichier vide/trop petit");
      fs.writeFileSync(destPath, buf);
      return true;
    } catch (err) {
      if (attempt === retries) {
        console.error(`    [!] Échec ${url} : ${err.message}`);
        return false;
      }
      // Backoff progressif : 3s, 6s, 9s — laisse le temps au rate-limit de se calmer
      await sleep(3000 * attempt);
    }
  }
}

async function main() {
  const client = await pool.connect();
  let ok = 0, skipped = 0, failed = 0;

  try {
    const { rows } = await client.query(
      `SELECT id, product_id, url, position
       FROM product_images
       ORDER BY product_id, position`
    );
    console.log(`[*] ${rows.length} images à traiter (pause de ${DELAY_MS}ms entre chaque).\n`);
    console.log(`[!] Laissez ce script tourner jusqu'au bout sans Ctrl+C.`);
    console.log(`    Il reprend automatiquement au prochain lancement si interrompu.\n`);

    let idx = 0;
    for (const img of rows) {
      idx++;
      // Déjà local ? on saute, pas de pause nécessaire.
      if (img.url.startsWith("/media/")) { skipped++; continue; }

      const dir = path.join(PUBLIC_DIR, String(img.product_id));
      fs.mkdirSync(dir, { recursive: true });

      const ext = extFromUrl(img.url);
      const fileName = `${img.position}.${ext}`;
      const destPath = path.join(dir, fileName);
      const localUrl = `/media/${img.product_id}/${fileName}`;

      // Fichier déjà présent sur le disque ? on met juste à jour la base, pas de pause.
      if (fs.existsSync(destPath) && fs.statSync(destPath).size > 100) {
        await client.query("UPDATE product_images SET url = $1 WHERE id = $2", [localUrl, img.id]);
        skipped++;
        continue;
      }

      process.stdout.write(`  [${idx}/${rows.length}] produit ${img.product_id} img ${img.position}… `);
      const success = await downloadOne(img.url, destPath);
      if (success) {
        await client.query("UPDATE product_images SET url = $1 WHERE id = $2", [localUrl, img.id]);
        console.log("✓");
        ok++;
      } else {
        failed++;
      }
      await sleep(DELAY_MS);
    }
  } finally {
    client.release();
    await pool.end();
  }

  console.log(`\n[✓] Terminé : ${ok} téléchargées, ${skipped} déjà présentes, ${failed} échecs.`);
  if (failed) {
    console.log(`[!] Relancez simplement la même commande pour ne retenter que les échecs.`);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });