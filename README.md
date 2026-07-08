# PiècesAuto — Plateforme e-commerce (Next.js + Express + PostgreSQL)

Vitrine e-commerce de pièces automobiles avec **règlement hors ligne**
(virement bancaire, chèque, à la livraison, espèces au retrait) : la facture
est transmise manuellement au client après la commande.

## Architecture

```
piecesauto-next/
├── db/schema.sql            Schéma PostgreSQL (catalogue + commandes)
├── scripts/import-scraped.js  Import du catalogue scrapé (JSON) avec nettoyage
├── data/                    Placez ici pieces_auto_produits.json
├── api/                     API Express (port 4000)
│   └── server.js            /health, /api/products, /api/categories, /api/orders
└── web/                     Vitrine Next.js App Router (port 3000)
    ├── app/                 Accueil, catalogue, fiche, panier, commande
    ├── components/          Header, panier (context), cartes produit…
    └── lib/                 Client API + formatage prix
```

Le front appelle l'API via `NEXT_PUBLIC_API_URL` (par défaut `http://localhost:4000`).

## Installation (Windows, sans Docker)

Prérequis : Node.js ≥ 20 et PostgreSQL installé nativement
(installeur EDB + pgAdmin 4 — voir la procédure déjà suivie pour le scaffold).

### 1. Base de données

Dans pgAdmin 4 (ou psql) :

```sql
CREATE DATABASE piecesauto;
```

Puis exécuter le contenu de `db/schema.sql` sur cette base
(pgAdmin → clic droit sur la base → Query Tool → coller → Exécuter).

### 2. Variables de connexion

Les scripts lisent les variables `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`,
`PGPASSWORD` (défauts : localhost / 5432 / piecesauto / postgres / postgres).

Sous `cmd.exe`, pour définir le mot de passe le temps de la session :

```bat
set PGPASSWORD=votre_mot_de_passe
```

### 3. Import du catalogue scrapé

Copier `pieces_auto_produits.json` dans le dossier `data/`, puis :

```bat
npm install
npm run import
```

Le script nettoie les données (miniatures d'images écartées, éléments de menu
retirés des caractéristiques et catégories) et il est **réexécutable** : un
second import met à jour les produits existants au lieu de les dupliquer.

> ⚠️ Les prix scrapés sont à 0 € (le site source masquait ses prix).
> Ces produits s'affichent en « Prix sur demande » sur la vitrine.
> Pour fixer un prix (en centimes) :
> `UPDATE products SET price_cents = 1990 WHERE reference = '17439';`

### 4. Démarrer l'API

```bat
cd api
npm install
npm start
```

Vérifier : http://localhost:4000/health → `{"status":"ok","db":"connected"}`

### 5. Démarrer la vitrine

Dans un **second terminal** :

```bat
cd web
npm install
copy .env.local.example .env.local
npm run dev
```

Ouvrir http://localhost:3000

## Parcours client

1. Catalogue avec recherche (titre ou référence), filtre par rayon, pagination.
2. Fiche produit : galerie, référence, caractéristiques, prix TTC (TVA 20 %)
   ou « Prix sur demande ».
3. Panier persistant (localStorage), quantités modifiables.
4. Commande : coordonnées + choix du mode de règlement hors ligne.
5. Confirmation avec numéro de commande (`CMD-2026-000001`).

Les commandes atterrissent dans les tables `orders` / `order_items` : c'est là
que se branche votre module de **facturation PDF** existant (scaffold
Express + pdf-lib) — la colonne `orders.status` suit le cycle
`en_attente → facturee → payee → expediee`.

## Prochaines étapes suggérées

- Brancher la génération de facture PDF (pdf-lib) sur `POST /api/orders`
  ou via un back-office.
- Back-office admin (produits, commandes, factures) protégé par JWT —
  réutiliser l'auth du scaffold existant.
- SEO : `generateMetadata` par fiche produit, sitemap.
- Production : API sur le VPS Contabo (systemd + Nginx), front sur Vercel
  ou même VPS (`next build && next start`).
