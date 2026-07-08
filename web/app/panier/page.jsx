"use client";
import Link from "next/link";
import { useCart } from "@/components/CartProvider";
import { formatPrice } from "@/lib/format";

export default function CartPage() {
  const cart = useCart();
  if (!cart) return null;

  if (!cart.items.length) {
    return (
      <section className="section">
        <div className="container">
          <h1 className="section-title">Panier</h1>
          <p className="empty">
            Votre panier est vide. <Link href="/produits" style={{ color: "var(--accent-dark)", fontWeight: 600 }}>Parcourir le catalogue →</Link>
          </p>
        </div>
      </section>
    );
  }

  const hasOnRequest = cart.items.some((i) => !i.price_cents);

  return (
    <section className="section">
      <div className="container">
        <h1 className="section-title">Panier</h1>

        <table className="cart-table">
          <thead>
            <tr>
              <th>Pièce</th><th>Réf.</th><th>Prix unitaire</th><th>Qté</th><th>Sous-total</th><th></th>
            </tr>
          </thead>
          <tbody>
            {cart.items.map((i) => (
              <tr key={i.product_id}>
                <td><Link href={`/produits/${i.slug}`}>{i.title}</Link></td>
                <td>{i.reference ? <span className="ref-tag">{i.reference}</span> : "—"}</td>
                <td>{formatPrice(i.price_cents) || "Sur demande"}</td>
                <td>
                  <input
                    className="qty-input" type="number" min="1" value={i.quantity}
                    onChange={(e) => cart.setQty(i.product_id, parseInt(e.target.value) || 1)}
                    aria-label={`Quantité pour ${i.title}`}
                  />
                </td>
                <td>{formatPrice(i.price_cents * i.quantity) || "—"}</td>
                <td>
                  <button className="remove-btn" onClick={() => cart.remove(i.product_id)}>
                    Retirer
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="cart-total">
          Total : {formatPrice(cart.total) || "—"}
          {hasOnRequest && (
            <div style={{ fontSize: 13, fontFamily: "var(--font-body)", fontWeight: 400, color: "var(--steel)" }}>
              Certaines pièces sont à prix sur demande : le total définitif figurera sur la facture.
            </div>
          )}
        </div>

        <div style={{ textAlign: "right", marginTop: 20 }}>
          <Link href="/commande" className="cta" style={{
            background: "var(--accent)", color: "#fff", padding: "13px 30px",
            borderRadius: 4, fontWeight: 700, display: "inline-block",
          }}>
            Passer la commande
          </Link>
        </div>
      </div>
    </section>
  );
}
