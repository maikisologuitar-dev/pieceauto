"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { getStats } from "@/lib/admin";

function euro(cents) {
  return new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" }).format((cents || 0) / 100);
}

export default function AdminDashboard() {
  const [stats, setStats] = useState(null);
  const [err, setErr] = useState("");

  useEffect(() => {
    getStats().then(setStats).catch((e) => setErr(e.message));
  }, []);

  return (
    <>
      <h1 className="admin-h1">Tableau de bord</h1>
      {err && <p style={{ color: "var(--accent-dark)" }}>{err}</p>}
      {stats && (
        <div className="stat-grid">
          <div className="stat-card">
            <div className="label">Commandes totales</div>
            <div className="value">{stats.orders}</div>
          </div>
          <div className="stat-card accent">
            <div className="label">En attente de traitement</div>
            <div className="value">{stats.pending}</div>
          </div>
          <div className="stat-card">
            <div className="label">Chiffre d'affaires encaissé</div>
            <div className="value">{euro(stats.revenue_cents)}</div>
          </div>
          <div className="stat-card">
            <div className="label">Produits au catalogue</div>
            <div className="value">{stats.products}</div>
          </div>
        </div>
      )}
      <div style={{ display: "flex", gap: 12 }}>
        <Link href="/admin/commandes" className="admin-btn primary">Gérer les commandes</Link>
        <Link href="/admin/produits" className="admin-btn">Gérer les produits</Link>
      </div>
    </>
  );
}
