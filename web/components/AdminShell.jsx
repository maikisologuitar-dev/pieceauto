"use client";
import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { getToken, clearToken } from "@/lib/admin";

export default function AdminShell({ children }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (pathname === "/admin/login") { setReady(true); return; }
    if (!getToken()) { router.replace("/admin/login"); return; }
    setReady(true);
  }, [pathname, router]);

  if (!ready) return null;
  if (pathname === "/admin/login") return <>{children}</>;

  const logout = () => { clearToken(); router.replace("/admin/login"); };

  return (
    <div className="admin-shell">
      <div className="admin-topbar">
        <span className="brand">Pièces<span>Auto</span> · Admin</span>
        <nav>
          <Link href="/admin">Tableau de bord</Link>
          <Link href="/admin/commandes">Commandes</Link>
          <Link href="/admin/produits">Produits</Link>
        </nav>
        <div className="spacer" />
        <Link href="/" style={{ fontSize: 13, opacity: 0.8 }}>Voir la boutique ↗</Link>
        <button className="admin-logout" onClick={logout}>Déconnexion</button>
      </div>
      <div className="admin-main">{children}</div>
    </div>
  );
}
