import AdminShell from "@/components/AdminShell";
export const metadata = { title: "Admin — PiècesAuto" };
export default function AdminLayout({ children }) {
  return <AdminShell>{children}</AdminShell>;
}
