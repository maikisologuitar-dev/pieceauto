// Cible dans le projet : components/AdminPaymentSettings.jsx
// Utilisé par app/admin/parametres/page.jsx (déjà en place).
//
// Permet à l'administrateur de basculer entre deux modes de règlement
// affichés au client et imprimés sur les factures :
//   - "rib"  : coordonnées bancaires (virement)
//   - "lien" : lien de paiement cliquable
// Les deux jeux de champs restent enregistrés même quand ils ne sont pas
// actifs, pour pouvoir rebasculer sans tout ressaisir (utile quand le lien
// de paiement n'est disponible que par intermittence).
"use client";
import { useEffect, useState } from "react";
import { getAdminPaymentInfo, updatePaymentInfo } from "@/lib/admin";

const EMPTY = {
  payment_mode: "rib",
  bank_name: "",
  agency_name: "",
  account_holder: "",
  iban: "",
  bic: "",
  payment_link_url: "",
  payment_link_label: "",
};

export default function AdminPaymentSettings() {
  const [form, setForm] = useState(EMPTY);
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
          payment_mode: data.payment_mode || "rib",
          bank_name: data.bank_name || "",
          agency_name: data.agency_name || "",
          account_holder: data.account_holder || "",
          iban: data.iban || "",
          bic: data.bic || "",
          payment_link_url: data.payment_link_url || "",
          payment_link_label: data.payment_link_label || "",
        });
      })
      .catch(() => setError("Impossible de charger les paramètres de paiement."))
      .finally(() => setLoading(false));
    return () => { alive = false; };
  }, []);

  function update(field, value) {
    setForm((f) => ({ ...f, [field]: value }));
    setSaved(false);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setSaving(true);
    try {
      const updated = await updatePaymentInfo(form);
      setForm({
        payment_mode: updated.payment_mode || "rib",
        bank_name: updated.bank_name || "",
        agency_name: updated.agency_name || "",
        account_holder: updated.account_holder || "",
        iban: updated.iban || "",
        bic: updated.bic || "",
        payment_link_url: updated.payment_link_url || "",
        payment_link_label: updated.payment_link_label || "",
      });
      setSaved(true);
    } catch (err) {
      setError(err.message || "Échec de l'enregistrement.");
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <p>Chargement…</p>;

  const isLien = form.payment_mode === "lien";

  return (
    <form onSubmit={handleSubmit} className="payment-settings-form">
      <fieldset className="payment-mode-switch">
        <legend>Mode de règlement affiché au client</legend>
        <p className="payment-mode-hint">
          Bascule immédiate : les prochaines factures et la page de confirmation
          client utiliseront le mode choisi ici. Les factures déjà émises ne
          changent pas rétroactivement.
        </p>
        <label className="payment-mode-option">
          <input
            type="radio"
            name="payment_mode"
            value="rib"
            checked={!isLien}
            onChange={() => update("payment_mode", "rib")}
          />
          Coordonnées bancaires (RIB)
        </label>
        <label className="payment-mode-option">
          <input
            type="radio"
            name="payment_mode"
            value="lien"
            checked={isLien}
            onChange={() => update("payment_mode", "lien")}
          />
          Lien de paiement en ligne
        </label>
      </fieldset>

      <div className="payment-fields-group" aria-hidden={isLien} data-active={!isLien}>
        <h2 className="payment-fields-title">Coordonnées bancaires</h2>
        <label>
          Nom de l'agence
          <input value={form.agency_name} onChange={(e) => update("agency_name", e.target.value)} />
        </label>
        <label>
          Banque
          <input value={form.bank_name} onChange={(e) => update("bank_name", e.target.value)} />
        </label>
        <label>
          Titulaire du compte
          <input value={form.account_holder} onChange={(e) => update("account_holder", e.target.value)} />
        </label>
        <label>
          IBAN / RIB
          <input value={form.iban} onChange={(e) => update("iban", e.target.value)} />
        </label>
        <label>
          BIC / SWIFT
          <input value={form.bic} onChange={(e) => update("bic", e.target.value)} />
        </label>
      </div>

      <div className="payment-fields-group" aria-hidden={!isLien} data-active={isLien}>
        <h2 className="payment-fields-title">Lien de paiement</h2>
        <label>
          URL du lien de paiement
          <input
            type="url"
            placeholder="https://…"
            value={form.payment_link_url}
            onChange={(e) => update("payment_link_url", e.target.value)}
          />
        </label>
        <label>
          Texte du bouton (optionnel)
          <input
            placeholder="Payer"
            value={form.payment_link_label}
            onChange={(e) => update("payment_link_label", e.target.value)}
          />
        </label>
        <p className="payment-fields-note">
          Le lien doit être valide et joignable pour pouvoir activer ce mode :
          il apparaîtra cliquable sur la facture du client.
        </p>
      </div>

      {error && <p className="payment-settings-error">{error}</p>}
      {saved && !error && <p className="payment-settings-saved">Enregistré ✓</p>}

      <button type="submit" disabled={saving}>
        {saving ? "Enregistrement…" : "Enregistrer"}
      </button>
    </form>
  );
}