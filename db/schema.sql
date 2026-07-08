-- ============================================================
-- PiècesAuto — Schéma PostgreSQL
-- Catalogue produits + commandes avec règlement hors-ligne
-- Exécuter dans pgAdmin 4 ou : psql -U postgres -d piecesauto -f schema.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS categories (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  slug        TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
  id            SERIAL PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  title         TEXT NOT NULL,
  reference     TEXT,
  brand         TEXT,
  price_cents   INTEGER NOT NULL DEFAULT 0,     -- prix TTC en centimes d'euro (0 = prix sur demande)
  currency      TEXT NOT NULL DEFAULT 'EUR',
  short_desc    TEXT,
  long_desc     TEXT,
  features      JSONB NOT NULL DEFAULT '[]',
  stock_status  TEXT NOT NULL DEFAULT 'en_stock', -- en_stock | rupture | sur_commande
  source_url    TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_title ON products (lower(title));
CREATE INDEX IF NOT EXISTS idx_products_reference ON products (reference);

CREATE TABLE IF NOT EXISTS product_images (
  id          SERIAL PRIMARY KEY,
  product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  position    INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS product_categories (
  product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (product_id, category_id)
);

-- ------------------------------------------------------------
-- Commandes (règlement hors-ligne : la facture est envoyée
-- manuellement au client après la commande)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id              SERIAL PRIMARY KEY,
  order_number    TEXT NOT NULL UNIQUE,           -- ex: CMD-2026-000001
  customer_name   TEXT NOT NULL,
  customer_email  TEXT NOT NULL,
  customer_phone  TEXT,
  address_line    TEXT NOT NULL,
  postal_code     TEXT NOT NULL,
  city            TEXT NOT NULL,
  country         TEXT NOT NULL DEFAULT 'France',
  payment_method  TEXT NOT NULL CHECK (payment_method IN ('virement','cheque','livraison','especes')),
  status          TEXT NOT NULL DEFAULT 'en_attente', -- en_attente | facturee | payee | expediee | annulee
  total_cents     INTEGER NOT NULL DEFAULT 0,
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  id           SERIAL PRIMARY KEY,
  order_id     INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   INTEGER REFERENCES products(id) ON DELETE SET NULL,
  title        TEXT NOT NULL,      -- copie au moment de la commande
  reference    TEXT,
  unit_cents   INTEGER NOT NULL,
  quantity     INTEGER NOT NULL CHECK (quantity > 0)
);

-- Séquence lisible pour les numéros de commande
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;
