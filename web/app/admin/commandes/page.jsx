"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { getOrders } from "@/lib/admin";

const STATUS_LABELS = {
  en_attente: "En attente", facturee: "Facturée", payee: "Payée",
  expediee: "Expédiée", annulee: "Annulée",
};
const PAY_LABELS = {
  virement: "Virement", cheque: "Chèque", livraison: "À la livraison", especes: "Espèces",
};
function euro(c){ return new Intl.NumberFormat("fr-FR",{style:"currency",currency:"EUR"}).format((c||0)/100); }
function dateFr(d){ return new Date(d).toLocaleDateString("fr-FR"); }

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [filter, setFilter] = useState("");
  const [err, setErr] = useState("");

  const load = (status) => {
    getOrders(status).then(setOrders).catch((e) => setErr(e.message));
  };
  useEffect(() => { load(filter); }, [filter]);

  const filters = ["", "en_attente", "facturee", "payee", "expediee", "annulee"];

  return (
    <>
      <h1 className="admin-h1">Commandes</h1>
      {err && <p style={{ color: "var(--accent-dark)" }}>{err}</p>}

      <div className="admin-filters">
        {filters.map((f) => (
          <button key={f || "all"} className={filter === f ? "active" : ""} onClick={() => setFilter(f)}>
            {f ? STATUS_LABELS[f] : "Toutes"}
          </button>
        ))}
      </div>

      {orders.length ? (
        <table className="admin-table">
          <thead>
            <tr><th>N° commande</th><th>Client</th><th>Règlement</th><th>Total</th><th>Statut</th><th>Date</th></tr>
          </thead>
          <tbody>
            {orders.map((o) => (
              <tr key={o.id}>
                <td><Link href={`/admin/commandes/${o.id}`}>{o.order_number}</Link></td>
                <td>{o.customer_name}</td>
                <td>{PAY_LABELS[o.payment_method] || o.payment_method}</td>
                <td>{euro(o.total_cents)}</td>
                <td><span className={`badge ${o.status}`}>{STATUS_LABELS[o.status]}</span></td>
                <td>{dateFr(o.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p style={{ color: "var(--steel)" }}>Aucune commande pour ce filtre.</p>
      )}
    </>
  );
}
