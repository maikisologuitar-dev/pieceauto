// scripts/backfill-brands.js
//
// Renseigne une marque commerciale exploitable dans products.brand, à partir
// du titre (les deux sources ont des conventions différentes) :
//   - Anciens produits (pieces-auto.fr) : marque en SUFFIXE après " – "
//       ex. "Antigel gazole – Bardahl"  ->  Bardahl
//   - Nouveaux produits (fresh.aateile) : marque connue en PRÉFIXE / dans le titre
//       ex. "BadBoys Nettoyant vitres 1L" -> BadBoys
//       accessoires génériques (brosses, seaux…) -> "RR Customs"
//
// Réexécutable sans risque (simple UPDATE calculé). N'écrase QUE brand.
//
// Usage :
//   export DATABASE_URL="postgresql://user:pass@host:port/railway"
//   node scripts/backfill-brands.js
//   node scripts/backfill-brands.js --dry   (aperçu sans écrire)

const { Client } = require("pg");

const DRY = process.argv.includes("--dry");

// Marques commerciales reconnues (recherche insensible à la casse, mot entier
// ou début de titre). L'ordre compte : les plus spécifiques d'abord.
const KNOWN_BRANDS = [
  "BadBoys",
  "GTools",
  "Moje Auto",
  "Moje",
  "Eurodet",
  "Finixa",
  "Maxgear",
  "Bardahl",
  "GS27",
  "Stilker",
  "Sumex",
  "Restagraf",
  "Holts",
  "Rain-X",
  "Schumacher",
  "Sodise",
  "Drakkar",
  "Planetline",
  "Impex",
  "Diframa",
  "K2",
];

// Normalisations d'affichage (corrige les fautes de la source, unifie)
const NORMALIZE = {
  Moje: "Moje Auto",
  Bardhal: "Bardahl", // faute fréquente côté source
};

// Vendeur -> marque de repli quand rien n'est détecté dans le titre
const VENDOR_FALLBACK = {
  "RR CUSTOMS": "RR Customs",
  "MOJE AUTO": "Moje Auto",
  EURODET: "Eurodet",
  SUFF: "Suff",
  FINIXA: "Finixa",
  K2: "K2",
  MAXGEAR: "Maxgear",
};

function deriveBrand(title, vendor) {
  const t = (title || "").trim();
  const low = t.toLowerCase();

  // 1) Marque connue reconnue dans le titre (préfixe ou mot entier) : prioritaire.
  //    Évite qu'un suffixe de parfum ("… – Bubble Gum") masque la vraie marque
  //    ("Moje Auto … – Bubble Gum" -> Moje Auto).
  for (const b of KNOWN_BRANDS) {
    const bl = b.toLowerCase();
    if (low.startsWith(bl) || new RegExp(`\\b${bl.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\b`).test(low)) {
      return NORMALIZE[b] || b;
    }
  }

  // 2) Sinon, suffixe après un tiret (– — -) : convention des anciens produits
  const parts = t.split(/\s[–—-]\s/);
  if (parts.length >= 2) {
    const suffix = parts[parts.length - 1].trim();
    // suffixe court et sans chiffres = probablement une marque
    if (suffix && suffix.length <= 20 && !/\d/.test(suffix)) {
      return NORMALIZE[suffix] || suffix;
    }
  }

  // 3) Repli sur le vendeur
  if (vendor && VENDOR_FALLBACK[vendor]) return VENDOR_FALLBACK[vendor];

  return null;
}

const client = process.env.DATABASE_URL
  ? new Client({
      connectionString: process.env.DATABASE_URL,
      ssl: /railway|rlwy\.net/.test(process.env.DATABASE_URL) ? { rejectUnauthorized: false } : undefined,
    })
  : new Client({
      host: process.env.PGHOST || "localhost",
      port: process.env.PGPORT || 5432,
      database: process.env.PGDATABASE || "piecesauto",
      user: process.env.PGUSER || "postgres",
      password: process.env.PGPASSWORD || "postgres",
    });

async function main() {
  await client.connect();

  // On lit title + brand actuel (qui contient le vendeur pour les nouveaux)
  const { rows } = await client.query(
    `SELECT id, title, brand AS current_brand FROM products ORDER BY id`
  );
  console.log(`${rows.length} produits à traiter${DRY ? " (DRY RUN)" : ""}.`);

  const updates = [];
  for (const r of rows) {
    // current_brand contient le vendeur d'origine pour les produits importés
    const derived = deriveBrand(r.title, r.current_brand);
    if (derived && derived !== r.current_brand) {
      updates.push({ id: r.id, brand: derived });
    }
  }

  console.log(`${updates.length} marques à (ré)affecter.`);

  // Aperçu de la répartition finale
  const finalBrands = {};
  for (const r of rows) {
    const u = updates.find((x) => x.id === r.id);
    const b = u ? u.brand : r.current_brand;
    finalBrands[b || "(sans marque)"] = (finalBrands[b || "(sans marque)"] || 0) + 1;
  }
  console.log("Répartition finale des marques :");
  Object.entries(finalBrands)
    .sort((a, b) => b[1] - a[1])
    .forEach(([b, n]) => console.log(`  ${String(n).padStart(4)}  ${b}`));

  if (DRY) {
    console.log("\nDRY RUN — aucune écriture. Relance sans --dry pour appliquer.");
    await client.end();
    return;
  }

  // Application par lots dans une transaction, via UPDATE ... FROM (VALUES ...)
  const BATCH = 200;
  await client.query("BEGIN");
  try {
    for (let i = 0; i < updates.length; i += BATCH) {
      const chunk = updates.slice(i, i + BATCH);
      const params = [];
      const values = chunk
        .map((u) => {
          params.push(u.id, u.brand);
          return `($${params.length - 1}::int, $${params.length}::text)`;
        })
        .join(",");
      await client.query(
        `UPDATE products AS p SET brand = v.brand
         FROM (VALUES ${values}) AS v(id, brand)
         WHERE p.id = v.id`,
        params
      );
    }
    await client.query("COMMIT");
    console.log(`\nOK — ${updates.length} marques mises à jour.`);
  } catch (e) {
    await client.query("ROLLBACK");
    console.error("Échec, transaction annulée :", e.message);
  }

  await client.end();
}

main().catch((e) => {
  console.error("Erreur fatale :", e);
  process.exit(1);
});