"use client";
import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { getOrder, updateOrderStatus, openInvoice } from "@/lib/admin";

const STATUS_LABELS = {
  en_attente: "En attente", facturee: "Facturée", payee: "Payée",
  expediee: "Expédiée", annulee: "Annulée",
};
const PAY_LABELS = {
  virement: "Virement bancaire", cheque: "Chèque",
  livraison: "Règlement à la livraison", especes: "Espèces au retrait",
};
function euro(c){ return new Intl.NumberFormat("fr-FR",{style:"currency",currency:"EUR"}).format((c||0)/100); }

export default function OrderDetail() {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");
  const [err, setErr] = useState("");

  const load = () => getOrder(id).then(setOrder).catch((e) => setErr(e.message));
  useEffect(() => { load(); }, [id]);

  const changeStatus = async (status) => {
    setSaving(true); setMsg(""); setErr("");
    try {
      await updateOrderStatus(id, status);
      await load();
      setMsg("Statut mis à jour.");
    } catch (e) { setErr(e.message); }
    setSaving(false);
  };

  if (err) return <p style={{ color: "var(--accent-dark)" }}>{err}</p>;
  if (!order) return <p>Chargement…</p>;

  return (
    <>
      <p style={{ marginBottom: 14, fontSize: 13.5 }}>
        <Link href="/admin/commandes" style={{ color: "var(--steel)" }}>← Retour aux commandes</Link>
      </p>
      <h1 className="admin-h1">{order.order_number}</h1>

      <div className="detail-grid">
        <div className="panel">
          <h2>Articles</h2>
          <table className="admin-table" style={{ border: "none" }}>
            <thead>
              <tr><th>Désignation</th><th>Réf.</th><th>P.U.</th><th>Qté</th><th>Total</th></tr>
            </thead>
            <tbody>
              {order.items.map((it) => (
                <tr key={it.id}>
                  <td>{it.title}</td>
                  <td>{it.reference || "—"}</td>
                  <td>{euro(it.unit_cents)}</td>
                  <td>{it.quantity}</td>
                  <td>{euro(it.unit_cents * it.quantity)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div style={{ textAlign: "right", marginTop: 14, fontFamily: "var(--font-display)", fontSize: 22, fontWeight: 700 }}>
            Total : {euro(order.total_cents)}
          </div>
        </div>

        <div>
          <div className="panel" style={{ marginBottom: 18 }}>
            <h2>Client</h2>
            <div className="kv"><span>Nom</span><span>{order.customer_name}</span></div>
            <div className="kv"><span>Email</span><span>{order.customer_email}</span></div>
            {order.customer_phone && <div className="kv"><span>Téléphone</span><span>{order.customer_phone}</span></div>}
            <div className="kv"><span>Adresse</span><span style={{ textAlign: "right" }}>{order.address_line}<br />{order.postal_code} {order.city}</span></div>
            <div className="kv"><span>Règlement</span><span>{PAY_LABELS[order.payment_method]}</span></div>
            {order.note && <div className="kv"><span>Note</span><span style={{ textAlign: "right" }}>{order.note}</span></div>}
          </div>

          <div className="panel">
            <h2>Traitement</h2>
            <div style={{ marginBottom: 12 }}>
              <span className={`badge ${order.status}`}>{STATUS_LABELS[order.status]}</span>
            </div>
            <label style={{ fontSize: 13, fontWeight: 600, display: "block", marginBottom: 6 }}>Changer le statut</label>
            <select className="status-select" value={order.status} disabled={saving}
              onChange={(e) => changeStatus(e.target.value)}>
              {order.statuses.map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
            </select>

            <button className="admin-btn primary" style={{ width: "100%", marginTop: 16 }}
              onClick={() => openInvoice(order.id)}>
              📄 Générer la facture PDF
            </button>

            {msg && <p style={{ color: "var(--ok)", fontSize: 13, marginTop: 10 }}>{msg}</p>}
            {err && <p style={{ color: "var(--accent-dark)", fontSize: 13, marginTop: 10 }}>{err}</p>}
          </div>
        </div>
      </div>
    </>
  );
}
