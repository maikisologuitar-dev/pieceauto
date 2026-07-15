"use client";
import { useEffect, useState, useCallback } from "react";
import Link from "next/link";
import { getAdminProducts, deleteProduct, updateProduct } from "@/lib/admin";
import AdminProductImages from "@/components/AdminProductImages";

function euro(cents) {
  return new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" }).format((cents || 0) / 100);
}

const STOCK_LABEL = {
  en_stock: { text: "En stock", color: "#0f7b3f", bg: "#e6f4ec" },
  rupture: { text: "Rupture", color: "#b3261e", bg: "#fce8e6" },
  sur_commande: { text: "Sur commande", color: "#8a6d0b", bg: "#fbf3d9" },
};

export default function AdminProductsPage() {
  const [products, setProducts] = useState([]);
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");
  const [editing, setEditing] = useState(null);   // produit en cours d'édition (modal images)
  const [deletingId, setDeletingId] = useState(null);

  // --- Édition inline du prix, directement dans le tableau ---
  const [editingPriceId, setEditingPriceId] = useState(null);
  const [priceDraft, setPriceDraft] = useState("");
  const [savingPrice, setSavingPrice] = useState(false);
  const [priceErr, setPriceErr] = useState("");

  function startEditPrice(p) {
    setPriceErr("");
    setEditingPriceId(p.id);
    // Champ vide si le produit n'a pas encore de prix (import scrapé à 0 €)
    setPriceDraft(p.price_cents ? String(p.price_cents / 100).replace(".", ",") : "");
  }

  function cancelEditPrice() {
    setEditingPriceId(null);
    setPriceDraft("");
    setPriceErr("");
  }

  async function saveEditPrice(p) {
    const raw = priceDraft.trim().replace(",", ".");
    const value = Number(raw);
    if (raw === "" || Number.isNaN(value) || value < 0) {
      setPriceErr("Prix invalide.");
      return;
    }
    setSavingPrice(true);
    setPriceErr("");
    try {
      const updated = await updateProduct(p.id, { price_eur: raw });
      setProducts((prev) =>
        prev.map((x) => (x.id === p.id ? { ...x, price_cents: updated.price_cents } : x))
      );
      setEditingPriceId(null);
      setPriceDraft("");
    } catch (e) {
      setPriceErr(e.message || "Échec de la mise à jour du prix.");
    } finally {
      setSavingPrice(false);
    }
  }

  const load = useCallback((query = "") => {
    setLoading(true); setErr("");
    getAdminProducts(query)
      .then((rows) => setProducts(Array.isArray(rows) ? rows : []))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  const onSearch = (e) => {
    e.preventDefault();
    load(q.trim());
  };

  const onDelete = async (p) => {
    if (!window.confirm(`Supprimer définitivement « ${p.title} » ?\nCette action est irréversible.`)) return;
    setDeletingId(p.id); setErr("");
    try {
      await deleteProduct(p.id);
      setProducts((prev) => prev.filter((x) => x.id !== p.id));
    } catch (e) {
      setErr(e.message);
    }
    setDeletingId(null);
  };

  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 12 }}>
        <h1 className="admin-h1" style={{ margin: 0 }}>Produits</h1>
        <Link href="/admin/produits/nouveau" className="admin-btn primary">+ Nouveau produit</Link>
      </div>

      <form onSubmit={onSearch} style={{ display: "flex", gap: 8, margin: "16px 0" }}>
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Rechercher par nom ou référence…"
          style={{ flex: 1, padding: "8px 12px", border: "1px solid var(--line, #e2e6ea)", borderRadius: 4 }}
        />
        <button type="submit" className="admin-btn">Rechercher</button>
        {q && (
          <button type="button" className="admin-btn" onClick={() => { setQ(""); load(""); }}>
            Réinitialiser
          </button>
        )}
      </form>

      {err && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{err}</p>}

      {loading ? (
        <p style={{ color: "var(--steel)" }}>Chargement…</p>
      ) : products.length === 0 ? (
        <p style={{ color: "var(--steel)" }}>
          {q ? "Aucun produit ne correspond à cette recherche." : "Aucun produit au catalogue."}
        </p>
      ) : (
        <>
          <p style={{ color: "var(--steel)", fontSize: 13 }}>
            {products.length} produit{products.length > 1 ? "s" : ""}
            {products.length === 500 ? " (500 max affichés)" : ""}
          </p>
          <div style={{ overflowX: "auto" }}>
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 14 }}>
              <thead>
                <tr style={{ textAlign: "left", borderBottom: "2px solid var(--line, #e2e6ea)" }}>
                  <th style={{ padding: "10px 8px" }}>Produit</th>
                  <th style={{ padding: "10px 8px" }}>Référence</th>
                  <th style={{ padding: "10px 8px" }}>Marque</th>
                  <th style={{ padding: "10px 8px", textAlign: "right" }}>Prix</th>
                  <th style={{ padding: "10px 8px" }}>Stock</th>
                  <th style={{ padding: "10px 8px", textAlign: "right" }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {products.map((p) => {
                  const st = STOCK_LABEL[p.stock_status] || STOCK_LABEL.en_stock;
                  return (
                    <tr key={p.id} style={{ borderBottom: "1px solid var(--line, #e2e6ea)" }}>
                      <td style={{ padding: "10px 8px", fontWeight: 600 }}>{p.title}</td>
                      <td style={{ padding: "10px 8px", color: "var(--steel)" }}>{p.reference || "—"}</td>
                      <td style={{ padding: "10px 8px" }}>{p.brand || "—"}</td>
                      <td style={{ padding: "10px 8px", textAlign: "right", whiteSpace: "nowrap" }}>
                        {editingPriceId === p.id ? (
                          <div style={{ display: "flex", alignItems: "center", gap: 6, justifyContent: "flex-end" }}>
                            <input
                              autoFocus
                              value={priceDraft}
                              onChange={(e) => setPriceDraft(e.target.value)}
                              onKeyDown={(e) => {
                                if (e.key === "Enter") saveEditPrice(p);
                                if (e.key === "Escape") cancelEditPrice();
                              }}
                              placeholder="0,00"
                              style={{ width: 90, padding: "4px 6px", border: "1px solid var(--line, #e2e6ea)", borderRadius: 4, textAlign: "right" }}
                            />
                            <span style={{ color: "var(--steel)" }}>€</span>
                            <button
                              type="button"
                              className="admin-btn"
                              onClick={() => saveEditPrice(p)}
                              disabled={savingPrice}
                              style={{ padding: "4px 8px" }}
                            >
                              {savingPrice ? "…" : "✓"}
                            </button>
                            <button
                              type="button"
                              className="admin-btn"
                              onClick={cancelEditPrice}
                              disabled={savingPrice}
                              style={{ padding: "4px 8px" }}
                            >
                              ✕
                            </button>
                          </div>
                        ) : (
                          <button
                            type="button"
                            onClick={() => startEditPrice(p)}
                            title="Modifier le prix"
                            style={{
                              background: "none", border: "none", cursor: "pointer",
                              font: "inherit", padding: 0,
                              color: p.price_cents ? "inherit" : "var(--steel)",
                              textDecoration: "underline dotted",
                            }}
                          >
                            {p.price_cents ? euro(p.price_cents) : "Sur demande"}
                          </button>
                        )}
                        {editingPriceId === p.id && priceErr && (
                          <div style={{ color: "var(--accent-dark, #b3261e)", fontSize: 12, marginTop: 4 }}>
                            {priceErr}
                          </div>
                        )}
                      </td>
                      <td style={{ padding: "10px 8px" }}>
                        <span style={{ background: st.bg, color: st.color, padding: "2px 8px", borderRadius: 999, fontSize: 12, fontWeight: 600, whiteSpace: "nowrap" }}>
                          {st.text}
                        </span>
                      </td>
                      <td style={{ padding: "10px 8px", textAlign: "right", whiteSpace: "nowrap" }}>
                        <button className="admin-btn" onClick={() => setEditing(p)} style={{ marginRight: 6 }}>
                          Éditer
                        </button>
                        <button
                          className="admin-btn"
                          onClick={() => onDelete(p)}
                          disabled={deletingId === p.id}
                          style={{ color: "#b3261e", borderColor: "#f0c6c2" }}
                        >
                          {deletingId === p.id ? "…" : "Supprimer"}
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}

      {editing && (
        <AdminProductImages
          product={editing}
          onClose={() => setEditing(null)}
          onSaved={() => load(q.trim())}
        />
      )}
    </>
  );
}