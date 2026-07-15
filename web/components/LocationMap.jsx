// Cible dans le projet : components/LocationMap.jsx
// Carte affichée juste au-dessus du footer, sur toutes les pages (via layout.jsx).
// Utilise l'embed Google Maps public (pas de clé API nécessaire, gratuit).
const ADDRESS = "Avenue Émile Sari, 20200 Bastia, France";
const AGENCY_NAME = "Auto Pièce Corse";

export default function LocationMap() {
  const mapQuery = encodeURIComponent(`${AGENCY_NAME}, ${ADDRESS}`);
  const embedSrc = `https://www.google.com/maps?q=${mapQuery}&output=embed`;
  const directionsHref = `https://www.google.com/maps/search/?api=1&query=${mapQuery}`;

  return (
    <section className="section" style={{ paddingTop: 0 }}>
      <div className="container">
        <h2 className="section-title" style={{ fontSize: 20, marginBottom: 4 }}>Nous trouver</h2>
        <p style={{ color: "var(--steel, #64748b)", marginTop: 0, marginBottom: 16 }}>
          {AGENCY_NAME} — {ADDRESS}
        </p>
        <div
          style={{
            border: "1px solid var(--line, #e2e6ea)",
            borderRadius: 8,
            overflow: "hidden",
          }}
        >
          <iframe
            title={`Localisation ${AGENCY_NAME}`}
            src={embedSrc}
            width="100%"
            height="320"
            style={{ border: 0, display: "block" }}
            loading="lazy"
            referrerPolicy="no-referrer-when-downgrade"
          />
        </div>
        <p style={{ marginTop: 10 }}>
          <a
            href={directionsHref}
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: "var(--accent-dark)", fontWeight: 600, fontSize: 14 }}
          >
            Itinéraire sur Google Maps →
          </a>
        </p>
      </div>
    </section>
  );
}