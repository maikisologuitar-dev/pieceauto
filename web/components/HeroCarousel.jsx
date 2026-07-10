"use client";
import { useState, useEffect, useCallback, useRef } from "react";
import Link from "next/link";

/**
 * HeroCarousel — carrousel plein largeur auto-rotatif.
 * Auto-défilement (pause au survol / focus), flèches, points cliquables,
 * clavier (← →), respect de prefers-reduced-motion.
 * Prend en charge une image de fond (image) et une slide promo à compteur animé.
 */
const IMG_PIECES =
  "https://res.cloudinary.com/jewjfeup/image/upload/v1783677205/4dd121ab1880c8db81e4b7546e1cc2a9_htvmsn.jpg";
const IMG_PROMO =
  "https://res.cloudinary.com/jewjfeup/image/upload/v1783678260/Where_to_find_cheap_car_parts_online_for_every_4_xvziyz.jpg";
const IMG_SERVICE =
  "https://res.cloudinary.com/jewjfeup/image/upload/v1783678259/191191946666421717_ovcu84.jpg";

const SLIDES = [
  {
    eyebrow: "Pièces & équipements",
    title: "Toutes vos pièces auto,\nau meilleur prix",
    text: "Freinage, moteur, éclairage, accessoires : un large choix livré rapidement.",
    cta: "Voir le catalogue",
    href: "/produits",
    image: IMG_PIECES,
    bg: "#0e1116",
  },
  {
    type: "promo",
    eyebrow: "Offre du moment",
    percent: 43,
    text: "d'économie sur une sélection de produits.",
    cta: "En profiter",
    href: "/produits",
    image: IMG_PROMO,
    bg: "linear-gradient(120deg, #14171c 0%, #2b1a10 55%, #c8410a 140%)",
  },
  {
    eyebrow: "Le service PiècesAuto",
    title: "Simple, rapide,\nde confiance",
    text: "Règlement par virement, livraison soignée, pièces d'origine et garanties.",
    cta: "Parcourir le catalogue",
    href: "/produits",
    image: IMG_SERVICE,
    bg: "linear-gradient(120deg, #14171c 0%, #23303a 100%)",
  },
];

const INTERVAL = 4500;

/* Compteur animé 0 -> target, déclenché quand la slide promo devient active */
function AnimatedPercent({ active, target = 43 }) {
  const [val, setVal] = useState(0);
  const raf = useRef(null);

  useEffect(() => {
    if (!active) { setVal(0); return; }
    const reduce = typeof window !== "undefined" &&
      window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
    if (reduce) { setVal(target); return; }

    const duration = 1200;
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - t, 3); // ease-out cubic
      setVal(Math.round(eased * target));
      if (t < 1) raf.current = requestAnimationFrame(tick);
    };
    raf.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf.current);
  }, [active, target]);

  return (
    <div className="hc-promo-figure" aria-hidden="true">
      <span className="hc-promo-minus">−</span>
      <span className="hc-promo-num">{val}</span>
      <span className="hc-promo-pct">%</span>
    </div>
  );
}

export default function HeroCarousel() {
  const [index, setIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  const timer = useRef(null);

  const go = useCallback((i) => setIndex((i + SLIDES.length) % SLIDES.length), []);
  const next = useCallback(() => go(index + 1), [go, index]);
  const prev = useCallback(() => go(index - 1), [go, index]);

  useEffect(() => {
    if (paused) return;
    const reduce = typeof window !== "undefined" &&
      window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;
    timer.current = setTimeout(next, INTERVAL);
    return () => clearTimeout(timer.current);
  }, [index, paused, next]);

  const onKey = (e) => {
    if (e.key === "ArrowRight") next();
    if (e.key === "ArrowLeft") prev();
  };

  return (
    <section
      className="hero-carousel"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
      onFocus={() => setPaused(true)}
      onBlur={() => setPaused(false)}
      onKeyDown={onKey}
      tabIndex={0}
      aria-roledescription="carrousel"
      aria-label="Mises en avant"
    >
      {SLIDES.map((s, i) => (
        <div
          key={i}
          className={`hc-slide ${i === index ? "active" : ""} ${s.type === "promo" ? "hc-slide-promo" : ""}`}
          style={{ background: s.bg }}
          aria-hidden={i !== index}
        >
          {s.image && (
            <div className="hc-slide-img" style={{ backgroundImage: `url(${s.image})` }} />
          )}

          <div className="hc-inner">
            <span className="hc-eyebrow">{s.eyebrow}</span>

            {s.type === "promo" ? (
              <>
                <AnimatedPercent active={i === index} target={s.percent} />
                <p className="hc-text">{s.text}</p>
              </>
            ) : (
              <>
                <h2 className="hc-title">
                  {s.title.split("\n").map((l, k) => <span key={k}>{l}<br /></span>)}
                </h2>
                <p className="hc-text">{s.text}</p>
              </>
            )}

            <Link href={s.href} className="hc-cta" tabIndex={i === index ? 0 : -1}>{s.cta}</Link>
          </div>
        </div>
      ))}

      <button className="hc-arrow prev" onClick={prev} aria-label="Slide précédent">‹</button>
      <button className="hc-arrow next" onClick={next} aria-label="Slide suivant">›</button>

      <div className="hc-dots" role="tablist" aria-label="Sélection de slide">
        {SLIDES.map((_, i) => (
          <button
            key={i}
            className={`hc-dot ${i === index ? "active" : ""}`}
            onClick={() => go(i)}
            role="tab"
            aria-selected={i === index}
            aria-label={`Aller au slide ${i + 1}`}
          />
        ))}
      </div>
    </section>
  );
}