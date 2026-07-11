-- ============================================================================
--  seed-categories.sql — Arborescence des catégories (familles → rayons)
-- ============================================================================
--
--  1) Ajoute la colonne parent_id à `categories` (hiérarchie à 2 niveaux).
--  2) Insère les 11 familles, puis leurs rayons rattachés.
--
--  Réexécutable : ON CONFLICT (slug) évite les doublons ; parent_id est
--  résolu par slug, donc l'ordre d'insertion n'a pas d'importance.
--
--  Familles = parent_id NULL. Rayons = parent_id -> id de la famille.
--
--  Application :
--    psql "$DATABASE_URL" -f scripts/seed-categories.sql
-- ============================================================================

BEGIN;

-- 1) Colonne de hiérarchie (auto-référence). IF NOT EXISTS = réexécutable.
ALTER TABLE categories ADD COLUMN IF NOT EXISTS parent_id integer REFERENCES categories(id) ON DELETE CASCADE;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS image_url text;  -- au cas où absente
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);

-- 2) FAMILLES (niveau 1) --------------------------------------------------
INSERT INTO categories (name, slug, parent_id) VALUES
  ('Freinage',                    'freinage',                 NULL),
  ('Filtration & Vidange',        'filtration-vidange',       NULL),
  ('Direction & Suspension',      'direction-suspension',     NULL),
  ('Démarrage & Charge',          'demarrage-charge',         NULL),
  ('Allumage & Moteur',           'allumage-moteur',          NULL),
  ('Échappement',                 'echappement',              NULL),
  ('Carrosserie & Optiques',      'carrosserie-optiques',     NULL),
  ('Visibilité & Essuyage',       'visibilite-essuyage',      NULL),
  ('Refroidissement & Climatisation', 'refroidissement-clim', NULL),
  ('Gadgets & Électronique',      'gadgets-electronique',     NULL),
  ('Outils de Diagnostic',        'outils-diagnostic',        NULL),
  ('Entretien & Consommables',    'entretien-consommables',   NULL)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, parent_id = NULL;

-- 3) RAYONS (niveau 2) — parent_id résolu par le slug de la famille --------
--    On insère avec un SELECT pour récupérer l'id du parent dynamiquement.
INSERT INTO categories (name, slug, parent_id)
SELECT v.name, v.slug, p.id
FROM (VALUES
  -- Freinage
  ('Plaquettes de frein',        'plaquettes-frein',        'freinage'),
  ('Disques de frein',           'disques-frein',           'freinage'),
  ('Étriers de frein',           'etriers-frein',           'freinage'),
  ('Kits de frein',              'kits-frein',              'freinage'),
  ('Liquide de frein',           'liquide-frein',           'freinage'),
  ('Flexibles & câbles de frein','flexibles-cables-frein',  'freinage'),
  -- Filtration & Vidange
  ('Filtre à huile',             'filtre-huile',            'filtration-vidange'),
  ('Filtre à air',               'filtre-air',              'filtration-vidange'),
  ('Filtre d''habitacle',        'filtre-habitacle',        'filtration-vidange'),
  ('Filtre à carburant',         'filtre-carburant',        'filtration-vidange'),
  ('Huile moteur',               'huile-moteur',            'filtration-vidange'),
  ('Kits de vidange',            'kits-vidange',            'filtration-vidange'),
  -- Direction & Suspension
  ('Amortisseurs',               'amortisseurs',            'direction-suspension'),
  ('Ressorts de suspension',     'ressorts-suspension',     'direction-suspension'),
  ('Rotules de direction',       'rotules-direction',       'direction-suspension'),
  ('Biellettes',                 'biellettes',              'direction-suspension'),
  ('Bras de suspension',         'bras-suspension',         'direction-suspension'),
  ('Roulements de roue',         'roulements-roue',         'direction-suspension'),
  -- Démarrage & Charge
  ('Batteries',                  'batteries',               'demarrage-charge'),
  ('Alternateurs',               'alternateurs',            'demarrage-charge'),
  ('Démarreurs',                 'demarreurs',              'demarrage-charge'),
  ('Boosters de batterie',       'boosters-batterie',       'demarrage-charge'),
  -- Allumage & Moteur
  ('Bougies d''allumage',        'bougies-allumage',        'allumage-moteur'),
  ('Bougies de préchauffage',    'bougies-prechauffage',    'allumage-moteur'),
  ('Bobines d''allumage',        'bobines-allumage',        'allumage-moteur'),
  ('Courroies de distribution',  'courroies-distribution',  'allumage-moteur'),
  ('Pompes à eau',               'pompes-eau',              'allumage-moteur'),
  ('Sondes lambda',              'sondes-lambda',           'allumage-moteur'),
  -- Échappement
  ('Silencieux',                 'silencieux',              'echappement'),
  ('Catalyseurs',                'catalyseurs',             'echappement'),
  ('Filtres à particules',       'filtres-particules',      'echappement'),
  ('Tuyaux d''échappement',      'tuyaux-echappement',      'echappement'),
  -- Carrosserie & Optiques
  ('Pare-chocs',                 'pare-chocs',              'carrosserie-optiques'),
  ('Rétroviseurs',               'retroviseurs',            'carrosserie-optiques'),
  ('Phares / Optiques',          'phares-optiques',         'carrosserie-optiques'),
  ('Feux arrière',               'feux-arriere',            'carrosserie-optiques'),
  ('Ailes',                      'ailes',                   'carrosserie-optiques'),
  ('Vérins de coffre',           'verins-coffre',           'carrosserie-optiques'),
  -- Visibilité & Essuyage
  ('Balais d''essuie-glace',     'balais-essuie-glace',     'visibilite-essuyage'),
  ('Ampoules',                   'ampoules',                'visibilite-essuyage'),
  ('Lave-glace',                 'lave-glace',              'visibilite-essuyage'),
  -- Refroidissement & Climatisation
  ('Radiateurs',                 'radiateurs',              'refroidissement-clim'),
  ('Liquide de refroidissement', 'liquide-refroidissement', 'refroidissement-clim'),
  ('Compresseurs de clim',       'compresseurs-clim',       'refroidissement-clim'),
  ('Condenseurs',                'condenseurs',             'refroidissement-clim'),
  -- Gadgets & Électronique
  ('Caméras de recul',           'cameras-recul',           'gadgets-electronique'),
  ('Dashcams',                   'dashcams',                'gadgets-electronique'),
  ('Chargeurs & USB',            'chargeurs-usb',           'gadgets-electronique'),
  ('Supports téléphone',         'supports-telephone',      'gadgets-electronique'),
  ('Régulateurs & aides',        'regulateurs-aides',       'gadgets-electronique'),
  ('Éclairage LED',              'eclairage-led',           'gadgets-electronique'),
  -- Outils de Diagnostic
  ('Valises OBD2',               'valises-obd2',            'outils-diagnostic'),
  ('Lecteurs de codes',          'lecteurs-codes',          'outils-diagnostic'),
  ('Multimètres',                'multimetres',             'outils-diagnostic'),
  ('Testeurs de batterie',       'testeurs-batterie',       'outils-diagnostic'),
  -- Entretien & Consommables
  ('Additifs',                   'additifs',                'entretien-consommables'),
  ('AdBlue',                     'adblue',                  'entretien-consommables'),
  ('Dégraissants',               'degraissants',            'entretien-consommables'),
  ('Produits de nettoyage',      'produits-nettoyage',      'entretien-consommables')
) AS v(name, slug, parent_slug)
JOIN categories p ON p.slug = v.parent_slug AND p.parent_id IS NULL
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, parent_id = EXCLUDED.parent_id;

-- 4) Récapitulatif
DO $$
DECLARE fam int; ray int;
BEGIN
  SELECT count(*) INTO fam FROM categories WHERE parent_id IS NULL;
  SELECT count(*) INTO ray FROM categories WHERE parent_id IS NOT NULL;
  RAISE NOTICE 'Catégories créées -> familles:% rayons:% total:%', fam, ray, fam+ray;
END $$;

COMMIT;
