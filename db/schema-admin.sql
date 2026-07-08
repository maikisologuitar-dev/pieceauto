-- ============================================================
-- PiècesAuto — Extension : back-office admin
-- À exécuter APRÈS db/schema.sql :
--   sudo -u postgres psql -d piecesauto -f db/schema-admin.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS admin_users (
  id            SERIAL PRIMARY KEY,
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,          -- hash PBKDF2 (voir scripts/create-admin.js)
  password_salt TEXT NOT NULL,
  name          TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Colonne facultative pour tracer l'émission de facture sur une commande
ALTER TABLE orders ADD COLUMN IF NOT EXISTS invoiced_at TIMESTAMPTZ;
