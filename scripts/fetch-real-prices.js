#!/usr/bin/env node
/**
 * fetch-real-prices.js — Re-visite chaque fiche produit pour récupérer le
 * VRAI prix (le premier scraping avait capté par erreur le prix du mini-panier
 * vide "0,00€" affiché en haut de page, au lieu du prix produit affiché plus
 * bas dans la fiche).
 *
 * Stratégie d'extraction : on exclut explicitement tout élément ".price" situé
 * dans le panier (header/mini-cart), les produits associés, ou tout bloc
 * "related/upsell", et on ne garde que celui de la zone résumé produit
 * (.summary / .entry-summary / form.cart).
 *
 * - Sauvegarde progressive (reprise si interrompu).
 * - Pause entre requêtes pour éviter le rate-limit (403).
 * - Réexécutable : ne retraite pas les produits déjà à prix > 0 (sauf --force).
 *
 * Usage :
 *    PGPASSWORD='...' node scripts/fetch-real-prices.js
 *    PGPASSWORD='...' node scripts/fetch-real-prices.js --force   (retraite tout)
 */

const { chromium } = require("playwright");
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.PGHOST || "localhost",
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE || "piecesauto",
  user: process.env.PGUSER || "postgres",
  password: process.env.PGPASSWORD || "postgres",
});

const DELAY_MS = Number(process.env.FETCH_PRICE_DELAY_MS || 1500);
const FORCE = process.argv.includes("--force");
const LIMIT = Number(process.env.LIMIT || 0); // 0 = tous, sinon limite pour tests rapides
const DEBUG = process.argv.includes("--debug") || process.env.DEBUG === "1";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Fonction exécutée DANS la page pour extraire le bon prix, en excluant
// panier / header / produits associés / upsells.
// Fonction exécutée DANS la page pour extraire le prix produit.
// (Passée comme vraie fonction à page.evaluate, pas comme string.)
function extractPriceInPage() {
  const SELECTORS = [
    '.summary .price',
    '.entry-summary .price',
    'p.price',
    '.product-info .price',
    'div[itemprop="offers"] .price',
    '.woocommerce-Price-amount',
  ];

  const results = {};
  for (const sel of SELECTORS) {
    const el = document.querySelector(sel);
    if (el) results[sel] = el.innerText.trim();
  }

  const allPrices = Array.from(document.querySelectorAll('.price, .woocommerce-Price-amount'))
    .slice(0, 8)
    .map((el) => ({
      text: el.innerText.trim().slice(0, 40),
      parentClass: String(el.parentElement ? el.parentElement.className : '').slice(0, 60),
    }));

  let chosen = null;
  for (const sel of SELECTORS) {
    if (results[sel] && /[1-9]/.test(results[sel])) { chosen = results[sel]; break; }
  }

  return { chosen, results, allPrices, title: document.title };
}

function parsePriceText(text) {
  if (!text) return null;
  // Cas "12,50€" ou "12.50 €" ou avec un prix barré suivi du prix promo :
  // on prend le DERNIER nombre trouvé (souvent le prix actuel après le prix barré)
  const matches = [...text.matchAll(/(\d[\d\s.,]*\d|\d)\s*€/g)];
  if (!matches.length) return null;
  const raw = matches[matches.length - 1][1];
  const cleaned = raw.replace(/\s/g, "").replace(",", ".");
  const n = Number(cleaned);
  if (Number.isNaN(n) || n <= 0) return null;
  return Math.round(n * 100);
}

async function main() {
  const client = await pool.connect();
  let rows;
  try {
    const where = FORCE ? "" : "WHERE price_cents = 0";
    const r = await client.query(
      `SELECT id, slug, title, reference, source_url FROM products ${where} ORDER BY id`
    );
    rows = r.rows;
  } finally {
    client.release();
  }

  if (!rows.length) {
    console.log("[*] Aucun produit à traiter (tous ont déjà un prix > 0). Utilisez --force pour retout retraiter.");
    await pool.end();
    return;
  }

  if (LIMIT > 0) rows = rows.slice(0, LIMIT);

  console.log(`[*] ${rows.length} produits à traiter (pause de ${DELAY_MS}ms entre chaque).`);
  console.log(`[!] Laissez tourner jusqu'au bout sans Ctrl+C — reprend automatiquement sinon.\n`);

  let browser;
  try {
    browser = await chromium.launch({ headless: true, channel: "chrome" });
  } catch (err) {
    console.log(`[!] Lancement de Chrome échoué (${err.message.split("\n")[0]}), repli sur Chromium.`);
    browser = await chromium.launch({ headless: true });
  }
  const context = await browser.newContext({
    locale: "fr-FR",
    userAgent:
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
      "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
  });
  const page = await context.newPage();

  // Warm-up : visite de la page d'accueil pour obtenir les cookies de session
  // (le site a une protection anti-bot qui bloque sinon les visites directes).
  console.log("[*] Initialisation de la session (visite de la page d'accueil)...");
  try {
    await page.goto("https://pieces-auto.fr/", { timeout: 45000, waitUntil: "domcontentloaded" });
    await page.waitForTimeout(3000);
    console.log("    -> session initialisée.\n");
  } catch (err) {
    console.log(`    [!] Warm-up échoué (${err.message}), on continue quand même.\n`);
  }

  let updated = 0, notFound = 0, failed = 0;

  for (let i = 0; i < rows.length; i++) {
    const p = rows[i];
    if (!p.source_url) { notFound++; continue; }

    process.stdout.write(`  [${i + 1}/${rows.length}] ${p.title.slice(0, 50)}… `);

    let success = false;
    for (let attempt = 1; attempt <= 3 && !success; attempt++) {
      try {
        const resp = await page.goto(p.source_url, { timeout: 45000, waitUntil: "domcontentloaded" });
        if (resp && resp.status() === 403) throw new Error("HTTP 403");

        // Attend l'apparition du prix produit (max 15s), sans échouer si absent.
        try {
          await page.waitForSelector(".summary .price, p.price, .woocommerce-Price-amount", { timeout: 15000 });
        } catch {}
        await page.waitForTimeout(1200);

        const result = await page.evaluate(extractPriceInPage);
        const cents = parsePriceText(result && result.chosen);

        if (cents) {
          const client2 = await pool.connect();
          try {
            await client2.query(
              "UPDATE products SET price_cents = $1, updated_at = now() WHERE id = $2",
              [cents, p.id]
            );
          } finally {
            client2.release();
          }
          console.log(`✓ ${(cents / 100).toFixed(2)} €`);
          updated++;
        } else {
          console.log(`— prix introuvable`);
          if (DEBUG) {
            console.log(`      title: ${JSON.stringify(result && result.title)}`);
            console.log(`      sélecteurs testés: ${JSON.stringify(result && result.results)}`);
            console.log(`      tous les .price: ${JSON.stringify(result && result.allPrices)}`);
          }
          notFound++;
        }
        success = true;
      } catch (err) {
        if (attempt === 3) {
          console.log(`✗ échec (${err.message})`);
          failed++;
        } else {
          await sleep(3000 * attempt);
        }
      }
    }
    await sleep(DELAY_MS);
  }

  await browser.close();
  await pool.end();

  console.log(`\n[✓] Terminé : ${updated} prix récupérés, ${notFound} introuvables, ${failed} échecs réseau.`);
  if (notFound || failed) {
    console.log(`[!] Relancez la même commande pour ne retenter que les produits encore à 0 €.`);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });