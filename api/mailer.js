/**
 * mailer.js — Envoi d'emails (reçu de confirmation de commande) via SMTP.
 *
 * Configuration par variables d'environnement :
 *   SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS
 *   SMTP_SECURE   ("true" pour du TLS implicite, ex. port 465)
 *   MAIL_FROM     adresse expéditrice affichée (défaut : SMTP_USER)
 *
 * Si ces variables ne sont pas définies, l'envoi est simplement ignoré
 * (avec un avertissement en log) plutôt que de faire échouer la requête.
 */

const nodemailer = require("nodemailer");

let transporter;
function getTransporter() {
  if (transporter !== undefined) return transporter;
  const { SMTP_HOST, SMTP_USER, SMTP_PASS } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    transporter = null;
    return transporter;
  }
  const port = Number(process.env.SMTP_PORT || 587);
  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port,
    secure: String(process.env.SMTP_SECURE || "").toLowerCase() === "true" || port === 465,
    auth: { user: SMTP_USER, pass: SMTP_PASS },
  });
  return transporter;
}

async function sendOrderReceiptEmail(order, pdfBytes) {
  const t = getTransporter();
  if (!t) {
    console.warn(`[mailer] SMTP non configuré — reçu non envoyé pour ${order.order_number}`);
    return { sent: false, reason: "smtp_not_configured" };
  }

  const from = process.env.MAIL_FROM || process.env.SMTP_USER;
  await t.sendMail({
    from,
    to: order.customer_email,
    subject: `Confirmation de votre commande ${order.order_number}`,
    text:
      `Bonjour ${order.customer_name},\n\n` +
      `Votre commande ${order.order_number} a bien été prise en charge et sera acheminée entre 2 à 5 jours.\n\n` +
      `Vous trouverez ci-joint votre reçu de confirmation.\n\n` +
      `Merci pour votre confiance.`,
    attachments: [
      {
        filename: `recu-${order.order_number}.pdf`,
        content: Buffer.from(pdfBytes),
        contentType: "application/pdf",
      },
    ],
  });
  return { sent: true };
}

module.exports = { sendOrderReceiptEmail };
