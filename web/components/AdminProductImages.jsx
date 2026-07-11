"use client";
import { useEffect, useState } from "react";
import {
  getProductImages, replaceProductImages, uploadImages,
  getProductCategories, replaceProductCategories,
  getAdminCategories, getAdminBrands, updateProduct,
} from "@/lib/admin";

/**
 * Panneau modal d'édition d'un produit existant :
 *  - Marque (avec suggestions)
 *  - Catégories (groupées par famille -> rayons en pastilles)
 *  - Images (upload / URL / retrait / réordonnancement)
 * "Enregistrer" applique les 3 en une fois (marque via PATCH, catégories et
 * images en remplacement complet).
 *
 * Props : product { id, title, brand }, onClose(), onSaved()
 */
export default function AdminProductImages({ product, onClose, onSaved }) {
  const [images, setImages] = useState([]);
  const [brand, setBrand] = useState(product.brand || "");
  const [allCategories, setAllCategories] = useState([]);
  const [allBrands, setAllBrands] = useState([]);
  const [categoryIds, setCategoryIds] = useState([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [urlInput, setUrlInput] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;
    Promise.all([
      getProductImages(product.id),
      getProductCategories(product.id),
      getAdminCategories(),
      getAdminBrands(),
    ])
      .then(([imgs, catIds, cats, brands]) => {
        if (!alive) return;
        setImages(imgs);
        setCategoryIds(catIds);
        setAllCategories(cats);
        setAllBrands(brands);
      })
      .catch((e) => { if (alive) setError(e.message); })
      .finally(() => { if (alive) setLoading(false); });
    return () => { alive = false; };
  }, [product.id]);

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

  const toggleCat = (id) =>
    setCategoryIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  const save = async () => {
    setSaving(true); setError("");
    try {
      // 1) marque (seulement si changée)
      if ((brand || "") !== (product.brand || "")) {
        await updateProduct(product.id, { brand });
      }
      // 2) catégories (remplacement complet)
      await replaceProductCategories(product.id, categoryIds);
      // 3) images (remplacement complet)
      await replaceProductImages(product.id, images);
      onSaved?.();
      onClose?.();
    } catch (err) { setError(err.message); setSaving(false); }
  };

  const field = { padding: "8px 12px", border: "1px solid var(--line, #e2e6ea)", borderRadius: 4, width: "100%" };

  // --- Pastille de catégorie (réutilisée pour familles et rayons) ---
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

  // --- Reconstruit la hiérarchie familles -> rayons depuis la liste plate ---
  const families = allCategories.filter((c) => c.parent_id == null);
  const byParent = new Map();
  for (const c of allCategories) {
    if (c.parent_id == null) continue;
    if (!byParent.has(c.parent_id)) byParent.set(c.parent_id, []);
    byParent.get(c.parent_id).push(c);
  }
  // catégories dont le parent n'est pas une famille connue (filet de sécurité)
  const orphans = allCategories.filter(
    (c) => c.parent_id != null && !families.some((f) => f.id === c.parent_id)
  );

  return (
    <div
      onClick={onClose}
      style={{
        position: "fixed", inset: 0, background: "rgba(0,0,0,.5)", zIndex: 1000,
        display: "flex", alignItems: "flex-start", justifyContent: "center", padding: 24, overflowY: "auto",
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{ background: "#fff", borderRadius: 10, padding: 20, width: "min(680px, 100%)", marginTop: 40 }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
          <h2 style={{ margin: 0, fontSize: 18 }}>Éditer — {product.title}</h2>
          <button className="admin-btn" onClick={onClose}>Fermer</button>
        </div>

        {error && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{error}</p>}

        {loading ? (
          <p style={{ color: "var(--steel)" }}>Chargement…</p>
        ) : (
          <>
            {/* Marque */}
            <div style={{ marginTop: 8 }}>
              <label style={{ fontWeight: 600, fontSize: 14 }}>Marque</label>
              <input style={{ ...field, marginTop: 6 }} value={brand}
                onChange={(e) => setBrand(e.target.value)} list="edit-brand-list"
                placeholder="Ex. BadBoys" />
              <datalist id="edit-brand-list">
                {allBrands.map((b) => <option key={b.name} value={b.name} />)}
              </datalist>
            </div>

            {/* Catégories — groupées par famille */}
            <div style={{ marginTop: 16 }}>
              <label style={{ fontWeight: 600, fontSize: 14 }}>Rayons / catégories</label>
              <div style={{ marginTop: 6, display: "flex", flexDirection: "column", gap: 14 }}>
                {families.map((fam) => (
                  <div key={fam.id}>
                    <div style={{
                      fontSize: 12, fontWeight: 700, textTransform: "uppercase",
                      letterSpacing: ".04em", color: "var(--steel, #64748b)", marginBottom: 6,
                    }}>
                      {fam.name}
                    </div>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                      {/* la famille elle-même, cliquable */}
                      {CatPill(fam)}
                      {/* ses rayons */}
                      {(byParent.get(fam.id) || []).map((c) => CatPill(c))}
                    </div>
                  </div>
                ))}

                {/* catégories orphelines éventuelles */}
                {orphans.length > 0 && (
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 700, color: "var(--steel)", marginBottom: 6 }}>
                      Autres
                    </div>
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
            <div style={{ marginTop: 18 }}>
              <label style={{ fontWeight: 600, fontSize: 14 }}>Images</label>
              <p style={{ color: "var(--steel)", fontSize: 13, margin: "2px 0 8px" }}>
                La première image sert de vignette.
              </p>
              {images.length === 0 && <p style={{ color: "var(--steel)" }}>Aucune image pour l'instant.</p>}
              <div style={{ display: "flex", flexWrap: "wrap", gap: 10 }}>
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

              <div style={{ marginTop: 14 }}>
                <label style={{ fontSize: 13, fontWeight: 600 }}>Ajouter depuis l'ordinateur</label>
                <input type="file" accept="image/*" multiple onChange={onFiles} disabled={uploading}
                  style={{ display: "block", marginTop: 6 }} />
                {uploading && <span style={{ color: "var(--steel)", fontSize: 13 }}>Envoi en cours…</span>}
              </div>

              <div style={{ marginTop: 12 }}>
                <label style={{ fontSize: 13, fontWeight: 600 }}>…ou ajouter une URL</label>
                <div style={{ display: "flex", gap: 8, marginTop: 6 }}>
                  <input value={urlInput} onChange={(e) => setUrlInput(e.target.value)}
                    placeholder="https://…/image.jpg" style={field} />
                  <button type="button" className="admin-btn" onClick={addUrl}>Ajouter</button>
                </div>
              </div>
            </div>

            <div style={{ marginTop: 22, display: "flex", gap: 10 }}>
              <button className="admin-btn primary" onClick={save} disabled={saving || uploading}>
                {saving ? "Enregistrement…" : "Enregistrer"}
              </button>
              <button className="admin-btn" onClick={onClose} disabled={saving}>Annuler</button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}