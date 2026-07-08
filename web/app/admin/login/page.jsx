"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { adminLogin } from "@/lib/admin";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState("");
  const [loading, setLoading] = useState(false);

  const submit = async () => {
    setErr("");
    setLoading(true);
    try {
      await adminLogin(email, password);
      router.replace("/admin");
    } catch (e) {
      setErr(e.message);
      setLoading(false);
    }
  };

  const onKey = (e) => { if (e.key === "Enter") submit(); };

  return (
    <div className="login-box">
      <h1>Administration</h1>
      <label>Email</label>
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} onKeyDown={onKey} autoComplete="username" />
      <label>Mot de passe</label>
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} onKeyDown={onKey} autoComplete="current-password" />
      <button onClick={submit} disabled={loading}>{loading ? "Connexion…" : "Se connecter"}</button>
      {err && <div className="err">{err}</div>}
    </div>
  );
}
