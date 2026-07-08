/** @type {import('next').NextConfig} */
const nextConfig = {
  allowedDevOrigins: ["*.trycloudflare.com"],
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "pieces-auto.fr" },
    ],
  },
};
export default nextConfig;
