// Frais de livraison calculés côté client : distance boutique -> adresse client x tarif au km.
//
// Coordonnées de la boutique = celles de ton point Google Maps (Auto Pièce Corse, Bastia).
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

// Appel Nominatim pour une requête texte donnée. Renvoie {lat,lng} ou null.
async function nominatim(q) {
  const url =
    "https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=fr&q=" +
    encodeURIComponent(q);
  const res = await fetch(url, { headers: { Accept: "application/json" } });
  if (!res.ok) return null;
  const data = await res.json();
  if (!Array.isArray(data) || data.length === 0) return null;
  return { lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon) };
}

// Géocodage TOLÉRANT : on tente l'adresse complète, puis on retombe
// progressivement sur des requêtes moins précises jusqu'à trouver un lieu.
// L'ordre garantit qu'on utilise l'info la plus précise disponible.
export async function geocodeAddress({ address_line, postal_code, city }) {
  const attempts = [
    [address_line, postal_code, city, "France"],       // adresse complète
    [postal_code, city, "France"],                     // code postal + ville
    [city, "France"],                                  // ville seule
    [postal_code, "France"],                           // code postal seul
  ];

  for (const parts of attempts) {
    const q = parts.filter(Boolean).join(", ");
    if (!q) continue;
    const hit = await nominatim(q);
    if (hit) return hit;
  }
  throw new Error("Adresse introuvable. Vérifiez le code postal et la ville.");
}

// Renvoie { km, feeCents } pour une adresse client.
export async function computeDelivery(address) {
  const dest = await geocodeAddress(address);
  const km = haversineKm(SHOP, dest);
  const feeCents = Math.round(km * DELIVERY_RATE_PER_KM * 100);
  return { km, feeCents, dest };
}