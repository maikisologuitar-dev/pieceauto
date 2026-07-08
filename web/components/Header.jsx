"use client";
import Link from "next/link";
import { useCart } from "./CartProvider";

export default function Header() {
  const cart = useCart();
  return (
    <header className="site-header">
      <div className="container">
        <Link href="/" className="logo">Pièces<span>Auto</span></Link>
        <nav className="nav">
          <Link href="/produits">Catalogue</Link>
          <Link href="/panier" className="cart-link">
            Panier{cart?.count ? ` (${cart.count})` : ""}
          </Link>
        </nav>
      </div>
    </header>
  );
}
