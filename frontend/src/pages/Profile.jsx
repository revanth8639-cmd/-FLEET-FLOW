import { useEffect, useState } from "react";
import api from "../api/axios";
import { useAuth } from "../context/AuthContext";

export default function Profile() {
  const { user, setUser } = useAuth();
  const [profile, setProfile] = useState({ full_name: "", phone: "", address: "" });
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState({ current_password: "", new_password: "" });
  const [message, setMessage] = useState("");

  useEffect(() => {
    if (user) {
      const timer = window.setTimeout(() => {
        setProfile({
          full_name: user.full_name || "",
          phone: user.phone || "",
          address: user.address || "",
        });
        setEmail(user.email || "");
      }, 0);
      return () => window.clearTimeout(timer);
    }
  }, [user]);

  const saveProfile = async (event) => {
    event.preventDefault();
    const response = await api.patch("/auth/me", profile);
    setUser(response.data);
    setMessage("Profile saved.");
  };

  const saveEmail = async (event) => {
    event.preventDefault();
    const response = await api.patch("/auth/me/email", { email });
    setUser(response.data);
    setMessage("Email updated.");
  };

  const savePassword = async (event) => {
    event.preventDefault();
    await api.patch("/auth/me/password", password);
    setPassword({ current_password: "", new_password: "" });
    setMessage("Password updated.");
  };

  if (!user) return <div className="p-8">Loading account settings…</div>;

  return (
    <div className="max-w-3xl space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Profile & Account Settings</h1>
        <p className="text-gray-600 mt-1">Manage your profile and sign-in details.</p>
      </div>
      {message && <div className="rounded-lg bg-green-50 px-4 py-3 text-green-700">{message}</div>}

      <form onSubmit={saveProfile} className="bg-white p-6 rounded-xl shadow space-y-4">
        <h2 className="text-xl font-semibold">Profile</h2>
        <input className="w-full border p-3 rounded-lg" placeholder="Full name" value={profile.full_name} onChange={(e) => setProfile({ ...profile, full_name: e.target.value })} />
        <input className="w-full border p-3 rounded-lg" placeholder="Phone" value={profile.phone} onChange={(e) => setProfile({ ...profile, phone: e.target.value })} />
        <textarea className="w-full border p-3 rounded-lg" placeholder="Address" value={profile.address} onChange={(e) => setProfile({ ...profile, address: e.target.value })} />
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg">Save profile</button>
      </form>

      <form onSubmit={saveEmail} className="bg-white p-6 rounded-xl shadow space-y-4">
        <h2 className="text-xl font-semibold">Email</h2>
        <input className="w-full border p-3 rounded-lg" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg">Update email</button>
      </form>

      <form onSubmit={savePassword} className="bg-white p-6 rounded-xl shadow space-y-4">
        <h2 className="text-xl font-semibold">Password</h2>
        <input className="w-full border p-3 rounded-lg" type="password" placeholder="Current password" value={password.current_password} onChange={(e) => setPassword({ ...password, current_password: e.target.value })} required />
        <input className="w-full border p-3 rounded-lg" type="password" placeholder="New password" value={password.new_password} onChange={(e) => setPassword({ ...password, new_password: e.target.value })} required />
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg">Change password</button>
      </form>
    </div>
  );
}
