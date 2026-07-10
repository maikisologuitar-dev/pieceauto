"use client";
import { useEffect, useState, useRef } from "react";
import Link from "next/link";
import { useCart } from "./CartProvider";
import { getCategories } from "@/lib/api";

// Regroupement des rayons en 3 familles (par nom de catégorie).
// Tout rayon non listé ici retombe automatiquement dans "Accessoires".
const FAMILIES = [
  {
    key: "exterieur",
    label: "Entretien extérieur",
    rayons: [
      "Shampoings & Mousses", "Nettoyants jantes", "Pneus (nettoyant & dressing)",
      "Cires & Protections", "Polish & Lustrage", "Quick Detailers",
      "Insectes", "Dégivrants & Antigel", "Préparation & Décontamination",
    ],
  },
  {
    key: "interieur",
    label: "Entretien intérieur",
    rayons: [
      "Cuir & Alcantara", "Textiles & Tapis", "Plastiques & Dressing",
      "Cockpit & Tableau de bord", "Nettoyants vitres",
      "Parfums & Désodorisants", "Multi-usages (APC)",
    ],
  },
  {
    key: "accessoires",
    label: "Accessoires",
    rayons: [
      "Microfibres & Applicateurs", "Seaux & Matériel de lavage",
      "Outillage & Divers", "Kits & Coffrets",
    ],
  },
];

function buildFamilies(categories) {
  const byName = new Map(categories.map((c) => [c.name, c]));
  const used = new Set();
  const result = FAMILIES.map((fam) => {
    const items = [];
    for (const name of fam.rayons) {
      const c = byName.get(name);
      if (c) { items.push(c); used.add(name); }
    }
    return { ...fam, items };
  });
  // rayons non mappés -> dans Accessoires
  const extras = categories.filter((c) => !used.has(c.name));
  if (extras.length) {
    const acc = result.find((f) => f.key === "accessoires");
    acc.items.push(...extras);
  }
  return result.filter((f) => f.items.length > 0);
}

export default function Header() {
  const cart = useCart();
  const [families, setFamilies] = useState([]);
  const [openKey, setOpenKey] = useState(null);   // desktop : famille survolée/ouverte
  const [mobileOpen, setMobileOpen] = useState(false);
  const closeTimer = useRef(null);

  useEffect(() => {
    getCategories()
      .then((cats) => setFamilies(buildFamilies(cats || [])))
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

        {/* Menu familles (desktop) */}
        <nav className="nav nav-families">
          {families.map((fam) => (
            <div
              key={fam.key}
              className="family"
              onMouseEnter={() => openMenu(fam.key)}
              onMouseLeave={scheduleClose}
            >
              <button
                className="family-btn"
                aria-expanded={openKey === fam.key}
                onClick={() => setOpenKey(openKey === fam.key ? null : fam.key)}
              >
                {fam.label} <span className="caret">▾</span>
              </button>
              {openKey === fam.key && (
                <div className="family-menu" onMouseEnter={() => openMenu(fam.key)} onMouseLeave={scheduleClose}>
                  {fam.items.map((c) => (
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
          {/* Bouton menu mobile */}
          <button className="burger" aria-label="Menu" onClick={() => setMobileOpen((v) => !v)}>☰</button>
        </nav>
      </div>

      {/* Panneau mobile : familles repliables */}
      {mobileOpen && (
        <div className="mobile-menu">
          {families.map((fam) => (
            <details key={fam.key} className="mobile-family">
              <summary>{fam.label}</summary>
              <div className="mobile-family-items">
                {fam.items.map((c) => (
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