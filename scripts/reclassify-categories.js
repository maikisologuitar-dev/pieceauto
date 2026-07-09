#!/usr/bin/env node
/**
 * reclassify-categories.js — Nettoie et reconstruit les rayons.
 *
 * Le scraping avait rattaché chaque produit à des "catégories" parasites
 * (éléments de menu), toutes avec ~259 produits. Ce script :
 *   1. Vide les tables categories + product_categories.
 *   2. Recrée des RAYONS MÉTIER propres (Freinage, Huiles, Nettoyage…).
 *   3. Classe chaque produit selon des mots-clés trouvés dans son titre.
 *   4. Un produit non reconnu va dans "Autres accessoires".
 *
 * Réexécutable sans risque (il repart de zéro à chaque fois).
 *
 * Usage :
 *   DATABASE_URL='postgresql://...' node scripts/reclassify-categories.js
 */

const { Pool } = require("pg");

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

function slugify(s) {
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

// Rayons métier + mots-clés (recherchés dans le titre, minuscules sans accents).
// Ordre = priorité : le premier rayon qui matche gagne.
const RAYONS = [
  { name: "Freinage", kw: ["frein", "plaquette", "disque de frein", "machoire", "etrier", "piston de frein"] },
  { name: "Huiles moteur", kw: ["huile xt", "huile boite", "huile moteur", "10w", "5w", "0w", "15w", "75w", "85w"] },
  { name: "Additifs & Traitements", kw: ["additif", "traitement", "nettoyant injecteur", "decrassant", "stop fuite", "stop-fuite", "anti", "octane", "cetane", "adblue", "bardahl", "demarrage moteur", "substitut"] },
  { name: "Nettoyage & Entretien", kw: ["nettoyant", "shampoing", "shampooing", "lustr", "polish", "renovateur", "cire", "microfibre", "eponge", "gant", "lingette", "brosse", "detachant", "baume", "soin", "impermeabilis", "deocar", "parfum", "assainiss", "purifiant", "gs27"] },
  { name: "Graisses & Lubrifiants", kw: ["graisse", "lubrifiant", "degrippant", "silicone", "burette"] },
  { name: "Filtration", kw: ["filtre"] },
  { name: "Batteries & Démarrage", kw: ["batterie", "booster", "chargeur", "demarr", "cable", "alternateur", "bobine", "bougie", "faisceau", "testeur de batterie"] },
  { name: "Pneus & Neige", kw: ["pneu", "chaine neige", "chaussette", "sel de deneigement", "degivrant", "degivr"] },
  { name: "Outillage", kw: ["cric", "servante", "douille", "cle dynamo", "coffret", "mallette", "rampe", "enrouleur", "repousse piston", "vidange", "kit de vidange", "tendeur", "baladeuse", "boite de fusibles", "outil"] },
  { name: "Attelage & Remorque", kw: ["attelage", "remorque", "antivol remorque", "prise d"] },
  { name: "Collage & Réparation", kw: ["glue", "colle", "mastic", "pate a reparer", "epoxy", "joint silicone", "double face", "repare crevaison", "reparation"] },
  { name: "Vitres & Pare-brise", kw: ["pare-brise", "pare brise", "anti-pluie", "anti pluie", "anti-buee", "rain-x", "vitres", "essuie", "bache"] },
  { name: "Sécurité & Signalisation", kw: ["gilet", "triangle", "signalisation", "haute visibilite"] },
  { name: "Direction & Suspension", kw: ["amortisseur", "direction", "suspension", "rotule", "biellette", "roulement"] },
  { name: "Transmission & Embrayage", kw: ["embrayage", "transmission", "cardan", "distribution", "courroie", "kit de distribution"] },
  { name: "Échappement", kw: ["echappement", "silencieux", "pot ", "catalyseur", "sangle"] },
  { name: "Carrosserie", kw: ["carrosserie", "pare-choc", "pare choc", "retroviseur", "optique", "phare", "teinteur"] },
  { name: "Répulsifs & Divers", kw: ["martre", "rongeur", "repulsif", "stop&go", "stop & go", "humidite", "tapis"] },
];

const norm = (s) => (s || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

function rayonFor(title) {
  const t = norm(title);
  for (const r of RAYONS) {
    if (r.kw.some((k) => t.includes(norm(k)))) return r.name;
  }
  return "Autres accessoires";
}

async function main() {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // 1. Repartir de zéro
    await client.query("DELETE FROM product_categories");
    await client.query("DELETE FROM categories");

    // 2. Créer les rayons (+ le fourre-tout)
    const allNames = [...RAYONS.map((r) => r.name), "Autres accessoires"];
    const idByName = {};
    for (const name of allNames) {
      const r = await client.query(
        "INSERT INTO categories (name, slug) VALUES ($1,$2) RETURNING id",
        [name, slugify(name)]
      );
      idByName[name] = r.rows[0].id;
    }

    // 3. Classer chaque produit
    const prods = (await client.query("SELECT id, title FROM products")).rows;
    const counts = {};
    for (const p of prods) {
      const rayon = rayonFor(p.title);
      counts[rayon] = (counts[rayon] || 0) + 1;
      await client.query(
        "INSERT INTO product_categories (product_id, category_id) VALUES ($1,$2) ON CONFLICT DO NOTHING",
        [p.id, idByName[rayon]]
      );
    }

    // 4. Supprimer les rayons restés vides
    await client.query(`
      DELETE FROM categories c
      WHERE NOT EXISTS (SELECT 1 FROM product_categories pc WHERE pc.category_id = c.id)
    `);

    await client.query("COMMIT");

    console.log("[✓] Reclassification terminée.\n");
    console.log("Répartition par rayon :");
    Object.entries(counts).sort((a, b) => b[1] - a[1])
      .forEach(([name, n]) => console.log(`  ${String(n).padStart(4)}  ${name}`));
  } catch (e) {
    await client.query("ROLLBACK");
    console.error("[!] Erreur, annulé :", e.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
