import Link from "next/link";
import { formatPrice } from "@/lib/format";

export default function ProductCard({ product }) {
  const price = formatPrice(product.price_cents);
  return (
    <Link href={`/produits/${product.slug}`} className="card">
      <div className="card-img">
        {product.image
          ? <img src={product.image} alt={product.title} loading="lazy" />
          : <span style={{ color: "var(--steel)", fontSize: 13 }}>Photo à venir</span>}
      </div>
      <div className="card-body">
        {product.reference && <span className="ref-tag">RÉF {product.reference}</span>}
        <div className="card-title">{product.title}</div>
        {price
          ? <div className="price">{price}</div>
          : <div className="price on-request">Prix sur demande</div>}
      </div>
    </Link>
  );
}
