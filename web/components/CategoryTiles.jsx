import Link from "next/link";

/**
 * CategoryTiles — grille de tuiles catégories façon "rayons".
 * Reçoit une liste { name, slug, image } déjà résolue côté serveur.
 */
export default function CategoryTiles({ categories }) {
  if (!categories?.length) return null;
  return (
    <div className="cat-tiles">
      {categories.map((c) => (
        <Link key={c.slug} href={`/produits?category=${c.slug}`} className="cat-tile">
          <div className="cat-tile-img">
            {c.image
              ? <img src={c.image} alt="" loading="lazy" />
              : <span className="cat-tile-ph">Rayon</span>}
          </div>
          <span className="cat-tile-name">{c.name}</span>
          {typeof c.product_count === "number" && (
            <span className="cat-tile-count">{c.product_count} réf.</span>
          )}
        </Link>
      ))}
    </div>
  );
}
