import "./globals.css";
import CartProvider from "@/components/CartProvider";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

export const metadata = {
  title: "PiècesAuto — Pièces et équipement automobile",
  description:
    "Catalogue de pièces détachées et équipement automobile. Règlement par virement, chèque, à la livraison ou espèces.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <body>
        <CartProvider>
          <Header />
          <main>{children}</main>
          <Footer />
        </CartProvider>
      </body>
    </html>
  );
}
