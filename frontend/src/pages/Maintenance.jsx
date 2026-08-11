import { useEffect, useState } from "react";
import api from "../api/axios";

const emptyForm = { vehicle_id: "", service_type: "", description: "", next_service_date: "", cost: "", status: "Pending" };

export default function Maintenance() {
  const [records, setRecords] = useState([]);
  const [vehicles, setVehicles] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [search, setSearch] = useState("");
  const [error, setError] = useState("");

  async function loadData() {
    try {
      const [maintenance, vehicleList] = await Promise.all([api.get("/maintenance/"), api.get("/vehicles/")]);
      setRecords(maintenance.data);
      setVehicles(vehicleList.data);
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Unable to load maintenance records.");
    }
  }

  useEffect(() => {
    const timer = window.setTimeout(() => void loadData(), 0);
    return () => window.clearTimeout(timer);
  }, []);

  async function saveRecord(event) {
    event.preventDefault();
    const payload = { ...form, cost: form.cost ? Number(form.cost) : null, next_service_date: form.next_service_date ? new Date(form.next_service_date).toISOString() : null };
    try {
      if (editingId) await api.put(`/maintenance/${editingId}`, payload);
      else await api.post("/maintenance/", payload);
      setForm(emptyForm);
      setEditingId(null);
      await loadData();
    } catch (requestError) {
      setError(requestError.response?.data?.detail || "Unable to save maintenance record.");
    }
  }

  async function deleteRecord(id) {
    if (!window.confirm("Delete this maintenance record?")) return;
    await api.delete(`/maintenance/${id}`);
    await loadData();
  }

  const vehicleName = (id) => vehicles.find((vehicle) => vehicle.vehicle_id === id)?.registration_number || id;
  const filtered = records.filter((record) => `${vehicleName(record.vehicle_id)} ${record.service_type}`.toLowerCase().includes(search.toLowerCase()));

  return <div className="p-8 bg-gray-100 min-h-screen"><h1 className="text-4xl font-bold mb-2">Maintenance</h1><p className="text-gray-600 mb-6">Live records used by the dashboard.</p>{error && <div className="mb-4 bg-red-50 p-3 text-red-700 rounded">{error}</div>}
    <form onSubmit={saveRecord} className="bg-white rounded-xl shadow p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
      <select required value={form.vehicle_id} onChange={(event) => setForm({ ...form, vehicle_id: event.target.value })} className="border rounded-lg p-3"><option value="">Select vehicle</option>{vehicles.map((vehicle) => <option key={vehicle.vehicle_id} value={vehicle.vehicle_id}>{vehicle.registration_number}</option>)}</select>
      <input required placeholder="Service type" value={form.service_type} onChange={(event) => setForm({ ...form, service_type: event.target.value })} className="border rounded-lg p-3" />
      <input placeholder="Description" value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} className="border rounded-lg p-3" />
      <input type="number" min="0" step="0.01" placeholder="Cost" value={form.cost} onChange={(event) => setForm({ ...form, cost: event.target.value })} className="border rounded-lg p-3" />
      <input type="datetime-local" value={form.next_service_date} onChange={(event) => setForm({ ...form, next_service_date: event.target.value })} className="border rounded-lg p-3" />
      <select value={form.status} onChange={(event) => setForm({ ...form, status: event.target.value })} className="border rounded-lg p-3"><option>Pending</option><option>In Progress</option><option>Completed</option></select>
      <div className="flex gap-3"><button className="bg-blue-600 text-white rounded-lg px-5 py-3">{editingId ? "Update Record" : "Add Record"}</button>{editingId && <button type="button" onClick={() => { setForm(emptyForm); setEditingId(null); }} className="bg-gray-200 rounded-lg px-5">Cancel</button>}</div>
    </form>
    <div className="bg-white mt-6 rounded-xl shadow p-6"><input placeholder="Search vehicle or service" value={search} onChange={(event) => setSearch(event.target.value)} className="border rounded-lg p-3 w-full mb-4" /><table className="w-full"><thead className="bg-gray-100"><tr><th className="p-3 text-left">Vehicle</th><th>Service</th><th>Cost</th><th>Next Service</th><th>Status</th><th>Actions</th></tr></thead><tbody>{filtered.map((record) => <tr key={record.maintenance_id} className="border-b text-center"><td className="p-3 text-left">{vehicleName(record.vehicle_id)}</td><td>{record.service_type}</td><td>₹{record.cost ?? "—"}</td><td>{record.next_service_date ? new Date(record.next_service_date).toLocaleString() : "—"}</td><td>{record.status}</td><td><button onClick={() => { setEditingId(record.maintenance_id); setForm({ vehicle_id: record.vehicle_id, service_type: record.service_type, description: record.description || "", next_service_date: record.next_service_date ? record.next_service_date.slice(0, 16) : "", cost: record.cost ?? "", status: record.status }); }} className="bg-yellow-500 text-white px-3 py-1 rounded mr-2">Edit</button><button onClick={() => deleteRecord(record.maintenance_id)} className="bg-red-600 text-white px-3 py-1 rounded">Delete</button></td></tr>)}{filtered.length === 0 && <tr><td colSpan="6" className="p-6 text-center text-gray-500">No maintenance records found.</td></tr>}</tbody></table></div>
  </div>;
}
