"use client";
import { useEffect, useState, useRef } from "react";
import Link from "next/link";
import { useCart } from "./CartProvider";
import { getCategories } from "@/lib/api";

/**
 * Header — menus déroulants alimentés par la hiérarchie réelle des catégories.
 * L'API /api/categories renvoie les familles (parent_id NULL) avec leurs rayons
 * dans `children`. Aucun mapping en dur : le menu suit la base.
 */
export default function Header() {
  const cart = useCart();
  const [families, setFamilies] = useState([]);
  const [openKey, setOpenKey] = useState(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const closeTimer = useRef(null);

  useEffect(() => {
    getCategories()
      .then((data) => {
        // on ne garde que les familles ayant au moins un rayon
        const fams = (data || []).filter((f) => Array.isArray(f.children) && f.children.length > 0);
        setFamilies(fams);
      })
      .catch(() => {});
  }, []);

  const openMenu = (key) => {
    if (closeTimer.current) clearTimeout(closeTimer.current);
    setOpenKey(key);
  };
  const scheduleClose = () => {
    if (closeTimer.current) clearTimeout(closeTimer.current);
    closeTimer.current = setTimeout(() => setOpenKey(null), 150);
  };

  return (
    <header className="site-header">
      <div className="container">
        <Link href="/" className="logo">Pièces<span>Auto</span></Link>

        {/* Familles (desktop) */}
        <nav className="nav nav-families">
          {families.map((fam) => (
            <div
              key={fam.slug}
              className="family"
              onMouseEnter={() => openMenu(fam.slug)}
              onMouseLeave={scheduleClose}
            >
              <button
                className="family-btn"
                aria-expanded={openKey === fam.slug}
                onClick={() => setOpenKey(openKey === fam.slug ? null : fam.slug)}
              >
                {fam.name} <span className="caret">▾</span>
              </button>

              {openKey === fam.slug && (
                <div className="family-menu" onMouseEnter={() => openMenu(fam.slug)} onMouseLeave={scheduleClose}>
                  {/* Lien "tout voir" : la famille inclut les produits de ses rayons */}
                  <Link
                    href={`/produits?category=${fam.slug}`}
                    className="family-all"
                    onClick={() => setOpenKey(null)}
                  >
                    Tout {fam.name.toLowerCase()}
                    {typeof fam.product_count === "number" && (
                      <span className="family-count">{fam.product_count}</span>
                    )}
                  </Link>

                  {fam.children.map((c) => (
                    <Link key={c.slug} href={`/produits?category=${c.slug}`} onClick={() => setOpenKey(null)}>
                      {c.name}
                      {typeof c.product_count === "number" && (
                        <span className="family-count">{c.product_count}</span>
                      )}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          ))}
        </nav>

        <nav className="nav">
          <Link href="/produits">Catalogue</Link>
          <Link href="/panier" className="cart-link">
            Panier{cart?.count ? ` (${cart.count})` : ""}
          </Link>
          <button className="burger" aria-label="Menu" onClick={() => setMobileOpen((v) => !v)}>☰</button>
        </nav>
      </div>

      {/* Panneau mobile */}
      {mobileOpen && (
        <div className="mobile-menu">
          {families.map((fam) => (
            <details key={fam.slug} className="mobile-family">
              <summary>{fam.name}</summary>
              <div className="mobile-family-items">
                <Link href={`/produits?category=${fam.slug}`} onClick={() => setMobileOpen(false)}>
                  Tout {fam.name.toLowerCase()}
                </Link>
                {fam.children.map((c) => (
                  <Link key={c.slug} href={`/produits?category=${c.slug}`} onClick={() => setMobileOpen(false)}>
                    {c.name}
                  </Link>
                ))}
              </div>
            </details>
          ))}
          <Link href="/produits" className="mobile-link" onClick={() => setMobileOpen(false)}>Tout le catalogue</Link>
        </div>
      )}
    </header>
  );
}