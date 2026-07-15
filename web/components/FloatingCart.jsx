"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useCart } from "@/components/CartProvider";
import { formatPrice } from "@/lib/format";

export default function FloatingCart() {
  const cart = useCart();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  // Fermer avec la touche Échap
  useEffect(() => {
    if (!open) return;
    const onKey = (e) => e.key === "Escape" && setOpen(false);
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);

  // Bloquer le scroll de la page quand le volet est ouvert
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  // Pas de panier flottant dans l'admin, ni sur les pages panier / commande
  if (!cart) return null;
  if (pathname?.startsWith("/admin")) return null;
  if (pathname === "/panier" || pathname?.startsWith("/commande")) return null;

  const { items, count, total, setQty, remove } = cart;

  return (
    <>
      {/* Bouton flottant : visible seulement quand le panier n'est pas vide */}
      {count > 0 && (
        <button
          type="button"
          aria-label={`Ouvrir le panier (${count} article${count > 1 ? "s" : ""})`}
          onClick={() => setOpen(true)}
          style={{
            position: "fixed",
            right: 20,
            bottom: 20,
            zIndex: 1000,
            width: 60,
            height: 60,
            borderRadius: "50%",
            border: "none",
            cursor: "pointer",
            background: "var(--accent-dark, #b3261e)",
            color: "#fff",
            boxShadow: "0 6px 20px rgba(0,0,0,0.25)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="9" cy="21" r="1" />
            <circle cx="20" cy="21" r="1" />
            <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
          </svg>
          <span
            style={{
              position: "absolute",
              top: -4,
              right: -4,
              minWidth: 22,
              height: 22,
              padding: "0 6px",
              borderRadius: 11,
              background: "#fff",
              color: "var(--accent-dark, #b3261e)",
              fontSize: 12,
              fontWeight: 700,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              border: "2px solid var(--accent-dark, #b3261e)",
            }}
          >
            {count}
          </span>
        </button>
      )}

      {/* Fond sombre */}
      <div
        onClick={() => setOpen(false)}
        style={{
          position: "fixed",
          inset: 0,
          zIndex: 1001,
          background: "rgba(0,0,0,0.45)",
          opacity: open ? 1 : 0,
          pointerEvents: open ? "auto" : "none",
          transition: "opacity 0.25s ease",
        }}
      />

      {/* Volet latéral */}
      <aside
        role="dialog"
        aria-label="Panier"
        style={{
          position: "fixed",
          top: 0,
          right: 0,
          zIndex: 1002,
          height: "100%",
          width: 380,
          maxWidth: "90vw",
          background: "#fff",
          boxShadow: "-4px 0 24px rgba(0,0,0,0.18)",
          transform: open ? "translateX(0)" : "translateX(100%)",
          transition: "transform 0.28s ease",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <header
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "16px 18px",
            borderBottom: "1px solid var(--line, #e2e6ea)",
          }}
        >
          <strong style={{ fontSize: 17 }}>
            Mon panier {count > 0 && `(${count})`}
          </strong>
          <button
            type="button"
            aria-label="Fermer"
            onClick={() => setOpen(false)}
            style={{ background: "none", border: "none", fontSize: 24, cursor: "pointer", lineHeight: 1, color: "var(--steel, #64748b)" }}
          >
            ×
          </button>
        </header>

        <div style={{ flex: 1, overflowY: "auto", padding: 12 }}>
          {items.length === 0 ? (
            <p style={{ color: "var(--steel, #64748b)", textAlign: "center", marginTop: 32 }}>
              Votre panier est vide.
            </p>
          ) : (
            items.map((i) => (
              <div
                key={i.product_id}
                style={{
                  display: "flex",
                  gap: 10,
                  padding: "10px 4px",
                  borderBottom: "1px solid var(--line, #e2e6ea)",
                }}
              >
                <div
                  style={{
                    width: 56,
                    height: 56,
                    flexShrink: 0,
                    borderRadius: 6,
                    background: "#f4f6f8",
                    overflow: "hidden",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  {i.image ? (
                    <img src={i.image} alt={i.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                  ) : (
                    <span style={{ fontSize: 10, color: "var(--steel, #64748b)" }}>—</span>
                  )}
                </div>

                <div style={{ flex: 1, minWidth: 0 }}>
                  <Link
                    href={`/produits/${i.slug}`}
                    onClick={() => setOpen(false)}
                    style={{ fontWeight: 600, fontSize: 13, color: "inherit", textDecoration: "none", display: "block" }}
                  >
                    {i.title}
                  </Link>
                  {i.reference && (
                    <div style={{ fontSize: 11, color: "var(--steel, #64748b)" }}>RÉF {i.reference}</div>
                  )}

                  <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 6 }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                      <button
                        type="button"
                        aria-label="Diminuer"
                        onClick={() => setQty(i.product_id, i.quantity - 1)}
                        style={qtyBtn}
                      >
                        −
                      </button>
                      <span style={{ minWidth: 20, textAlign: "center", fontSize: 13 }}>{i.quantity}</span>
                      <button
                        type="button"
                        aria-label="Augmenter"
                        onClick={() => setQty(i.product_id, i.quantity + 1)}
                        style={qtyBtn}
                      >
                        +
                      </button>
                    </div>
                    <strong style={{ fontSize: 13 }}>{formatPrice(i.price_cents * i.quantity)}</strong>
                  </div>
                </div>

                <button
                  type="button"
                  aria-label="Retirer"
                  onClick={() => remove(i.product_id)}
                  style={{ background: "none", border: "none", cursor: "pointer", color: "var(--steel, #64748b)", fontSize: 18, alignSelf: "flex-start" }}
                >
                  ×
                </button>
              </div>
            ))
          )}
        </div>

        {items.length > 0 && (
          <footer style={{ padding: 16, borderTop: "1px solid var(--line, #e2e6ea)" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 12, fontSize: 16 }}>
              <span>Sous-total</span>
              <strong>{formatPrice(total)}</strong>
            </div>
            <Link
              href="/commande"
              onClick={() => setOpen(false)}
              style={{
                display: "block",
                textAlign: "center",
                padding: "12px 16px",
                borderRadius: 6,
                background: "var(--accent-dark, #b3261e)",
                color: "#fff",
                fontWeight: 600,
                textDecoration: "none",
              }}
            >
              Passer la commande
            </Link>
            <Link
              href="/panier"
              onClick={() => setOpen(false)}
              style={{
                display: "block",
                textAlign: "center",
                padding: "10px 16px",
                marginTop: 8,
                borderRadius: 6,
                border: "1px solid var(--line, #e2e6ea)",
                color: "inherit",
                textDecoration: "none",
                fontSize: 14,
              }}
            >
              Voir le panier
            </Link>
          </footer>
        )}
      </aside>
    </>
  );
}

const qtyBtn = {
  width: 26,
  height: 26,
  borderRadius: 4,
  border: "1px solid var(--line, #e2e6ea)",
  background: "#fff",
  cursor: "pointer",
  fontSize: 16,
  lineHeight: 1,
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
};