"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  createProduct, uploadImages,
  getAdminCategories, getAdminBrands,
} from "@/lib/admin";

export default function NouveauProduitPage() {
  const router = useRouter();

  // Champs du produit
  const [title, setTitle] = useState("");
  const [brand, setBrand] = useState("");
  const [reference, setReference] = useState("");
  const [priceEur, setPriceEur] = useState("");
  const [currency, setCurrency] = useState("EUR");
  const [stockStatus, setStockStatus] = useState("en_stock");
  const [shortDesc, setShortDesc] = useState("");
  const [longDesc, setLongDesc] = useState("");
  const [categoryIds, setCategoryIds] = useState([]);
  const [images, setImages] = useState([]);
  const [urlInput, setUrlInput] = useState("");

  // Données de référence
  const [allCategories, setAllCategories] = useState([]);
  const [allBrands, setAllBrands] = useState([]);

  // États UI
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;
    Promise.all([getAdminCategories(), getAdminBrands()])
      .then(([cats, brands]) => {
        if (!alive) return;
        setAllCategories(cats);
        setAllBrands(brands);
      })
      .catch((e) => { if (alive) setError(e.message); })
      .finally(() => { if (alive) setLoading(false); });
    return () => { alive = false; };
  }, []);

  const toggleCat = (id) =>
    setCategoryIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  const onFiles = async (e) => {
    const files = Array.from(e.target.files || []);
    if (!files.length) return;
    setError(""); setUploading(true);
    try {
      const urls = await uploadImages(files);
      setImages((prev) => [...prev, ...urls]);
    } catch (err) { setError(err.message); }
    setUploading(false);
    e.target.value = "";
  };

  const addUrl = () => {
    const u = urlInput.trim();
    if (!u) return;
    setImages((prev) => [...prev, u]);
    setUrlInput("");
  };

  const removeAt = (idx) => setImages((prev) => prev.filter((_, i) => i !== idx));

  const move = (idx, dir) => {
    setImages((prev) => {
      const next = [...prev];
      const j = idx + dir;
      if (j < 0 || j >= next.length) return prev;
      [next[idx], next[j]] = [next[j], next[idx]];
      return next;
    });
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    if (!title.trim()) { setError("Le titre est obligatoire."); return; }
    setSaving(true); setError("");
    try {
      await createProduct({
        title: title.trim(),
        brand: brand.trim() || null,
        reference: reference.trim() || null,
        price_eur: priceEur === "" ? null : priceEur,
        currency,
        stock_status: stockStatus,
        short_desc: shortDesc || null,
        long_desc: longDesc || null,
        category_ids: categoryIds,
        images,
      });
      // Retour à la liste après création
      router.push("/admin/produits");
    } catch (err) {
      setError(err.message);
      setSaving(false);
    }
  };

  const field = {
    padding: "8px 12px", border: "1px solid var(--line, #e2e6ea)",
    borderRadius: 4, width: "100%",
  };
  const labelStyle = { fontWeight: 600, fontSize: 14, display: "block", marginBottom: 6 };
  const group = { marginBottom: 18 };

  // Hiérarchie familles -> rayons (depuis la liste plate + parent_id)
  const families = allCategories.filter((c) => c.parent_id == null);
  const byParent = new Map();
  for (const c of allCategories) {
    if (c.parent_id == null) continue;
    if (!byParent.has(c.parent_id)) byParent.set(c.parent_id, []);
    byParent.get(c.parent_id).push(c);
  }
  const orphans = allCategories.filter(
    (c) => c.parent_id != null && !families.some((f) => f.id === c.parent_id)
  );

  const CatPill = (c) => {
    const active = categoryIds.includes(c.id);
    return (
      <button type="button" key={c.id} onClick={() => toggleCat(c.id)}
        style={{
          padding: "5px 10px", borderRadius: 999, cursor: "pointer",
          border: "1px solid var(--line, #e2e6ea)", fontSize: 13,
          background: active ? "var(--ink, #16202c)" : "transparent",
          color: active ? "#fff" : "inherit",
        }}>
        {c.name}
      </button>
    );
  };

  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
        <h1 className="admin-h1" style={{ margin: 0 }}>Nouveau produit</h1>
        <Link href="/admin/produits" className="admin-btn">← Retour à la liste</Link>
      </div>

      {error && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{error}</p>}

      {loading ? (
        <p style={{ color: "var(--steel)" }}>Chargement…</p>
      ) : (
        <form onSubmit={onSubmit} style={{ maxWidth: 760 }}>
          {/* Titre */}
          <div style={group}>
            <label style={labelStyle}>Titre *</label>
            <input style={field} value={title} onChange={(e) => setTitle(e.target.value)}
              placeholder="Ex. BOSCH BP1979 Plaquettes de frein Essieu arrière" required />
          </div>

          {/* Ligne : Marque + Référence */}
          <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
            <div style={{ ...group, flex: 1, minWidth: 220 }}>
              <label style={labelStyle}>Marque</label>
              <input style={field} value={brand} onChange={(e) => setBrand(e.target.value)}
                list="new-brand-list" placeholder="Ex. BOSCH" />
              <datalist id="new-brand-list">
                {allBrands.map((b) => <option key={b.name} value={b.name} />)}
              </datalist>
            </div>
            <div style={{ ...group, flex: 1, minWidth: 220 }}>
              <label style={labelStyle}>Référence</label>
              <input style={field} value={reference} onChange={(e) => setReference(e.target.value)}
                placeholder="Ex. BP1979" />
            </div>
          </div>

          {/* Ligne : Prix + Devise + Stock */}
          <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
            <div style={{ ...group, flex: 1, minWidth: 160 }}>
              <label style={labelStyle}>Prix (€)</label>
              <input style={field} value={priceEur} onChange={(e) => setPriceEur(e.target.value)}
                placeholder="47,99" inputMode="decimal" />
              <span style={{ color: "var(--steel)", fontSize: 12 }}>Laisser vide = « Prix sur demande »</span>
            </div>
            <div style={{ ...group, width: 120 }}>
              <label style={labelStyle}>Devise</label>
              <select style={field} value={currency} onChange={(e) => setCurrency(e.target.value)}>
                <option value="EUR">EUR</option>
                <option value="XAF">FCFA</option>
              </select>
            </div>
            <div style={{ ...group, flex: 1, minWidth: 180 }}>
              <label style={labelStyle}>Stock</label>
              <select style={field} value={stockStatus} onChange={(e) => setStockStatus(e.target.value)}>
                <option value="en_stock">En stock</option>
                <option value="sur_commande">Sur commande</option>
                <option value="rupture">Rupture</option>
              </select>
            </div>
          </div>

          {/* Description courte */}
          <div style={group}>
            <label style={labelStyle}>Description courte</label>
            <input style={field} value={shortDesc} onChange={(e) => setShortDesc(e.target.value)}
              placeholder="Résumé affiché sur la fiche produit" />
          </div>

          {/* Description longue */}
          <div style={group}>
            <label style={labelStyle}>Description longue</label>
            <textarea style={{ ...field, minHeight: 120, resize: "vertical" }}
              value={longDesc} onChange={(e) => setLongDesc(e.target.value)}
              placeholder="Détails techniques, compatibilités, notes…" />
          </div>

          {/* Catégories groupées par famille */}
          <div style={group}>
            <label style={labelStyle}>Rayons / catégories</label>
            <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
              {families.map((fam) => (
                <div key={fam.id}>
                  <div style={{
                    fontSize: 12, fontWeight: 700, textTransform: "uppercase",
                    letterSpacing: ".04em", color: "var(--steel, #64748b)", marginBottom: 6,
                  }}>
                    {fam.name}
                  </div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                    {CatPill(fam)}
                    {(byParent.get(fam.id) || []).map((c) => CatPill(c))}
                  </div>
                </div>
              ))}
              {orphans.length > 0 && (
                <div>
                  <div style={{ fontSize: 12, fontWeight: 700, color: "var(--steel)", marginBottom: 6 }}>Autres</div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                    {orphans.map((c) => CatPill(c))}
                  </div>
                </div>
              )}
              {families.length === 0 && orphans.length === 0 && (
                <p style={{ color: "var(--steel)", fontSize: 13 }}>Aucune catégorie disponible.</p>
              )}
            </div>
          </div>

          {/* Images */}
          <div style={group}>
            <label style={labelStyle}>Images</label>
            <p style={{ color: "var(--steel)", fontSize: 13, margin: "0 0 8px" }}>
              La première image sert de vignette.
            </p>
            {images.length > 0 && (
              <div style={{ display: "flex", flexWrap: "wrap", gap: 10, marginBottom: 10 }}>
                {images.map((url, idx) => (
                  <div key={url + idx} style={{ position: "relative", width: 96 }}>
                    <img src={url} alt="" style={{ width: 96, height: 96, objectFit: "cover", borderRadius: 6, border: "1px solid var(--line, #e2e6ea)" }} />
                    {idx === 0 && (
                      <span style={{ position: "absolute", bottom: 4, left: 4, fontSize: 10, fontWeight: 700, color: "#fff", background: "rgba(0,0,0,.65)", padding: "1px 5px", borderRadius: 3 }}>Vignette</span>
                    )}
                    <button type="button" onClick={() => removeAt(idx)} title="Retirer"
                      style={{ position: "absolute", top: -6, right: -6, width: 20, height: 20, borderRadius: "50%", border: "none", background: "#b3261e", color: "#fff", cursor: "pointer", lineHeight: 1, fontSize: 12 }}>×</button>
                    <div style={{ display: "flex", justifyContent: "center", gap: 4, marginTop: 4 }}>
                      <button type="button" onClick={() => move(idx, -1)} disabled={idx === 0}
                        style={{ cursor: "pointer", border: "1px solid var(--line,#e2e6ea)", borderRadius: 4, background: "#fff", fontSize: 12, lineHeight: 1, padding: "2px 6px" }}>←</button>
                      <button type="button" onClick={() => move(idx, 1)} disabled={idx === images.length - 1}
                        style={{ cursor: "pointer", border: "1px solid var(--line,#e2e6ea)", borderRadius: 4, background: "#fff", fontSize: 12, lineHeight: 1, padding: "2px 6px" }}>→</button>
                    </div>
                  </div>
                ))}
              </div>
            )}

            <div style={{ display: "flex", gap: 20, flexWrap: "wrap", alignItems: "flex-start" }}>
              <div>
                <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 6 }}>Depuis l'ordinateur</label>
                <input type="file" accept="image/*" multiple onChange={onFiles} disabled={uploading} />
                {uploading && <span style={{ color: "var(--steel)", fontSize: 13, marginLeft: 8 }}>Envoi…</span>}
              </div>
              <div style={{ flex: 1, minWidth: 240 }}>
                <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 6 }}>…ou par URL</label>
                <div style={{ display: "flex", gap: 8 }}>
                  <input value={urlInput} onChange={(e) => setUrlInput(e.target.value)}
                    placeholder="https://…/image.jpg" style={field} />
                  <button type="button" className="admin-btn" onClick={addUrl}>Ajouter</button>
                </div>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: "flex", gap: 10, marginTop: 8 }}>
            <button type="submit" className="admin-btn primary" disabled={saving || uploading}>
              {saving ? "Création…" : "Créer le produit"}
            </button>
            <Link href="/admin/produits" className="admin-btn">Annuler</Link>
          </div>
        </form>
      )}
    </>
  );
}