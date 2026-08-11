import { useEffect, useState } from "react";
import api from "../api/axios";

export default function Dashboard() {
  const [summary, setSummary] = useState(null);
  const [user, setUser] = useState(null);

  useEffect(() => {
    // Get dashboard summary
    api
      .get("/dashboard/summary")
      .then((res) => setSummary(res.data))
      .catch((err) => console.error(err));

    // Get logged-in user
    api
      .get("/auth/me")
      .then((res) => setUser(res.data))
      .catch((err) => console.error(err));
  }, []);

  if (!summary || !user) {
    return (
      <div className="flex justify-center items-center h-screen">
        <h2 className="text-2xl font-bold">Loading Dashboard...</h2>
      </div>
    );
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-4xl font-bold">FleetFlow Dashboard 🚚</h1>
          <p className="text-gray-600 mt-2">
            Welcome, <span className="font-semibold">{user.full_name}</span>
          </p>
        </div>

        <div className="bg-blue-100 px-4 py-2 rounded-lg shadow">
          <h3 className="font-bold text-lg">{user.full_name}</h3>
          <p className="text-sm text-gray-600">{user.role}</p>
        </div>
      </div>

      {/* Dashboard Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div className="bg-blue-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Vehicles</h2>
          <p className="text-3xl font-bold">{summary.total_vehicles}</p>
        </div>

        <div className="bg-green-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Drivers</h2>
          <p className="text-3xl font-bold">{summary.total_drivers}</p>
        </div>

        <div className="bg-orange-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Shipments</h2>
          <p className="text-3xl font-bold">{summary.total_shipments}</p>
        </div>

        <div className="bg-purple-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Trips</h2>
          <p className="text-3xl font-bold">{summary.total_trips}</p>
        </div>

        <div className="bg-red-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Maintenance</h2>
          <p className="text-3xl font-bold">{summary.total_maintenance}</p>
        </div>

        <div className="bg-yellow-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Fuel Records</h2>
          <p className="text-3xl font-bold">{summary.total_fuel_records}</p>
        </div>

        <div className="bg-pink-500 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Notifications</h2>
          <p className="text-3xl font-bold">{summary.total_notifications}</p>
        </div>

        <div className="bg-gray-700 text-white p-6 rounded-xl shadow">
          <h2 className="text-lg">Attendance</h2>
          <p className="text-3xl font-bold">{summary.total_attendance}</p>
        </div>
      </div>
    </div>
  );
}