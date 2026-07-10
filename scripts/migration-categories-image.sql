-- migration-categories-image.sql
-- Ajoute une image d'ambiance dédiée par rayon (catégorie).
-- Réexécutable sans risque grâce à IF NOT EXISTS.
--
-- Application :
--   psql "$DATABASE_URL" -f scripts/migration-categories-image.sql

ALTER TABLE categories ADD COLUMN IF NOT EXISTS image_url text;
