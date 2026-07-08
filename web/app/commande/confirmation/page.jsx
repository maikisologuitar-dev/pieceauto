import Link from "next/link";
import { PAYMENT_LABELS } from "@/lib/format";

export const metadata = { title: "Commande confirmée — PiècesAuto" };

export default async function ConfirmationPage({ searchParams }) {
  const sp = await searchParams;
  const orderNumber = sp?.n || "";
  const payment = PAYMENT_LABELS[sp?.p] || null;

  return (
    <section className="section">
      <div className="container">
        <div className="confirm-box">
          <h1 style={{ fontFamily: "var(--font-display)", textTransform: "uppercase" }}>
            Commande enregistrée ✓
          </h1>
          {orderNumber && <div className="order-num">{orderNumber}</div>}
          <p>
            Merci pour votre commande. Vous recevrez votre <strong>facture par
            email</strong> avec les instructions de règlement
            {payment ? <> ({payment.toLowerCase()})</> : null}.
          </p>
          <p style={{ marginTop: 18 }}>
            <Link href="/produits" style={{ color: "var(--accent-dark)", fontWeight: 600 }}>
              ← Continuer mes achats
            </Link>
          </p>
        </div>
      </div>
    </section>
  );
}
