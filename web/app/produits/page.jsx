"use client";
import { useEffect, useState, useCallback } from "react";
import { getProducts } from "@/lib/api";
import ProductCard from "@/components/ProductCard";

const LIMIT = 12; // doit correspondre au "limit" de getProducts dans web/lib/api.js

export default function ProduitsPage() {
  const [products, setProducts] = useState([]);
  const [q, setQ] = useState("");
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(false);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  const load = useCallback(async (query = "", pageNum = 1, append = false) => {
    setLoading(true);
    setErr("");
    try {
      const data = await getProducts({ page: pageNum, q: query });
      const rows = Array.isArray(data?.products) ? data.products : [];
      setProducts((prev) => (append ? [...prev, ...rows] : rows));
      setHasMore(rows.length === LIMIT);
      setPage(pageNum);
    } catch (e) {
      setErr(e.message || "Impossible de charger le catalogue.");
      if (!append) setProducts([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load("", 1, false); }, [load]);

  const onSearch = (e) => {
    e.preventDefault();
    load(q.trim(), 1, false);
  };

  const onReset = () => {
    setQ("");
    load("", 1, false);
  };

  return (
    <section className="section">
      <div className="container">
        <div className="section-head">
          <h1 className="section-title" style={{ margin: 0 }}>Catalogue</h1>
        </div>

        <form onSubmit={onSearch} style={{ display: "flex", gap: 8, margin: "16px 0", flexWrap: "wrap" }}>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Rechercher une pièce, une référence…"
            style={{
              flex: "1 1 260px",
              padding: "10px 14px",
              border: "1px solid var(--line, #e2e6ea)",
              borderRadius: 6,
            }}
          />
          <button type="submit" className="cta-band-btn">Rechercher</button>
          {q && (
            <button
              type="button"
              onClick={onReset}
              style={{
                padding: "10px 14px",
                border: "1px solid var(--line, #e2e6ea)",
                borderRadius: 6,
                background: "#fff",
                cursor: "pointer",
              }}
            >
              Réinitialiser
            </button>
          )}
        </form>

        {err && (
          <p className="empty" style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>
            {err}
          </p>
        )}

        {loading && products.length === 0 ? (
          <p className="empty">Chargement…</p>
        ) : products.length === 0 ? (
          <p className="empty">
            {q ? "Aucun produit ne correspond à cette recherche." : "Aucun produit au catalogue."}
          </p>
        ) : (
          <>
            <div className="grid">
              {products.map((p) => (
                <ProductCard key={p.id} product={p} />
              ))}
            </div>

            {hasMore && (
              <div style={{ textAlign: "center", marginTop: 24 }}>
                <button
                  type="button"
                  className="cta-band-btn"
                  disabled={loading}
                  onClick={() => load(q.trim(), page + 1, true)}
                >
                  {loading ? "Chargement…" : "Charger plus"}
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </section>
  );
}