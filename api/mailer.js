/**
 * mailer.js — Envoi d'emails (suivi de commande) via SMTP.
 *
 * Configuration par variables d'environnement :
 *   SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS
 *   SMTP_SECURE   ("true" pour du TLS implicite, ex. port 465)
 *   MAIL_FROM     adresse expéditrice affichée (défaut : SMTP_USER)
 *   ADMIN_EMAIL   adresse qui reçoit les notifications admin (défaut : MAIL_FROM)
 *
 * Si SMTP n'est pas configuré, l'envoi est simplement ignoré (avec un
 * avertissement en log) plutôt que de faire échouer la requête.
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

function euro(cents) {
  return new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" }).format((cents || 0) / 100);
}

function orderSummaryText(order, items) {
  const lines = (items || []).map(
    (it) => `- ${it.title} x${it.quantity} — ${euro(it.unit_cents * it.quantity)}`
  );
  return [
    `Commande : ${order.order_number}`,
    `Client : ${order.customer_name} (${order.customer_email}${order.customer_phone ? ", " + order.customer_phone : ""})`,
    `Adresse : ${order.address_line}, ${order.postal_code} ${order.city}`,
    `Règlement : ${order.payment_method}`,
    "",
    ...lines,
    "",
    `Total : ${euro(order.total_cents)}`,
  ].join("\n");
}

async function send(to, subject, text, extra = {}) {
  const t = getTransporter();
  if (!t) {
    console.warn(`[mailer] SMTP non configuré — email non envoyé : ${subject}`);
    return { sent: false, reason: "smtp_not_configured" };
  }
  const from = process.env.MAIL_FROM || process.env.SMTP_USER;
  await t.sendMail({ from, to, subject, text, ...extra });
  return { sent: true };
}

// Nouvelle commande créée, en attente de règlement : prévient l'admin pour
// qu'il puisse relancer le client si le paiement n'arrive pas.
async function sendNewOrderAdminEmail(order, items) {
  const adminEmail = process.env.ADMIN_EMAIL || process.env.MAIL_FROM || process.env.SMTP_USER;
  return send(
    adminEmail,
    `Nouvelle commande ${order.order_number} — en attente de paiement`,
    `Une nouvelle commande vient d'être passée, en attente de règlement.\n\n` +
      orderSummaryText(order, items) +
      `\n\nPensez à relancer le client si le paiement n'est pas confirmé rapidement.`
  );
}

// Le client a téléversé sa preuve de paiement : l'admin reçoit la preuve et
// le récap commande pour vérification.
async function sendProofUploadedAdminEmail(order, items, proofUrl) {
  const adminEmail = process.env.ADMIN_EMAIL || process.env.MAIL_FROM || process.env.SMTP_USER;
  return send(
    adminEmail,
    `Preuve de paiement reçue — ${order.order_number}`,
    `Le client a téléversé une preuve de paiement pour la commande ci-dessous.\n\n` +
      orderSummaryText(order, items) +
      `\n\nPreuve de paiement : ${proofUrl}`,
    {
      html:
        `<p>Le client a téléversé une preuve de paiement pour la commande <b>${order.order_number}</b>.</p>` +
        `<pre style="font-family:inherit;white-space:pre-wrap">${orderSummaryText(order, items)}</pre>` +
        `<p><a href="${proofUrl}">Voir la preuve de paiement</a></p>` +
        `<p><img src="${proofUrl}" alt="Preuve de paiement" style="max-width:500px" /></p>`,
    }
  );
}

// Confirme au client que sa preuve de paiement a bien été reçue et est en
// cours de vérification (avant l'envoi du reçu final par l'admin).
async function sendProofPendingClientEmail(order) {
  return send(
    order.customer_email,
    `Preuve de paiement reçue — commande ${order.order_number}`,
    `Bonjour ${order.customer_name},\n\n` +
      `Nous avons bien reçu votre preuve de paiement pour la commande ${order.order_number}.\n` +
      `Elle est en cours de vérification par notre équipe ; vous recevrez une confirmation dès sa validation.\n\n` +
      `Merci pour votre confiance.`
  );
}

module.exports = { sendNewOrderAdminEmail, sendProofUploadedAdminEmail, sendProofPendingClientEmail };
