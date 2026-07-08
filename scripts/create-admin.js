#!/usr/bin/env node
/**
 * create-admin.js — Crée (ou met à jour) un compte administrateur.
 * Hash du mot de passe en PBKDF2 (module crypto natif, aucune dépendance).
 *
 * Usage :
 *    PGPASSWORD='...' node scripts/create-admin.js <email> <motdepasse> ["Nom Prénom"]
 *
 * Exemple :
 *    PGPASSWORD='Mot2passe&' node scripts/create-admin.js admin@piecesauto.fr MonPass123 "Ulrich"
 */

const crypto = require("crypto");
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.PGHOST || "localhost",
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE || "piecesauto",
  user: process.env.PGUSER || "postgres",
  password: process.env.PGPASSWORD || "postgres",
});

function hashPassword(password, salt) {
  return crypto.pbkdf2Sync(password, salt, 120000, 64, "sha512").toString("hex");
}

async function main() {
  const [email, password, name] = process.argv.slice(2);
  if (!email || !password) {
    console.error('Usage : node scripts/create-admin.js <email> <motdepasse> ["Nom"]');
    process.exit(1);
  }
  if (password.length < 6) {
    console.error("[!] Mot de passe trop court (6 caractères minimum).");
    process.exit(1);
  }

  const salt = crypto.randomBytes(16).toString("hex");
  const hash = hashPassword(password, salt);

  const client = await pool.connect();
  try {
    await client.query(
      `INSERT INTO admin_users (email, password_hash, password_salt, name)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (email) DO UPDATE SET
         password_hash = EXCLUDED.password_hash,
         password_salt = EXCLUDED.password_salt,
         name = EXCLUDED.name`,
      [email.toLowerCase(), hash, salt, name || null]
    );
    console.log(`[✓] Compte admin créé/mis à jour : ${email}`);
    console.log(`    Connectez-vous sur http://localhost:3000/admin/login`);
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
