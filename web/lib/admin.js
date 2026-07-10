"use client";
const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
const TOKEN_KEY = "admin_token";

export function getToken() {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem(TOKEN_KEY);
}
export function setToken(t) { window.localStorage.setItem(TOKEN_KEY, t); }
export function clearToken() { window.localStorage.removeItem(TOKEN_KEY); }

async function authFetch(path, options = {}) {
  const token = getToken();
  const res = await fetch(`${API}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {}),
    },
  });
  if (res.status === 401) {
    clearToken();
    if (typeof window !== "undefined") window.location.href = "/admin/login";
    throw new Error("Session expirée");
  }
  return res;
}

export async function adminLogin(email, password) {
  const res = await fetch(`${API}/api/admin/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "Échec de connexion");
  setToken(data.token);
  return data;
}

export async function getStats() {
  const r = await authFetch("/api/admin/stats"); return r.json();
}
export async function getOrders(status = "") {
  const r = await authFetch(`/api/admin/orders${status ? `?status=${status}` : ""}`); return r.json();
}
export async function getOrder(id) {
  const r = await authFetch(`/api/admin/orders/${id}`); return r.json();
}
export async function updateOrderStatus(id, status) {
  const r = await authFetch(`/api/admin/orders/${id}`, { method: "PATCH", body: JSON.stringify({ status }) });
  return r.json();
}
export function invoiceUrl(id) {
  return `${API}/api/admin/orders/${id}/invoice`;
}
export async function getAdminProducts(q = "") {
  const r = await authFetch(`/api/admin/products${q ? `?q=${encodeURIComponent(q)}` : ""}`); return r.json();
}
export async function updateProduct(id, patch) {
  const r = await authFetch(`/api/admin/products/${id}`, { method: "PATCH", body: JSON.stringify(patch) });
  return r.json();
}

// --- Chantier 3 : création de produit + listes pour le formulaire ---
export async function getAdminCategories() {
  const r = await authFetch("/api/admin/categories");
  return r.json();
}
export async function getAdminBrands() {
  const r = await authFetch("/api/admin/brands");
  return r.json();
}
export async function createProduct(payload) {
  const r = await authFetch("/api/admin/products", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  const data = await r.json();
  if (!r.ok) throw new Error(data.error || "Échec de la création du produit");
  return data;
}

// Upload d'images vers l'API (multipart). On NE force PAS le Content-Type :
// le navigateur pose lui-même le boundary. On ajoute juste le token.
export async function uploadImages(files) {
  const token = getToken();
  const fd = new FormData();
  for (const f of files) fd.append("files", f);
  const res = await fetch(`${API}/api/admin/upload`, {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    body: fd,
  });
  if (res.status === 401) {
    clearToken();
    if (typeof window !== "undefined") window.location.href = "/admin/login";
    throw new Error("Session expirée");
  }
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "Échec de l'upload");
  return data.urls || [];
}

// Images d'un produit existant : lecture + remplacement complet
export async function getProductImages(id) {
  const r = await authFetch(`/api/admin/products/${id}/images`);
  const data = await r.json();
  return data.images || [];
}
export async function replaceProductImages(id, images) {
  const r = await authFetch(`/api/admin/products/${id}/images`, {
    method: "PUT",
    body: JSON.stringify({ images }),
  });
  const data = await r.json();
  if (!r.ok) throw new Error(data.error || "Échec de la mise à jour des images");
  return data;
}

// Catégories d'un produit existant : lecture + remplacement complet
export async function getProductCategories(id) {
  const r = await authFetch(`/api/admin/products/${id}/categories`);
  const data = await r.json();
  return data.category_ids || [];
}
export async function replaceProductCategories(id, categoryIds) {
  const r = await authFetch(`/api/admin/products/${id}/categories`, {
    method: "PUT",
    body: JSON.stringify({ category_ids: categoryIds }),
  });
  const data = await r.json();
  if (!r.ok) throw new Error(data.error || "Échec de la mise à jour des catégories");
  return data;
}

// Image d'ambiance d'un rayon (catégorie)
export async function updateCategoryImage(id, imageUrl) {
  const r = await authFetch(`/api/admin/categories/${id}`, {
    method: "PATCH",
    body: JSON.stringify({ image_url: imageUrl }),
  });
  const data = await r.json();
  if (!r.ok) throw new Error(data.error || "Échec de la mise à jour du rayon");
  return data;
}

// Ouvre la facture PDF avec le token en header (via blob)
export async function openInvoice(id) {
  const r = await authFetch(`/api/admin/orders/${id}/invoice`);
  const blob = await r.blob();
  const url = URL.createObjectURL(blob);
  window.open(url, "_blank");
}