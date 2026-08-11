import { useEffect, useState } from "react";
import api from "../api/axios";
import { useAuth } from "../context/AuthContext";

const emptyForm = { title: "", message: "" };

export default function Notifications() {
  const { user } = useAuth();
  const [form, setForm] = useState(emptyForm);
  const [editId, setEditId] = useState(null);
  const [notifications, setNotifications] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  async function loadNotifications() {
    try {
      const response = await api.get("/notifications/");
      setNotifications(response.data);
      setError("");
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Unable to load notifications.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadNotifications();
    }, 0);
    return () => window.clearTimeout(timer);
  }, []);

  async function saveNotification(event) {
    event.preventDefault();
    if (!form.title.trim() || !form.message.trim()) return;

    try {
      if (editId) {
        await api.put(`/notifications/${editId}`, form);
      } else if (user) {
        await api.post("/notifications/", { ...form, user_id: user.user_id });
      }
      setForm(emptyForm);
      setEditId(null);
      await loadNotifications();
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Unable to save notification.");
    }
  }

  function editNotification(notification) {
    setForm({ title: notification.title, message: notification.message });
    setEditId(notification.notification_id);
  }

  async function deleteNotification(notificationId) {
    if (!window.confirm("Delete this notification?")) return;
    try {
      await api.delete(`/notifications/${notificationId}`);
      await loadNotifications();
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Unable to delete notification.");
    }
  }

  return (
    <div className="p-8 bg-gray-100 min-h-screen">
      <h1 className="text-3xl font-bold mb-2">Notifications</h1>
      <p className="text-gray-600 mb-6">Notifications below come from the same database count shown on the dashboard.</p>

      {error && <div className="mb-4 rounded-lg bg-red-50 p-3 text-red-700">{error}</div>}

      <form onSubmit={saveNotification} className="bg-white shadow rounded-lg p-6 mb-6 grid gap-4">
        <input type="text" placeholder="Notification title" value={form.title} onChange={(event) => setForm({ ...form, title: event.target.value })} className="border rounded-lg p-3" required />
        <textarea rows="4" placeholder="Notification message" value={form.message} onChange={(event) => setForm({ ...form, message: event.target.value })} className="border rounded-lg p-3" required />
        <div className="flex gap-3">
          <button className="bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-5 py-3">{editId ? "Update Notification" : "Send Notification"}</button>
          {editId && <button type="button" onClick={() => { setForm(emptyForm); setEditId(null); }} className="rounded-lg bg-gray-200 px-5 py-3">Cancel</button>}
        </div>
      </form>

      <div className="bg-white shadow rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-200"><tr><th className="p-3 text-left">Title</th><th className="p-3 text-left">Message</th><th className="p-3 text-left">Created</th><th className="p-3 text-center">Actions</th></tr></thead>
          <tbody>
            {!loading && notifications.map((item) => <tr key={item.notification_id} className="border-t hover:bg-gray-50"><td className="p-3 font-semibold">{item.title}</td><td className="p-3">{item.message}</td><td className="p-3">{new Date(item.created_at).toLocaleString()}</td><td className="p-3 flex justify-center gap-3"><button onClick={() => editNotification(item)} className="bg-yellow-500 text-white px-3 py-1 rounded">Edit</button><button onClick={() => deleteNotification(item.notification_id)} className="bg-red-600 text-white px-3 py-1 rounded">Delete</button></td></tr>)}
            {!loading && notifications.length === 0 && <tr><td colSpan="4" className="text-center p-6 text-gray-500">No notifications available</td></tr>}
            {loading && <tr><td colSpan="4" className="text-center p-6 text-gray-500">Loading notifications…</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}
