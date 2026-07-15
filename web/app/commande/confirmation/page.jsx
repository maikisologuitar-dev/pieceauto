// Cible dans le projet : app/commande/confirmation/page.jsx
import Link from "next/link";
import ReceiptButton from "@/components/ReceiptButton";
import PaymentProofPanel from "@/components/PaymentProofPanel";
import { getPaymentInfo } from "@/lib/api";


export const metadata = { title: "Commande confirmée — PiècesAuto" };

export default async function ConfirmationPage({ searchParams }) {
  const sp = await searchParams;
  const orderNumber = sp?.n || "";
  const token = sp?.t || "";
  const bank = orderNumber && token ? await getPaymentInfo() : null;

  return (
    <section className="section">
      <div className="container">
        <div className="confirm-box">
          <h1 style={{ fontFamily: "var(--font-display)", textTransform: "uppercase" }}>
            Commande enregistrée ✓
          </h1>
          {orderNumber && <div className="order-num">{orderNumber}</div>}
          <p>
            Merci pour votre commande. Les <strong>coordonnées bancaires</strong> pour
            le règlement par virement sont indiquées ci-dessous.
          </p>

          {orderNumber && token && bank && (
            <PaymentProofPanel orderNumber={orderNumber} token={token} bank={bank} />
          )}

          {orderNumber && token && (
            <div style={{ marginTop: 22 }}>
              <ReceiptButton orderNumber={orderNumber} token={token} />
             
              <p style={{ color: "var(--steel, #64748b)", fontSize: 13, marginTop: 8 }}>
                Conservez ce reçu : il récapitule votre commande.
              </p>
            </div>
          )}

          <p style={{ marginTop: 22 }}>
            <Link href="/produits" style={{ color: "var(--accent-dark)", fontWeight: 600 }}>
              ← Continuer mes achats
            </Link>
          </p>
        </div>
      </div>
    </section>
  );
}