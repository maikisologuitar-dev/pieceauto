"use client";
import { useState } from "react";
import { useCart } from "./CartProvider";

export default function AddToCartButton({ product }) {
  const cart = useCart();
  const [added, setAdded] = useState(false);

  const handleClick = () => {
    cart.add(product, 1);
    setAdded(true);
    setTimeout(() => setAdded(false), 1600);
  };

  return (
    <button className="btn-add" onClick={handleClick}>
      {added ? "✓ Ajouté au panier" : "Ajouter au panier"}
    </button>
  );
}
