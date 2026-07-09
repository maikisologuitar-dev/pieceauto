import Link from "next/link";

/**
 * CategoryTiles — grille de tuiles catégories façon "rayons".
 * Reçoit une liste { name, slug, image, product_count } résolue côté serveur.
 *
 * variant="immersive" : image plein cadre + nom en surimpression (look boutique).
 * variant="classic"   : image produit sur fond clair + nom dessous (défaut).
 */
export default function CategoryTiles({ categories, variant = "classic" }) {
  if (!categories?.length) return null;
  const immersive = variant === "immersive";
  return (
    <div className={immersive ? "cat-tiles cat-tiles--immersive" : "cat-tiles"}>
      {categories.map((c) => (
        <Link key={c.slug} href={`/produits?category=${c.slug}`} className="cat-tile">
          <div className="cat-tile-img">
            {c.image
              ? <img src={c.image} alt="" loading="lazy" />
              : <span className="cat-tile-ph">Rayon</span>}
            {immersive && (
              <span className="cat-tile-overlay">
                <span className="cat-tile-name">{c.name}</span>
                {typeof c.product_count === "number" && (
                  <span className="cat-tile-count">{c.product_count} réf.</span>
                )}
              </span>
            )}
          </div>
          {!immersive && (
            <>
              <span className="cat-tile-name">{c.name}</span>
              {typeof c.product_count === "number" && (
                <span className="cat-tile-count">{c.product_count} réf.</span>
              )}
            </>
          )}
        </Link>
      ))}
    </div>
  );
}