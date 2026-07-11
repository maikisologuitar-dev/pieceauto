-- ============================================================================
--  purge-catalogue.sql — REMISE À ZÉRO du catalogue et des commandes
-- ============================================================================
--
--  ⚠️  OPÉRATION IRRÉVERSIBLE. Fais une sauvegarde AVANT :
--        pg_dump "$DATABASE_URL" > sauvegarde_avant_purge.sql
--
--  Ce script vide :
--    - products, product_images, product_categories   (tout le catalogue)
--    - categories                                       (tous les rayons)
--    - orders, order_items                              (toutes les commandes)
--
--  Ce script CONSERVE :
--    - admin_users   (tes comptes administrateur — sinon plus de connexion !)
--
--  Les compteurs d'ID (séquences) sont remis à 1 grâce à RESTART IDENTITY.
--
--  Application :
--    psql "$DATABASE_URL" -f scripts/purge-catalogue.sql
-- ============================================================================

BEGIN;

-- Aperçu de ce qui va être supprimé (s'affiche avant la purge)
DO $$
DECLARE
  p int; i int; pc int; c int; o int; oi int;
BEGIN
  SELECT count(*) INTO p  FROM products;
  SELECT count(*) INTO i  FROM product_images;
  SELECT count(*) INTO pc FROM product_categories;
  SELECT count(*) INTO c  FROM categories;
  SELECT count(*) INTO o  FROM orders;
  SELECT count(*) INTO oi FROM order_items;
  RAISE NOTICE 'À supprimer -> produits:% images:% liens_cat:% categories:% commandes:% lignes_commande:%',
    p, i, pc, c, o, oi;
END $$;

-- TRUNCATE en cascade : vide les tables liées et remet les séquences à zéro.
-- On ne touche PAS à admin_users.
TRUNCATE TABLE
  order_items,
  orders,
  product_images,
  product_categories,
  products,
  categories
RESTART IDENTITY CASCADE;

-- Vérification post-purge (doit afficher 0 partout)
DO $$
DECLARE
  p int; c int; o int;
BEGIN
  SELECT count(*) INTO p FROM products;
  SELECT count(*) INTO c FROM categories;
  SELECT count(*) INTO o FROM orders;
  RAISE NOTICE 'Après purge -> produits:% categories:% commandes:% (admin_users conservés)', p, c, o;
END $$;

-- ⚠️  Tant que ce COMMIT n'est pas exécuté, rien n'est définitif.
--     Si quelque chose te semble anormal dans les NOTICE, remplace COMMIT par ROLLBACK.
COMMIT;
