"use client";
import { useState, useEffect, useCallback, useRef } from "react";
import Link from "next/link";

/**
 * HeroCarousel — carrousel plein largeur auto-rotatif.
 * Slides configurables (titre, sous-titre, CTA, couleur d'accent).
 * Auto-défilement (pause au survol / focus), flèches, points cliquables,
 * clavier (← →), et respect de prefers-reduced-motion.
 */
const SLIDES = [
  {
    eyebrow: "Entretien & nettoyage",
    title: "Préparez votre véhicule\npour chaque saison",
    text: "Huiles, additifs, produits d'entretien : tout pour rouler l'esprit tranquille.",
    cta: "Voir le rayon entretien",
    href: "/produits?category=entretien-nettoyage",
    bg: "linear-gradient(120deg, #14171c 0%, #1e232b 55%, #2b323d 100%)",
  },
  {
    eyebrow: "Outillage d'atelier",
    title: "L'équipement pro,\nà portée de main",
    text: "Servantes, coffrets de douilles, crics et boosters pour travailler comme au garage.",
    cta: "Découvrir l'outillage",
    href: "/produits?category=outillage",
    bg: "linear-gradient(120deg, #1a1d23 0%, #262b34 60%, #3a2417 100%)",
  },
  {
    eyebrow: "Offre du moment",
    title: "Les meilleurs prix,\ntoute l'année",
    text: "Un large choix de pièces et d'accessoires, livrés rapidement, réglés simplement.",
    cta: "Parcourir le catalogue",
    href: "/produits",
    bg: "linear-gradient(120deg, #14171c 0%, #23303a 100%)",
  },
];

const INTERVAL = 5500;

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
          className={`hc-slide ${i === index ? "active" : ""}`}
          style={{ background: s.bg }}
          aria-hidden={i !== index}
        >
          <div className="hc-inner">
            <span className="hc-eyebrow">{s.eyebrow}</span>
            <h2 className="hc-title">{s.title.split("\n").map((l, k) => <span key={k}>{l}<br /></span>)}</h2>
            <p className="hc-text">{s.text}</p>
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
