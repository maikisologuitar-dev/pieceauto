import Link from "next/link";
import { formatPrice } from "@/lib/format";

// Extrait une contenance (volume) du titre pour l'afficher en pastille.
// On ne garde que ml / cl / L (les vraies contenances produit), pas les
// grammages de serviettes ni les dimensions. Ex. "… 500ml" -> "500ML".
function extractSize(title = "") {
  const re = /\b(\d+(?:[.,]\d+)?)\s?(ml|cl|l)\b/gi;
  let m;
  let last = null;
  while ((m = re.exec(title)) !== null) last = m;
  if (!last) return null;
  const num = last[1];
  const unit = last[2].toLowerCase();
  return unit === "l" ? `${num}L` : `${num}${unit.toUpperCase()}`;
}

export default function ProductCard({ product }) {
  const price = formatPrice(product.price_cents);
  const size = extractSize(product.title);
  return (
    <Link href={`/produits/${product.slug}`} className="card">
      <div className="card-img">
        {size && <span className="size-badge">{size}</span>}
        {product.image
          ? <img src={product.image} alt={product.title} loading="lazy" />
          : <span style={{ color: "var(--steel)", fontSize: 13 }}>Photo à venir</span>}
      </div>
      <div className="card-body">
        <div className="card-tags">
          {product.reference && <span className="ref-tag">RÉF {product.reference}</span>}
          {product.brand && <span className="brand-tag">{product.brand}</span>}
        </div>
        <div className="card-title">{product.title}</div>
        {price
          ? <div className="price">{price}</div>
          : <div className="price on-request">Prix sur demande</div>}
      </div>
    </Link>
  );
}