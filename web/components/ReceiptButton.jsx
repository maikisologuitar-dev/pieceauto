"use client";
import { useState } from "react";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/**
 * Bouton de téléchargement du reçu PDF d'une commande.
 * Accède à la route publique sécurisée par token :
 *   GET /api/orders/:number/receipt?token=xxx
 * Le token (impossible à deviner) garantit que seul le client
 * possédant le lien de confirmation peut télécharger son reçu.
 */
export default function ReceiptButton({ orderNumber, token }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  const download = async () => {
    setBusy(true); setError("");
    try {
      const url = `${API}/api/orders/${encodeURIComponent(orderNumber)}/receipt?token=${encodeURIComponent(token)}`;
      const res = await fetch(url);
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Reçu indisponible");
      }
      const blob = await res.blob();
      const objectUrl = URL.createObjectURL(blob);
      // Déclenche le téléchargement du fichier
      const a = document.createElement("a");
      a.href = objectUrl;
      a.download = `recu-${orderNumber}.pdf`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      URL.revokeObjectURL(objectUrl);
    } catch (e) {
      setError(e.message);
    }
    setBusy(false);
  };

  return (
    <>
      <button className="btn-add" onClick={download} disabled={busy}>
        {busy ? "Préparation…" : "Télécharger mon reçu (PDF)"}
      </button>
      {error && (
        <p style={{ color: "var(--accent-dark, #b3261e)", fontSize: 13, marginTop: 8 }}>
          {error}
        </p>
      )}
    </>
  );
}