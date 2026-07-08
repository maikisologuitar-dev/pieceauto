import { notFound } from "next/navigation";
import Link from "next/link";
import { getProduct } from "@/lib/api";
import { formatPrice } from "@/lib/format";
import AddToCartButton from "@/components/AddToCartButton";

export default async function ProductPage({ params }) {
  const { slug } = await params;
  let product = null;
  try {
    product = await getProduct(slug);
  } catch {}
  if (!product) notFound();

  const price = formatPrice(product.price_cents);
  const features = Array.isArray(product.features) ? product.features : [];

  return (
    <section className="section">
      <div className="container">
        <p style={{ marginBottom: 18, fontSize: 13.5 }}>
          <Link href="/produits" style={{ color: "var(--steel)" }}>← Retour au catalogue</Link>
        </p>

        <div className="product-layout">
          <div>
            <div className="gallery-main">
              {product.images?.[0]
                ? <img src={product.images[0]} alt={product.title} />
                : <span style={{ color: "var(--steel)" }}>Photo à venir</span>}
            </div>
            {product.images?.length > 1 && (
              <div className="gallery-thumbs">
                {product.images.slice(1, 6).map((url) => (
                  <img key={url} src={url} alt="" loading="lazy" />
                ))}
              </div>
            )}
          </div>

          <div className="product-info">
            {product.reference && <span className="ref-tag">RÉF {product.reference}</span>}
            <h1>{product.title}</h1>

            {product.categories?.length > 0 && (
              <p style={{ fontSize: 13, color: "var(--steel)" }}>
                {product.categories.map((c, i) => (
                  <span key={c.slug}>
                    {i > 0 && " · "}
                    <Link href={`/produits?category=${c.slug}`}>{c.name}</Link>
                  </span>
                ))}
              </p>
            )}

            {price ? (
              <>
                <div className="price">{price}</div>
                <p className="tva-note">TTC — TVA 20 % incluse</p>
              </>
            ) : (
              <>
                <div className="price on-request" style={{ fontSize: 20, margin: "18px 0 4px" }}>
                  Prix sur demande
                </div>
                <p className="tva-note">Un devis vous sera transmis avec la facture.</p>
              </>
            )}

            {features.length > 0 && (
              <ul className="features">
                {features.map((f) => <li key={f}>{f}</li>)}
              </ul>
            )}

            <AddToCartButton product={product} />

            <div className="notice">
              Règlement <strong>hors ligne</strong> : après votre commande, nous vous
              transmettons la facture par email. Paiement par virement bancaire,
              chèque, à la livraison ou espèces au retrait.
            </div>
          </div>
        </div>

        {product.long_desc && (
          <div className="desc">
            <h2>Description</h2>
            <p>{product.long_desc}</p>
          </div>
        )}
      </div>
    </section>
  );
}
