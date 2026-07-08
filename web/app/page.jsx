import Link from "next/link";
import { getProducts, getFeaturedCategories } from "@/lib/api";
import ProductCard from "@/components/ProductCard";
import HeroCarousel from "@/components/HeroCarousel";
import CategoryTiles from "@/components/CategoryTiles";

export default async function HomePage() {
  let latest = { products: [] };
  let categories = [];
  try {
    [latest, categories] = await Promise.all([
      getProducts({ page: 1 }),
      getFeaturedCategories(10),
    ]);
  } catch {
    // API non démarrée : la page reste affichable
  }

  return (
    <>
      <HeroCarousel />

      {/* Bandeau de réassurance */}
      <section className="reassurance">
        <div className="container reassurance-grid">
          <div className="reassurance-item">
            <span className="ri-icon">€</span>
            <div><strong>Meilleurs prix</strong><span>Règlement en plusieurs fois</span></div>
          </div>
          <div className="reassurance-item">
            <span className="ri-icon">⚡</span>
            <div><strong>Livraison rapide</strong><span>En stock près de chez vous</span></div>
          </div>
          <div className="reassurance-item">
            <span className="ri-icon">%</span>
            <div><strong>Promos toute l'année</strong><span>Offres renouvelées</span></div>
          </div>
          <div className="reassurance-item">
            <span className="ri-icon">✓</span>
            <div><strong>Qualité garantie</strong><span>Pièces d'origine</span></div>
          </div>
        </div>
      </section>

      {/* Rayons / catégories */}
      {categories.length > 0 && (
        <section className="section">
          <div className="container">
            <div className="section-head">
              <h2 className="section-title">Nos rayons</h2>
              <Link href="/produits" className="section-link">Tout voir →</Link>
            </div>
            <CategoryTiles categories={categories} />
          </div>
        </section>
      )}

      {/* Sélection catalogue */}
      <section className="section section-alt">
        <div className="container">
          <div className="section-head">
            <h2 className="section-title">Au catalogue</h2>
            <Link href="/produits" className="section-link">Tout le catalogue →</Link>
          </div>
          {latest.products.length ? (
            <div className="grid">
              {latest.products.map((p) => <ProductCard key={p.id} product={p} />)}
            </div>
          ) : (
            <p className="empty">
              Le catalogue est vide ou l'API n'est pas démarrée. Lancez l'API puis importez vos produits.
            </p>
          )}
        </div>
      </section>

      {/* Bandeau newsletter / CTA */}
      <section className="cta-band">
        <div className="container cta-band-inner">
          <div>
            <h2>Une pièce précise en tête ?</h2>
            <p>Parcourez le catalogue ou contactez-nous pour un devis sur les pièces techniques.</p>
          </div>
          <Link href="/produits" className="cta-band-btn">Trouver ma pièce</Link>
        </div>
      </section>
    </>
  );
}
