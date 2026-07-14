// Cible dans le projet : components/PaymentProofPanel.jsx
"use client";
import { useState } from "react";
import { uploadPaymentProof } from "@/lib/api";

const copyBtnStyle = {
  padding: "6px 14px",
  fontSize: 13,
  fontWeight: 600,
  borderRadius: 4,
  border: "1px solid var(--line, #e2e6ea)",
  background: "#fff",
  cursor: "pointer",
  color: "var(--ink, #16202c)",
  whiteSpace: "nowrap",
};

const linkBtnStyle = {
  display: "inline-block",
  marginTop: 6,
  padding: "10px 20px",
  fontSize: 15,
  fontWeight: 700,
  borderRadius: 6,
  background: "var(--accent-dark, #1a56db)",
  color: "#fff",
  textDecoration: "none",
};

function CopyField({ label, value }) {
  const [copied, setCopied] = useState(false);
  if (!value) return null;

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      setCopied(false);
    }
  };

  return (
    <div
      style={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        gap: 10, padding: "10px 0", borderBottom: "1px solid var(--line, #e2e6ea)",
      }}
    >
      <div>
        <div style={{ fontSize: 12, color: "var(--steel, #64748b)", textTransform: "uppercase", letterSpacing: ".04em" }}>
          {label}
        </div>
        <div style={{ fontSize: 15, fontWeight: 600, fontFamily: "monospace", wordBreak: "break-all" }}>
          {value}
        </div>
      </div>
      <button type="button" onClick={copy} style={copyBtnStyle}>
        {copied ? "Copié ✓" : "Copier"}
      </button>
    </div>
  );
}

/**
 * Affiche le mode de règlement actuellement actif — RIB ou lien de paiement,
 * choisi par l'admin dans /admin/parametres, et peut basculer d'une commande
 * à l'autre selon la disponibilité du lien — puis permet au client de
 * téléverser sa preuve de paiement, dernière étape avant la livraison
 * (identique dans les deux modes).
 *
 * Props : orderNumber, token (jeton public de la commande),
 *         bank = résultat de getPaymentInfo(), forme :
 *           { mode: "rib", bank_name, agency_name, account_holder, iban, bic }
 *           { mode: "lien", payment_link_url, payment_link_label }
 */
export default function PaymentProofPanel({ orderNumber, token, bank }) {
  const [file, setFile] = useState(null);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState("");
  const [done, setDone] = useState(false);

  // Rétro-compatible : si `bank.mode` est absent (ancien format), on retombe
  // sur le RIB pour ne rien casser tant que tous les appels ne sont pas à jour.
  const mode = bank?.mode === "lien" ? "lien" : "rib";
  const hasRib = mode === "rib" && bank && (bank.iban || bank.agency_name || bank.bank_name);
  const hasLink = mode === "lien" && bank && bank.payment_link_url;
  if (!hasRib && !hasLink) return null;

  const submit = async () => {
    if (!file) {
      setError("Merci de sélectionner votre capture ou reçu de paiement.");
      return;
    }
    setError("");
    setSending(true);
    try {
      await uploadPaymentProof(orderNumber, token, file);
      setDone(true);
    } catch (e) {
      setError(e.message);
    }
    setSending(false);
  };

  return (
    <div style={{ marginTop: 26, border: "1px solid var(--line, #e2e6ea)", borderRadius: 8, padding: 20 }}>
      {hasLink ? (
        <>
          <h2 style={{ fontSize: 18, marginTop: 0, marginBottom: 4 }}>Réglez votre commande en ligne</h2>
          <p style={{ color: "var(--steel, #64748b)", fontSize: 13, marginTop: 0 }}>
            Cliquez sur le bouton ci-dessous pour effectuer votre paiement, puis
            téléversez votre justificatif.
          </p>
          <a
            href={bank.payment_link_url}
            target="_blank"
            rel="noopener noreferrer"
            style={linkBtnStyle}
          >
            {bank.payment_link_label || "Payer"}
          </a>

          <div className="notice" style={{ marginTop: 18 }}>
            Dernière étape avant la livraison : une fois le paiement effectué,
            téléversez ici une capture d'écran ou le reçu de votre paiement.
            Votre commande part en préparation dès sa vérification par notre équipe.
          </div>
        </>
      ) : (
        <>
          <h2 style={{ fontSize: 18, marginTop: 0, marginBottom: 4 }}>Coordonnées pour le virement</h2>
          <p style={{ color: "var(--steel, #64748b)", fontSize: 13, marginTop: 0 }}>
            Effectuez le virement vers ce compte, puis téléversez votre justificatif ci-dessous.
          </p>

          <div style={{ marginTop: 10 }}>
            <CopyField label="Agence" value={bank.agency_name} />
            <CopyField label="Banque" value={bank.bank_name} />
            <CopyField label="Titulaire du compte" value={bank.account_holder} />
            <CopyField label="IBAN" value={bank.iban} />
            <CopyField label="BIC" value={bank.bic} />
          </div>

          <div className="notice" style={{ marginTop: 18 }}>
            Dernière étape avant la livraison : une fois le virement effectué, téléversez
            ici une capture d'écran ou le reçu de votre paiement. Votre commande part en
            préparation dès sa vérification par notre équipe.
          </div>
        </>
      )}

      {done ? (
        <p style={{ color: "green", fontWeight: 600, marginTop: 14 }}>
          Preuve de paiement bien reçue ✓ — nous préparons votre commande.
        </p>
      ) : (
        <div style={{ marginTop: 14 }}>
          <input
            type="file"
            accept="image/*,application/pdf"
            onChange={(e) => setFile(e.target.files?.[0] || null)}
            disabled={sending}
          />
          {error && <p style={{ color: "var(--accent-dark)", fontWeight: 600, marginTop: 8 }}>{error}</p>}
          <button className="btn-add" style={{ marginTop: 12 }} onClick={submit} disabled={sending}>
            {sending ? "Envoi…" : "Envoyer ma preuve de paiement"}
          </button>
        </div>
      )}
    </div>
  );
}