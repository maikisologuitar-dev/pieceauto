export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="container">
        <div>© {new Date().getFullYear()} PiècesAuto — Pièces et équipement automobile</div>
        <div>Règlement par virement, chèque, à la livraison ou espèces</div>
      </div>
    </footer>
  );
}
