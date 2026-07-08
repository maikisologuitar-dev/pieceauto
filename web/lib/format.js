export function formatPrice(cents) {
  if (!cents || cents <= 0) return null; // prix sur demande
  return new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" }).format(cents / 100);
}

export const PAYMENT_LABELS = {
  virement: "Virement bancaire",
  cheque: "Chèque",
  livraison: "Règlement à la livraison",
  especes: "Espèces au retrait",
};
