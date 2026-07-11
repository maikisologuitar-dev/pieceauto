import Link from "next/link";
import { getProducts, getCategories, getBrands } from "@/lib/api";
import ProductCard from "@/components/ProductCard";

export const metadata = { title: "Catalogue — PiècesAuto" };

export default async function CataloguePage({ searchParams }) {
  const sp = await searchParams;
  const page = parseInt(sp?.page) || 1;
  const q = sp?.q || "";
  const category = sp?.category || "";
  const brand = sp?.brand || "";
  const sort = sp?.sort || "";

  let data = { products: [], total: 0, pages: 1, page: 1 };
  let families = [];
  let brands = [];
  try {
    [data, families, brands] = await Promise.all([
      getProducts({ page, q, category, brand, sort }),
      getCategories(),   // hiérarchie : familles + children
      getBrands(),
    ]);
  } catch {}

  const buildHref = (p) => {
    const params = new URLSearchParams();
    if (q) params.set("q", q);
    if (category) params.set("category", category);
    if (brand) params.set("brand", brand);
    if (sort) params.set("sort", sort);
    if (p > 1) params.set("page", String(p));
    const s = params.toString();
    return `/produits${s ? `?${s}` : ""}`;
  };

  return (
    <section className="section">
      <div className="container">
        <h1 className="section-title">
          Catalogue {data.total ? `— ${data.total} pièces` : ""}
        </h1>

        <form className="toolbar" action="/produits" method="get">
          <input
            type="search" name="q" defaultValue={q}
            placeholder="Rechercher une pièce ou une référence…"
            aria-label="Recherche"
          />

          {/* Rayons groupés par famille */}
          <select name="category" defaultValue={category} aria-label="Rayon">
            <option value="">Tous les rayons</option>
            {families.map((fam) => (
              <optgroup key={fam.slug} label={fam.name}>
                {/* la famille elle-même : inclut tous ses rayons */}
                <option value={fam.slug}>
                  Tout {fam.name.toLowerCase()} ({fam.product_count})
                </option>
                {(fam.children || []).map((c) => (
                  <option key={c.slug} value={c.slug}>
                    {c.name} ({c.product_count})
                  </option>
                ))}
              </optgroup>
            ))}
          </select>

          <select name="brand" defaultValue={brand} aria-label="Marque">
            <option value="">Toutes les marques</option>
            {brands.map((b) => (
              <option key={b.name} value={b.name}>{b.name} ({b.product_count})</option>
            ))}
          </select>

          <select name="sort" defaultValue={sort} aria-label="Tri">
            <option value="">Tri conseillé</option>
            <option value="title">Nom (A→Z)</option>
            <option value="price">Prix croissant</option>
          </select>

          <button type="submit">Filtrer</button>
        </form>

        {data.products.length ? (
          <div className="grid">
            {data.products.map((p) => <ProductCard key={p.id} product={p} />)}
          </div>
        ) : (
          <p className="empty">Aucune pièce ne correspond à cette recherche.</p>
        )}

        {data.pages > 1 && (
          <nav className="pagination" aria-label="Pagination">
            {data.page > 1 && <Link href={buildHref(data.page - 1)}>‹ Précédent</Link>}
            {Array.from({ length: data.pages }, (_, i) => i + 1)
              .filter((p) => Math.abs(p - data.page) <= 3 || p === 1 || p === data.pages)
              .map((p, idx, arr) => (
                <span key={p} style={{ display: "contents" }}>
                  {idx > 0 && arr[idx - 1] !== p - 1 && <span>…</span>}
                  {p === data.page
                    ? <span className="current">{p}</span>
                    : <Link href={buildHref(p)}>{p}</Link>}
                </span>
              ))}
            {data.page < data.pages && <Link href={buildHref(data.page + 1)}>Suivant ›</Link>}
          </nav>
        )}
      </div>
    </section>
  );
}