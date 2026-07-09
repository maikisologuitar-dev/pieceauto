"use client";
import { useEffect, useState } from "react";
import {
  getAdminProducts, updateProduct,
  createProduct, getAdminCategories, getAdminBrands, uploadImages,
} from "@/lib/admin";
import AdminProductImages from "@/components/AdminProductImages";

const STOCK_LABELS = { en_stock: "En stock", rupture: "Rupture", sur_commande: "Sur commande" };

export default function AdminProducts() {
  const [products, setProducts] = useState([]);
  const [q, setQ] = useState("");
  const [savingId, setSavingId] = useState(null);
  const [savedId, setSavedId] = useState(null);
  const [err, setErr] = useState("");
  const [imagesProduct, setImagesProduct] = useState(null);

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

      <NewProductForm onCreated={() => load(q)} />

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
              saving={savingId === p.id} saved={savedId === p.id} STOCK_LABELS={STOCK_LABELS}
              onEditImages={() => setImagesProduct(p)} />
          ))}
        </tbody>
      </table>
      {!products.length && <p style={{ color: "var(--steel)", marginTop: 16 }}>Aucun produit.</p>}

      {imagesProduct && (
        <AdminProductImages
          product={imagesProduct}
          onClose={() => setImagesProduct(null)}
          onSaved={() => load(q)}
        />
      )}
    </>
  );
}

function NewProductForm({ onCreated }) {
  const [open, setOpen] = useState(false);
  const [categories, setCategories] = useState([]);
  const [brands, setBrands] = useState([]);
  const [form, setForm] = useState({
    title: "", brand: "", reference: "", price_eur: "",
    stock_status: "en_stock", short_desc: "", long_desc: "",
    images: "", category_ids: [],
  });
  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState("");
  const [error, setError] = useState("");
  const [uploadedUrls, setUploadedUrls] = useState([]);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if (!open) return;
    getAdminCategories().then(setCategories).catch(() => {});
    getAdminBrands().then(setBrands).catch(() => {});
  }, [open]);

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const toggleCat = (id) =>
    setForm((f) => ({
      ...f,
      category_ids: f.category_ids.includes(id)
        ? f.category_ids.filter((x) => x !== id)
        : [...f.category_ids, id],
    }));

  const onFilesSelected = async (e) => {
    const files = Array.from(e.target.files || []);
    if (!files.length) return;
    setError(""); setUploading(true);
    try {
      const urls = await uploadImages(files);
      setUploadedUrls((prev) => [...prev, ...urls]);
    } catch (err) {
      setError(err.message);
    }
    setUploading(false);
    e.target.value = ""; // permet de re-sélectionner les mêmes fichiers
  };

  const removeUploaded = (url) =>
    setUploadedUrls((prev) => prev.filter((u) => u !== url));

  const submit = async () => {
    setError(""); setMsg("");
    if (!form.title.trim()) { setError("Le titre est obligatoire."); return; }
    setSubmitting(true);
    try {
      const manualUrls = form.images.split(/[\n,]+/).map((s) => s.trim()).filter(Boolean);
      const allImages = [...uploadedUrls, ...manualUrls];
      const payload = {
        title: form.title,
        brand: form.brand || null,
        reference: form.reference || null,
        price_eur: form.price_eur,
        stock_status: form.stock_status,
        short_desc: form.short_desc || null,
        long_desc: form.long_desc || null,
        category_ids: form.category_ids,
        images: allImages,
      };
      const res = await createProduct(payload);
      setMsg(`Produit créé (réf. interne ${res.slug}).`);
      setForm({
        title: "", brand: "", reference: "", price_eur: "",
        stock_status: "en_stock", short_desc: "", long_desc: "",
        images: "", category_ids: [],
      });
      setUploadedUrls([]);
      onCreated?.();
    } catch (e) { setError(e.message); }
    setSubmitting(false);
  };

  const field = { padding: "8px 12px", border: "1px solid var(--line)", borderRadius: 4, width: "100%" };

  if (!open) {
    return (
      <div style={{ margin: "8px 0 20px" }}>
        <button className="admin-btn primary" onClick={() => setOpen(true)}>+ Nouveau produit</button>
      </div>
    );
  }

  return (
    <div style={{ border: "1px solid var(--line)", borderRadius: 8, padding: 18, margin: "8px 0 24px", background: "var(--card, #fff)" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
        <h2 style={{ margin: 0, fontSize: 18 }}>Nouveau produit</h2>
        <button className="admin-btn" onClick={() => setOpen(false)}>Fermer</button>
      </div>

      {error && <p style={{ color: "var(--accent-dark)", fontWeight: 600 }}>{error}</p>}
      {msg && <p style={{ color: "green", fontWeight: 600 }}>{msg}</p>}

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <div style={{ gridColumn: "1 / -1" }}>
          <label>Titre *</label>
          <input style={field} value={form.title} onChange={set("title")} placeholder="Ex. BadBoys Nettoyant jantes 500ml" />
        </div>

        <div>
          <label>Marque</label>
          <input style={field} value={form.brand} onChange={set("brand")} list="brand-list" placeholder="Ex. BadBoys" />
          <datalist id="brand-list">
            {brands.map((b) => <option key={b.name} value={b.name} />)}
          </datalist>
        </div>

        <div>
          <label>Référence</label>
          <input style={field} value={form.reference} onChange={set("reference")} placeholder="Ex. 15583132254591" />
        </div>

        <div>
          <label>Prix (€) — laisser vide pour « Prix sur demande »</label>
          <input style={field} value={form.price_eur} onChange={set("price_eur")} placeholder="Ex. 7,90" inputMode="decimal" />
        </div>

        <div>
          <label>Stock</label>
          <select style={field} value={form.stock_status} onChange={set("stock_status")}>
            {Object.entries(STOCK_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
        </div>

        <div style={{ gridColumn: "1 / -1" }}>
          <label>Images du produit — uploader depuis l'ordinateur</label>
          <input type="file" accept="image/*" multiple onChange={onFilesSelected}
            disabled={uploading} style={{ display: "block", marginTop: 6 }} />
          {uploading && <span style={{ color: "var(--steel)", fontSize: 13 }}>Envoi en cours…</span>}
          {uploadedUrls.length > 0 && (
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 10 }}>
              {uploadedUrls.map((url) => (
                <div key={url} style={{ position: "relative" }}>
                  <img src={url} alt="" style={{ width: 72, height: 72, objectFit: "cover", borderRadius: 6, border: "1px solid var(--line)" }} />
                  <button type="button" onClick={() => removeUploaded(url)}
                    title="Retirer"
                    style={{ position: "absolute", top: -6, right: -6, width: 20, height: 20, borderRadius: "50%",
                      border: "none", background: "#b3261e", color: "#fff", cursor: "pointer", lineHeight: 1, fontSize: 12 }}>
                    ×
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div style={{ gridColumn: "1 / -1" }}>
          <label>…ou coller des URLs d'images (une par ligne)</label>
          <textarea style={{ ...field, minHeight: 70 }} value={form.images} onChange={set("images")}
            placeholder="https://…/image1.jpg&#10;https://…/image2.jpg" />
        </div>

        <div style={{ gridColumn: "1 / -1" }}>
          <label>Description courte</label>
          <input style={field} value={form.short_desc} onChange={set("short_desc")} />
        </div>

        <div style={{ gridColumn: "1 / -1" }}>
          <label>Description longue</label>
          <textarea style={{ ...field, minHeight: 80 }} value={form.long_desc} onChange={set("long_desc")} />
        </div>

        <div style={{ gridColumn: "1 / -1" }}>
          <label>Rayons / catégories</label>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 6 }}>
            {categories.map((c) => {
              const active = form.category_ids.includes(c.id);
              return (
                <button type="button" key={c.id} onClick={() => toggleCat(c.id)}
                  style={{
                    padding: "5px 10px", borderRadius: 999, cursor: "pointer",
                    border: "1px solid var(--line)", fontSize: 13,
                    background: active ? "var(--ink, #16202c)" : "transparent",
                    color: active ? "#fff" : "inherit",
                  }}>
                  {c.name}
                </button>
              );
            })}
            {!categories.length && <span style={{ color: "var(--steel)" }}>Chargement des rayons…</span>}
          </div>
        </div>
      </div>

      <div style={{ marginTop: 16 }}>
        <button className="admin-btn primary" onClick={submit} disabled={submitting}>
          {submitting ? "Création…" : "Créer le produit"}
        </button>
      </div>
    </div>
  );
}

function ProductRow({ p, onSave, saving, saved, STOCK_LABELS, onEditImages }) {
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
        <div style={{ display: "flex", gap: 6 }}>
          <button className="admin-btn primary" disabled={saving}
            onClick={() => onSave(p, { price_eur: price, stock_status: stock })}>
            {saving ? "…" : saved ? "✓" : "Enregistrer"}
          </button>
          <button className="admin-btn" type="button" onClick={onEditImages}>
            Images
          </button>
        </div>
      </td>
    </tr>
  );
}