"use client";
import { createContext, useContext, useEffect, useState } from "react";

const CartContext = createContext(null);
export const useCart = () => useContext(CartContext);

export default function CartProvider({ children }) {
  const [items, setItems] = useState([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    try {
      const saved = window.localStorage.getItem("cart");
      if (saved) setItems(JSON.parse(saved));
    } catch {}
    setLoaded(true);
  }, []);

  useEffect(() => {
    if (loaded) {
      try { window.localStorage.setItem("cart", JSON.stringify(items)); } catch {}
    }
  }, [items, loaded]);

  const add = (product, qty = 1) =>
    setItems((prev) => {
      const found = prev.find((i) => i.product_id === product.id);
      if (found) {
        return prev.map((i) =>
          i.product_id === product.id ? { ...i, quantity: i.quantity + qty } : i
        );
      }
      return [...prev, {
        product_id: product.id,
        slug: product.slug,
        title: product.title,
        reference: product.reference,
        price_cents: product.price_cents,
        image: product.images?.[0] || product.image || null,
        quantity: qty,
      }];
    });

  const setQty = (productId, qty) =>
    setItems((prev) => prev.map((i) =>
      i.product_id === productId ? { ...i, quantity: Math.max(1, qty) } : i
    ));

  const remove = (productId) =>
    setItems((prev) => prev.filter((i) => i.product_id !== productId));

  const clear = () => setItems([]);

  const count = items.reduce((s, i) => s + i.quantity, 0);
  const total = items.reduce((s, i) => s + i.price_cents * i.quantity, 0);

  return (
    <CartContext.Provider value={{ items, add, setQty, remove, clear, count, total }}>
      {children}
    </CartContext.Provider>
  );
}
