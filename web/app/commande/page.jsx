"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useCart } from "@/components/CartProvider";
import { createOrder } from "@/lib/api";
import { formatPrice, PAYMENT_LABELS } from "@/lib/format";

export default function CheckoutPage() {
  const cart = useCart();
  const router = useRouter();
  const [form, setForm] = useState({
    name: "", email: "", phone: "",
    address_line: "", postal_code: "", city: "", note: "",
  });
  const [payment, setPayment] = useState("virement");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

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

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const submit = async () => {
    setError("");
    if (!form.name || !form.email || !form.address_line || !form.postal_code || !form.city) {
      setError("Merci de remplir tous les champs obligatoires (*).");
      return;
    }
    setSubmitting(true);
    try {
      const res = await createOrder({
        customer: form,
        payment_method: payment,
        note: form.note,
        items: cart.items.map((i) => ({ product_id: i.product_id, quantity: i.quantity })),
      });
      cart.clear();
      router.push(`/commande/confirmation?n=${encodeURIComponent(res.order_number)}&p=${payment}`);
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

        <h2 className="section-title" style={{ marginTop: 30, fontSize: 20 }}>Mode de règlement</h2>
        <div className="payment-options">
          {Object.entries(PAYMENT_LABELS).map(([value, label]) => (
            <label key={value}>
              <input
                type="radio" name="payment" value={value}
                checked={payment === value}
                onChange={() => setPayment(value)}
              />
              {label}
            </label>
          ))}
        </div>

        <div className="notice">
          Aucun paiement en ligne : la facture correspondant à votre commande vous
          sera transmise par email avec les instructions de règlement
          ({PAYMENT_LABELS[payment].toLowerCase()}).
        </div>

        <div className="cart-total">Total : {formatPrice(cart.total) || "sur devis"}</div>

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
