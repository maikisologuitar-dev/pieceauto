"use client";
import { useEffect, useState } from "react";
import { getAdminCategories, updateCategoryImage, uploadImages } from "@/lib/admin";

export default function AdminRayons() {
  const [cats, setCats] = useState([]);
  const [err, setErr] = useState("");
  const [busyId, setBusyId] = useState(null);

  const load = () =>
    getAdminCategories().then(setCats).catch((e) => setErr(e.message));
  useEffect(() => { load(); }, []);

  const onUpload = async (cat, file) => {
    if (!file) return;
    setErr(""); setBusyId(cat.id);
    try {
      const [url] = await uploadImages([file]);
      await updateCategoryImage(cat.id, url);
      setCats((prev) => prev.map((c) => (c.id === cat.id ? { ...c, image_url: url } : c)));
    } catch (e) { setErr(e.message); }
    setBusyId(null);
  };

  const onRemove = async (cat) => {
    setErr(""); setBusyId(cat.id);
    try {
      await updateCategoryImage(cat.id, null);
      setCats((prev) => prev.map((c) => (c.id === cat.id ? { ...c, image_url: null } : c)));
    } catch (e) { setErr(e.message); }
    setBusyId(null);
  };

  return (
    <>
      <h1 className="admin-h1">Rayons</h1>
      <p style={{ color: "var(--steel)", fontSize: 14, marginTop: -4 }}>
        Définissez une image d'ambiance par rayon. Sans image dédiée, une photo
        de produit du rayon est utilisée par défaut sur l'accueil.
      </p>
      {err && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{err}</p>}

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 16, marginTop: 16 }}>
        {cats.map((c) => (
          <div key={c.id} style={{ border: "1px solid var(--line, #e2e6ea)", borderRadius: 10, overflow: "hidden", background: "#fff" }}>
            <div style={{ position: "relative", aspectRatio: "4 / 3", background: "var(--ink, #16202c)" }}>
              {c.image_url ? (
                <img src={c.image_url} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
              ) : (
                <span style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", color: "rgba(255,255,255,.6)", fontSize: 13 }}>
                  Pas d'image dédiée
                </span>
              )}
              {busyId === c.id && (
                <span style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(0,0,0,.4)", color: "#fff", fontSize: 13 }}>
                  Envoi…
                </span>
              )}
            </div>
            <div style={{ padding: 12 }}>
              <div style={{ fontWeight: 700, fontSize: 14 }}>{c.name}</div>
              <div style={{ color: "var(--steel)", fontSize: 12, marginBottom: 10 }}>
                {c.product_count} produit{c.product_count > 1 ? "s" : ""}
              </div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                <label className="admin-btn primary" style={{ cursor: "pointer", margin: 0 }}>
                  {c.image_url ? "Changer" : "Ajouter une image"}
                  <input type="file" accept="image/*" style={{ display: "none" }}
                    disabled={busyId === c.id}
                    onChange={(e) => { onUpload(c, e.target.files?.[0]); e.target.value = ""; }} />
                </label>
                {c.image_url && (
                  <button className="admin-btn" disabled={busyId === c.id} onClick={() => onRemove(c)}>
                    Retirer
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
      {!cats.length && <p style={{ color: "var(--steel)", marginTop: 16 }}>Aucun rayon.</p>}
    </>
  );
}