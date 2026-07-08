const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

export async function getProducts({ page = 1, q = "", category = "" } = {}) {
  const params = new URLSearchParams({ page: String(page), limit: "12" });
  if (q) params.set("q", q);
  if (category) params.set("category", category);
  const res = await fetch(`${API}/api/products?${params}`, { cache: "no-store" });
  if (!res.ok) throw new Error("API produits indisponible");
  return res.json();
}

export async function getProduct(slug) {
  const res = await fetch(`${API}/api/products/${slug}`, { cache: "no-store" });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error("API produit indisponible");
  return res.json();
}

export async function getCategories() {
  const res = await fetch(`${API}/api/categories`, { next: { revalidate: 300 } });
  if (!res.ok) return [];
  return res.json();
}

export async function getFeaturedCategories(limit = 10) {
  const res = await fetch(`${API}/api/categories/featured?limit=${limit}`, { next: { revalidate: 300 } });
  if (!res.ok) return [];
  return res.json();
}

export async function createOrder(payload) {
  const res = await fetch(`${API}/api/orders`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "Erreur lors de la commande");
  return data;
}
