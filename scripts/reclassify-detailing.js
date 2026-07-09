// scripts/reclassify-detailing.js
//
// Reclasse les produits importés depuis fresh.aateile.com (actuellement tous
// dans la seule catégorie "Accessoires") vers de vrais rayons déduits du titre.
//
//   1. Crée les rayons manquants dans `categories`.
//   2. Pour chaque produit lié à "Accessoires" : détermine son rayon, retire le
//      lien "Accessoires", ajoute le lien vers le bon rayon.
//   3. Supprime "Accessoires" si elle devient vide.
//
// Réexécutable. Usage :
//   export DATABASE_URL="postgresql://user:pass@host:port/railway"
//   node scripts/reclassify-detailing.js          (applique)
//   node scripts/reclassify-detailing.js --dry     (aperçu sans écrire)

const { Client } = require("pg");

const DRY = process.argv.includes("--dry");
const SOURCE_CATEGORY_SLUG = "accessoires";

function slugify(name) {
  return name.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()
    .replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

const RULES = [
  ["Kits & Coffrets", /\bkit\b|coffret|\bpack\b|\bbox\b/i],
  ["Parfums & Désodorisants", /parfum|senteur|désodor|desodor|odeur|insenti|ambiance|arbre magique/i],
  ["Nettoyants jantes", /jante/i],
  ["Pneus (nettoyant & dressing)", /pneu/i],
  ["Nettoyants vitres", /vitre|pare.?brise|lave.?glace|raclette/i],
  ["Cockpit & Tableau de bord", /cockpit|tableau de bord/i],
  ["Cuir & Alcantara", /cuir|alcantara|conditioner/i],
  ["Textiles & Tapis", /textile|tissu|tapis|moquette/i],
  ["Préparation & Décontamination", /décontamin|decontamin|ferreux|\biron\b|argile|\bclay\b|détartr|detartr|goudron|colle|\bipa\b|dégraiss|degraiss|alcool|film routier|préparation|preparation/i],
  ["Dégivrants & Antigel", /dégiv|degiv|antigel|givre/i],
  ["Insectes", /insecte|moucheron/i],
  ["Polish & Lustrage", /polish|lustr|\bpate\b|\bpâte\b|correction|panneau/i],
  ["Cires & Protections", /\bcire\b|\bwax\b|céramique|ceramique|scellant|sealant|protection|hydrophobe/i],
  ["Quick Detailers", /quick detailer|detailer|spray brillance/i],
  ["Shampoings & Mousses", /shampo?ing|shampooing|snow|mousse/i],
  ["Plastiques & Dressing", /plastique|dressing|rénov|renov|brillant|pare.?chocs/i],
  ["Multi-usages (APC)", /\bapc\b|multi.?usage|tout usage|nettoyant tout|hardcore/i],
  ["Microfibres & Applicateurs", /microfibre|serviette|applicateur|tampon|\bpad\b|éponge|eponge|\bgant\b|mitaine|séparateur|separateur|toile/i],
  ["Seaux & Matériel de lavage", /seau|brosse|pinceau|pulvéris|pulveris|bouteille|bidon|bec verseur|pistolet|flacon|plateau|wrapper|grille|distributeur|vaporisat/i],
  ["Outillage & Divers", /clé|cle |grattoir|adhésif|adhesif|molette|cruciforme|outil/i],
];
const FALLBACK = "Produits d'entretien divers";
function classify(title) { for (const [name, re] of RULES) if (re.test(title)) return name; return FALLBACK; }

const client = process.env.DATABASE_URL
  ? new Client({ connectionString: process.env.DATABASE_URL,
      ssl: /railway|rlwy\.net/.test(process.env.DATABASE_URL) ? { rejectUnauthorized: false } : undefined })
  : new Client({ host: process.env.PGHOST || "localhost", port: process.env.PGPORT || 5432,
      database: process.env.PGDATABASE || "piecesauto", user: process.env.PGUSER || "postgres",
      password: process.env.PGPASSWORD || "postgres" });

async function main() {
  await client.connect();
  const src = await client.query(`SELECT id FROM categories WHERE slug = $1`, [SOURCE_CATEGORY_SLUG]);
  if (!src.rows.length) { console.error(`Catégorie "${SOURCE_CATEGORY_SLUG}" introuvable.`); await client.end(); return; }
  const sourceId = src.rows[0].id;

  const prods = await client.query(
    `SELECT p.id, p.title FROM products p
     JOIN product_categories pc ON pc.product_id = p.id
     WHERE pc.category_id = $1 ORDER BY p.id`, [sourceId]);
  console.log(`${prods.rows.length} produits à reclasser${DRY ? " (DRY RUN)" : ""}.`);

  const byCat = new Map();
  for (const p of prods.rows) {
    const cat = classify(p.title);
    if (!byCat.has(cat)) byCat.set(cat, []);
    byCat.get(cat).push(p.id);
  }
  console.log(`\nRépartition prévue (${byCat.size} rayons) :`);
  [...byCat.entries()].sort((a, b) => b[1].length - a[1].length)
    .forEach(([name, ids]) => console.log(`  ${String(ids.length).padStart(4)}  ${name}`));

  if (DRY) { console.log("\nDRY RUN — aucune écriture."); await client.end(); return; }

  await client.query("BEGIN");
  try {
    const catId = new Map();
    for (const name of byCat.keys()) {
      const r = await client.query(
        `INSERT INTO categories (name, slug) VALUES ($1, $2)
         ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id`,
        [name, slugify(name)]);
      catId.set(name, r.rows[0].id);
    }
    let moved = 0;
    for (const [name, ids] of byCat.entries()) {
      const targetId = catId.get(name);
      for (let i = 0; i < ids.length; i += 200) {
        const chunk = ids.slice(i, i + 200);
        const params = [];
        const values = chunk.map((pid) => { params.push(pid, targetId);
          return `($${params.length - 1}::int, $${params.length}::int)`; }).join(",");
        await client.query(
          `INSERT INTO product_categories (product_id, category_id) VALUES ${values} ON CONFLICT DO NOTHING`, params);
        moved += chunk.length;
      }
    }
    const allIds = prods.rows.map((p) => p.id);
    await client.query(
      `DELETE FROM product_categories WHERE category_id = $1 AND product_id = ANY($2::int[])`, [sourceId, allIds]);
    const remaining = await client.query(
      `SELECT COUNT(*)::int AS n FROM product_categories WHERE category_id = $1`, [sourceId]);
    let deletedSource = false;
    if (remaining.rows[0].n === 0) {
      await client.query(`DELETE FROM categories WHERE id = $1`, [sourceId]); deletedSource = true;
    }
    await client.query("COMMIT");
    console.log(`\nOK — ${moved} affectations créées, ${allIds.length} liens "Accessoires" retirés.`);
    console.log(deletedSource ? 'Catégorie "Accessoires" supprimée (vide).' : 'Catégorie "Accessoires" conservée.');
  } catch (e) {
    await client.query("ROLLBACK");
    console.error("Échec, transaction annulée :", e.message);
  }
  await client.end();
}
main().catch((e) => { console.error("Erreur fatale :", e); process.exit(1); });