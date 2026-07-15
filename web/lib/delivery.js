// Frais de livraison calculés côté client : distance boutique -> adresse client x tarif au km.
//
// Coordonnées de la boutique = celles de ton point Google Maps (Auto Pièce Corse, Bastia).
// Si tu déplaces la boutique, mets à jour SHOP.lat / SHOP.lng ici.
export const SHOP = {
  name: "Auto Pièce Corse",
  lat: 42.7040265,
  lng: 9.4518763,
};

// Tarif au kilomètre, en euros. 0,02 € => 2 € pour 100 km.
export const DELIVERY_RATE_PER_KM = 0.02;

// Distance « à vol d'oiseau » (Haversine), en km.
export function haversineKm(a, b) {
  const R = 6371;
  const toRad = (d) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

// Géocodage gratuit via Nominatim (OpenStreetMap), sans clé API.
// Convertit l'adresse saisie en coordonnées.
export async function geocodeAddress({ address_line, postal_code, city }) {
  const q = [address_line, postal_code, city, "France"].filter(Boolean).join(", ");
  const url =
    "https://nominatim.openstreetmap.org/search?format=json&limit=1&q=" +
    encodeURIComponent(q);
  const res = await fetch(url, { headers: { Accept: "application/json" } });
  if (!res.ok) throw new Error("Service de géolocalisation indisponible.");
  const data = await res.json();
  if (!Array.isArray(data) || data.length === 0) {
    throw new Error("Adresse introuvable. Vérifiez l'adresse, le code postal et la ville.");
  }
  return { lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon) };
}

// Renvoie { km, feeCents } pour une adresse client.
export async function computeDelivery(address) {
  const dest = await geocodeAddress(address);
  const km = haversineKm(SHOP, dest);
  const feeCents = Math.round(km * DELIVERY_RATE_PER_KM * 100);
  return { km, feeCents, dest };
}