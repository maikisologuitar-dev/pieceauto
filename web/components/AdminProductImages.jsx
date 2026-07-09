"use client";
import { useEffect, useState } from "react";
import { getProductImages, replaceProductImages, uploadImages } from "@/lib/admin";

/**
 * Panneau modal d'édition des images d'un produit existant.
 * - charge les images actuelles
 * - permet d'en ajouter (upload fichier ou URL) et d'en retirer
 * - "Enregistrer" REMPLACE tout le jeu d'images par la liste affichée
 *
 * Props : product { id, title }, onClose(), onSaved()
 */
export default function AdminProductImages({ product, onClose, onSaved }) {
  const [images, setImages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [urlInput, setUrlInput] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;
    getProductImages(product.id)
      .then((imgs) => { if (alive) setImages(imgs); })
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

  const save = async () => {
    setSaving(true); setError("");
    try {
      await replaceProductImages(product.id, images);
      onSaved?.();
      onClose?.();
    } catch (err) { setError(err.message); setSaving(false); }
  };

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
          <h2 style={{ margin: 0, fontSize: 18 }}>Images — {product.title}</h2>
          <button className="admin-btn" onClick={onClose}>Fermer</button>
        </div>
        <p style={{ color: "var(--steel)", fontSize: 13, marginTop: 0 }}>
          La première image sert de vignette. « Enregistrer » remplace toutes les images du produit.
        </p>

        {error && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{error}</p>}

        {loading ? (
          <p style={{ color: "var(--steel)" }}>Chargement des images…</p>
        ) : (
          <>
            {images.length === 0 && (
              <p style={{ color: "var(--steel)" }}>Aucune image pour l'instant.</p>
            )}
            <div style={{ display: "flex", flexWrap: "wrap", gap: 10 }}>
              {images.map((url, idx) => (
                <div key={url + idx} style={{ position: "relative", width: 96 }}>
                  <img src={url} alt="" style={{ width: 96, height: 96, objectFit: "cover", borderRadius: 6, border: "1px solid var(--line, #e2e6ea)" }} />
                  {idx === 0 && (
                    <span style={{ position: "absolute", bottom: 4, left: 4, fontSize: 10, fontWeight: 700, color: "#fff", background: "rgba(0,0,0,.65)", padding: "1px 5px", borderRadius: 3 }}>
                      Vignette
                    </span>
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

            <div style={{ marginTop: 18 }}>
              <label style={{ fontWeight: 600, fontSize: 14 }}>Ajouter depuis l'ordinateur</label>
              <input type="file" accept="image/*" multiple onChange={onFiles} disabled={uploading}
                style={{ display: "block", marginTop: 6 }} />
              {uploading && <span style={{ color: "var(--steel)", fontSize: 13 }}>Envoi en cours…</span>}
            </div>

            <div style={{ marginTop: 14 }}>
              <label style={{ fontWeight: 600, fontSize: 14 }}>…ou ajouter une URL</label>
              <div style={{ display: "flex", gap: 8, marginTop: 6 }}>
                <input value={urlInput} onChange={(e) => setUrlInput(e.target.value)}
                  placeholder="https://…/image.jpg"
                  style={{ flex: 1, padding: "8px 12px", border: "1px solid var(--line,#e2e6ea)", borderRadius: 4 }} />
                <button type="button" className="admin-btn" onClick={addUrl}>Ajouter</button>
              </div>
            </div>

            <div style={{ marginTop: 20, display: "flex", gap: 10 }}>
              <button className="admin-btn primary" onClick={save} disabled={saving || uploading}>
                {saving ? "Enregistrement…" : "Enregistrer les images"}
              </button>
              <button className="admin-btn" onClick={onClose} disabled={saving}>Annuler</button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}