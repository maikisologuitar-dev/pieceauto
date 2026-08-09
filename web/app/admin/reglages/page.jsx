"use client";
import { useEffect, useState } from "react";
import { getSettings, updateSettings } from "@/lib/admin";

export default function AdminReglages() {
  const [siret, setSiret] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");
  const [ok, setOk] = useState(false);

  useEffect(() => {
    getSettings()
      .then((s) => setSiret(s.siret || ""))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  }, []);

  // SIRET valide = vide, ou exactement 14 chiffres (espaces ignorés)
  const digits = siret.replace(/\s/g, "");
  const validSiret = digits === "" || /^\d{14}$/.test(digits);

  const save = async () => {
    if (!validSiret) return;
    setSaving(true); setErr(""); setOk(false);
    try {
      await updateSettings({ siret: digits });
      setOk(true);
    } catch (e) {
      setErr(e.message);
    }
    setSaving(false);
  };

  const field = {
    padding: "8px 12px", border: "1px solid var(--line, #e2e6ea)",
    borderRadius: 4, width: "100%", maxWidth: 320, fontFamily: "monospace",
    letterSpacing: "1px",
  };

  return (
    <>
      <h1 className="admin-h1">Réglages</h1>

      <div className="admin-card">
        <h2 style={{ fontFamily: "var(--font-display)", fontSize: 18, textTransform: "uppercase", margin: "0 0 4px" }}>
          Informations légales
        </h2>
        <p style={{ color: "var(--steel)", fontSize: 14, margin: "0 0 20px" }}>
          Utilisées sur les documents et le site.
        </p>

        {err && <p style={{ color: "var(--accent-dark)", fontWeight: 600, marginBottom: 16 }}>{err}</p>}

        {loading ? (
          <p style={{ color: "var(--steel)" }}>Chargement…</p>
        ) : (
          <div>
            <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 6 }}>
              Numéro SIRET
            </label>
            <input
              style={field}
              value={siret}
              onChange={(e) => { setSiret(e.target.value); setOk(false); }}
              placeholder="14 chiffres"
              inputMode="numeric"
            />
            <div style={{ fontSize: 13, marginTop: 6, minHeight: 18 }}>
              {siret && !validSiret ? (
                <span style={{ color: "var(--accent-dark)" }}>
                  Le SIRET doit comporter 14 chiffres ({digits.length}/14).
                </span>
              ) : (
                <span style={{ color: "var(--steel)" }}>
                  SIREN (9) + NIC (5) = 14 chiffres. Peut rester vide.
                </span>
              )}
            </div>

            <div style={{ marginTop: 20, display: "flex", gap: 12, alignItems: "center" }}>
              <button
                className="admin-btn primary"
                onClick={save}
                disabled={saving || !validSiret}
              >
                {saving ? "Enregistrement…" : "Enregistrer"}
              </button>
              {ok && <span style={{ color: "var(--ok)", fontWeight: 600, fontSize: 14 }}>✓ Enregistré</span>}
            </div>
          </div>
        )}
      </div>
    </>
  );
}