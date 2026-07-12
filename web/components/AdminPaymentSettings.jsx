// Cible dans le projet : components/AdminPaymentSettings.jsx
// À intégrer dans une page du back-office (ex. /admin/parametres).
"use client";
import { useEffect, useState } from "react";
import { getAdminPaymentInfo, updatePaymentInfo } from "@/lib/admin";

/**
 * Édition des coordonnées bancaires (RIB) affichées aux clients sur la
 * page de confirmation de commande et imprimées sur les factures PDF.
 * Toute modification est immédiatement visible côté client.
 */
export default function AdminPaymentSettings() {
  const [form, setForm] = useState({
    agency_name: "", bank_name: "", account_holder: "", iban: "", bic: "",
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    let alive = true;
    getAdminPaymentInfo()
      .then((data) => {
        if (!alive) return;
        setForm({
          agency_name: data.agency_name || "",
          bank_name: data.bank_name || "",
          account_holder: data.account_holder || "",
          iban: data.iban || "",
          bic: data.bic || "",
        });
      })
      .catch((e) => alive && setError(e.message))
      .finally(() => alive && setLoading(false));
    return () => { alive = false; };
  }, []);

  const set = (k) => (e) => {
    setSaved(false);
    setForm((f) => ({ ...f, [k]: e.target.value }));
  };

  const save = async () => {
    setSaving(true); setError(""); setSaved(false);
    try {
      await updatePaymentInfo(form);
      setSaved(true);
    } catch (e) {
      setError(e.message);
    }
    setSaving(false);
  };

  const field = { padding: "8px 12px", border: "1px solid var(--line, #e2e6ea)", borderRadius: 4, width: "100%" };

  if (loading) return <p style={{ color: "var(--steel)" }}>Chargement…</p>;

  return (
    <div style={{ background: "#fff", borderRadius: 10, padding: 20, maxWidth: 520 }}>
      <h2 style={{ marginTop: 0, fontSize: 18 }}>Coordonnées bancaires (RIB client)</h2>
      <p style={{ color: "var(--steel, #64748b)", fontSize: 13 }}>
        Affichées aux clients après leur commande, et imprimées sur les factures PDF.
      </p>

      {error && <p style={{ color: "var(--accent-dark, #b3261e)", fontWeight: 600 }}>{error}</p>}

      <div style={{ display: "flex", flexDirection: "column", gap: 12, marginTop: 10 }}>
        <div>
          <label style={{ fontSize: 13, fontWeight: 600 }}>Nom de l'agence</label>
          <input style={{ ...field, marginTop: 4 }} value={form.agency_name} onChange={set("agency_name")}
            placeholder="Ex. Agence Bastos, Douala" />
        </div>
        <div>
          <label style={{ fontSize: 13, fontWeight: 600 }}>Banque</label>
          <input style={{ ...field, marginTop: 4 }} value={form.bank_name} onChange={set("bank_name")}
            placeholder="Ex. Afriland First Bank" />
        </div>
        <div>
          <label style={{ fontSize: 13, fontWeight: 600 }}>Titulaire du compte</label>
          <input style={{ ...field, marginTop: 4 }} value={form.account_holder} onChange={set("account_holder")} />
        </div>
        <div>
          <label style={{ fontSize: 13, fontWeight: 600 }}>IBAN / RIB</label>
          <input style={{ ...field, marginTop: 4 }} value={form.iban} onChange={set("iban")} />
        </div>
        <div>
          <label style={{ fontSize: 13, fontWeight: 600 }}>BIC / SWIFT</label>
          <input style={{ ...field, marginTop: 4 }} value={form.bic} onChange={set("bic")} />
        </div>
      </div>

      <div style={{ marginTop: 18, display: "flex", alignItems: "center", gap: 12 }}>
        <button className="admin-btn primary" onClick={save} disabled={saving}>
          {saving ? "Enregistrement…" : "Enregistrer"}
        </button>
        {saved && <span style={{ color: "green", fontWeight: 600 }}>Enregistré ✓</span>}
      </div>
    </div>
  );
}