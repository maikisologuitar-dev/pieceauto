"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useCart } from "@/components/CartProvider";
import { createOrder } from "@/lib/api";
import { formatPrice } from "@/lib/format";
import { computeDelivery, DELIVERY_RATE_PER_KM } from "@/lib/delivery";

export default function CheckoutPage() {
  const cart = useCart();
  const router = useRouter();
  const [form, setForm] = useState({
    name: "", email: "", phone: "",
    address_line: "", postal_code: "", city: "", note: "",
  });
  const payment = "virement";
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  // --- Livraison ---
  const [delivery, setDelivery] = useState(null); // { km, feeCents }
  const [deliveryLoading, setDeliveryLoading] = useState(false);
  const [deliveryErr, setDeliveryErr] = useState("");

  if (!cart) return null;
  if (!cart.items.length) {
    return (
      <section className="section"><div className="container">
        <h1 className="section-title">Commande</h1>
        <p className="empty">
          Votre panier est vide. <Link href="/produits" style={{ color: "var(--accent-dark)", fontWeight: 600 }}>Parcourir le catalogue →</Link>
        </p>
      </div></section>
    );
  }

  const set = (k) => (e) => {
    setForm((f) => ({ ...f, [k]: e.target.value }));
    // Une modification d'adresse invalide le calcul de livraison précédent.
    if (["address_line", "postal_code", "city"].includes(k)) {
      setDelivery(null);
      setDeliveryErr("");
    }
  };

  const addressComplete = form.address_line && form.postal_code && form.city;

  async function calcDelivery() {
    setDeliveryErr("");
    if (!addressComplete) {
      setDeliveryErr("Renseignez d'abord l'adresse, le code postal et la ville.");
      return null;
    }
    setDeliveryLoading(true);
    try {
      const res = await computeDelivery(form);
      setDelivery(res);
      return res;
    } catch (e) {
      setDeliveryErr(e.message || "Impossible de calculer la livraison.");
      setDelivery(null);
      return null;
    } finally {
      setDeliveryLoading(false);
    }
  }

  const deliveryFeeCents = delivery?.feeCents ?? 0;
  const grandTotal = cart.total + deliveryFeeCents;

  const submit = async () => {
    setError("");
    if (!form.name || !form.email || !form.address_line || !form.postal_code || !form.city) {
      setError("Merci de remplir tous les champs obligatoires (*).");
      return;
    }
    setSubmitting(true);

    // La livraison doit être incluse : on la calcule si ce n'est pas déjà fait.
    let del = delivery;
    if (!del) {
      del = await calcDelivery();
      if (!del) { setSubmitting(false); return; }
    }
    const feeCents = del.feeCents;

    try {
      const res = await createOrder({
        customer: form,
        payment_method: payment,
        note: form.note,
        // On transmet aussi la livraison à l'API (ignorée si non gérée côté serveur).
        delivery_km: del.km,
        delivery_fee_cents: feeCents,
        items: cart.items.map((i) => ({ product_id: i.product_id, quantity: i.quantity })),
      });

      // --- Snapshot de la facture (généré côté front) ---
      const invoice = {
        order_number: res.order_number,
        date: new Date().toISOString(),
        customer: { ...form },
        items: cart.items.map((i) => ({
          title: i.title,
          reference: i.reference,
          slug: i.slug,
          price_cents: i.price_cents,
          quantity: i.quantity,
        })),
        subtotal_cents: cart.total,
        delivery_km: del.km,
        delivery_fee_cents: feeCents,
        total_cents: cart.total + feeCents,
        payment_method: payment,
      };
      try {
        sessionStorage.setItem(`invoice:${res.order_number}`, JSON.stringify(invoice));
      } catch {}

      cart.clear();
      const params = new URLSearchParams({ n: res.order_number });
      if (res.public_token) params.set("t", res.public_token);
      router.push(`/commande/confirmation?${params.toString()}`);
    } catch (e) {
      setError(e.message);
      setSubmitting(false);
    }
  };

  return (
    <section className="section">
      <div className="container" style={{ maxWidth: 760 }}>
        <h1 className="section-title">Finaliser la commande</h1>
        <div className="form-grid">
          <div><label>Nom complet *</label><input value={form.name} onChange={set("name")} autoComplete="name" /></div>
          <div><label>Email *</label><input type="email" value={form.email} onChange={set("email")} autoComplete="email" /></div>
          <div><label>Téléphone</label><input value={form.phone} onChange={set("phone")} autoComplete="tel" /></div>
          <div className="full"><label>Adresse *</label><input value={form.address_line} onChange={set("address_line")} autoComplete="street-address" /></div>
          <div><label>Code postal *</label><input value={form.postal_code} onChange={set("postal_code")} autoComplete="postal-code" /></div>
          <div><label>Ville *</label><input value={form.city} onChange={set("city")} autoComplete="address-level2" /></div>
          <div className="full"><label>Remarque (facultatif)</label><textarea rows={3} value={form.note} onChange={set("note")} /></div>
        </div>

        <h2 className="section-title" style={{ marginTop: 30, fontSize: 20 }}>Livraison</h2>
        <div style={{ display: "flex", alignItems: "center", gap: 12, flexWrap: "wrap" }}>
          <button type="button" className="btn-add btn-add--ghost" onClick={calcDelivery} disabled={deliveryLoading || !addressComplete}>
            {deliveryLoading ? "Calcul…" : "Calculer les frais de livraison"}
          </button>
          <span style={{ color: "var(--steel, #64748b)", fontSize: 13 }}>
            Tarif : {formatPrice(Math.round(DELIVERY_RATE_PER_KM * 100))}/km
          </span>
        </div>
        {deliveryErr && <p style={{ color: "var(--accent-dark)", marginTop: 8, fontWeight: 600 }}>{deliveryErr}</p>}
        {delivery && (
          <p style={{ marginTop: 8 }}>
            Distance estimée : <strong>{delivery.km.toFixed(1)} km</strong> — Frais : <strong>{formatPrice(delivery.feeCents)}</strong>
          </p>
        )}

        <h2 className="section-title" style={{ marginTop: 30, fontSize: 20 }}>Mode de règlement</h2>
        <div className="payment-options">
          <label>
            <input type="radio" name="payment" value="virement" checked readOnly />
            Virement bancaire
          </label>
        </div>
        <div className="notice">
          Aucun paiement en ligne : un récapitulatif de votre commande vous est
          remis immédiatement en PDF, et les coordonnées bancaires pour le
          virement vous seront transmises par email.
        </div>

        <div className="cart-total" style={{ lineHeight: 1.8 }}>
          <div>Sous-total : {formatPrice(cart.total)}</div>
          <div>Livraison : {delivery ? formatPrice(deliveryFeeCents) : "à calculer"}</div>
          <div><strong>Total : {formatPrice(grandTotal) || "sur devis"}</strong></div>
        </div>

        {error && <p style={{ color: "var(--accent-dark)", marginTop: 12, fontWeight: 600 }}>{error}</p>}
        <button
          className="btn-add" style={{ marginTop: 18 }}
          onClick={submit} disabled={submitting}
        >
          {submitting ? "Enregistrement…" : "Confirmer la commande"}
        </button>
      </div>
    </section>
  );
}