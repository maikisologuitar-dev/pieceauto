// Cible dans le projet : app/admin/parametres/page.jsx
"use client";
import AdminPaymentSettings from "@/components/AdminPaymentSettings";

export default function AdminParametresPage() {
  return (
    <>
      <h1 className="admin-h1">Paramètres</h1>
      <AdminPaymentSettings />
    </>
  );
}