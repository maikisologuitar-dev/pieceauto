"use client";
import { useEffect, useState } from "react";
import { getAdminProducts, updateProduct } from "@/lib/admin";

const STOCK_LABELS = { en_stock: "En stock", rupture: "Rupture", sur_commande: "Sur commande" };

export default function AdminProducts() {
  const [products, setProducts] = useState([]);
  const [q, setQ] = useState("");
  const [savingId, setSavingId] = useState(null);
  const [savedId, setSavedId] = useState(null);
  const [err, setErr] = useState("");

  const load = (query = "") => getAdminProducts(query).then(setProducts).catch((e) => setErr(e.message));
  useEffect(() => { load(); }, []);

  const onSearch = (e) => { e.preventDefault(); load(q); };

  const save = async (p, patch) => {
    setSavingId(p.id); setErr(""); setSavedId(null);
    try {
      const res = await updateProduct(p.id, patch);
      setProducts((prev) => prev.map((x) =>
        x.id === p.id ? { ...x, price_cents: res.price_cents, stock_status: res.stock_status } : x
      ));
      setSavedId(p.id);
      setTimeout(() => setSavedId(null), 1500);
    } catch (e) { setErr(e.message); }
    setSavingId(null);
  };

  return (
    <>
      <h1 className="admin-h1">Produits</h1>
      {err && <p style={{ color: "var(--accent-dark)" }}>{err}</p>}

      <form className="admin-filters" onSubmit={onSearch}>
        <input value={q} onChange={(e) => setQ(e.target.value)}
          placeholder="Rechercher par titre ou référence…"
          style={{ flex: 1, minWidth: 220, padding: "8px 14px", border: "1px solid var(--line)", borderRadius: 4 }} />
        <button className="admin-btn primary" type="submit">Rechercher</button>
      </form>

      <table className="admin-table">
        <thead>
          <tr><th>Produit</th><th>Réf.</th><th>Prix (€)</th><th>Stock</th><th></th></tr>
        </thead>
        <tbody>
          {products.map((p) => (
            <ProductRow key={p.id} p={p} onSave={save}
              saving={savingId === p.id} saved={savedId === p.id} STOCK_LABELS={STOCK_LABELS} />
          ))}
        </tbody>
      </table>
      {!products.length && <p style={{ color: "var(--steel)", marginTop: 16 }}>Aucun produit.</p>}
    </>
  );
}

function ProductRow({ p, onSave, saving, saved, STOCK_LABELS }) {
  const [price, setPrice] = useState((p.price_cents / 100).toFixed(2));
  const [stock, setStock] = useState(p.stock_status);

  return (
    <tr>
      <td>{p.title}</td>
      <td>{p.reference || "—"}</td>
      <td>
        <input className="editable-price" value={price} onChange={(e) => setPrice(e.target.value)} />
      </td>
      <td>
        <select value={stock} onChange={(e) => setStock(e.target.value)} className="status-select" style={{ width: 140 }}>
          {Object.entries(STOCK_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
        </select>
      </td>
      <td>
        <button className="admin-btn primary" disabled={saving}
          onClick={() => onSave(p, { price_eur: price, stock_status: stock })}>
          {saving ? "…" : saved ? "✓" : "Enregistrer"}
        </button>
      </td>
    </tr>
  );
}
