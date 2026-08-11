import { useEffect, useState } from "react";
import { FaBoxes, FaFileExcel, FaFilePdf, FaGasPump, FaPrint, FaTools, FaTruck, FaUsers } from "react-icons/fa";
import api from "../api/axios";

const reportCards = [
  ["total_vehicles", "Total Vehicles", "bg-blue-600", FaTruck],
  ["total_drivers", "Total Drivers", "bg-green-600", FaUsers],
  ["total_shipments", "Total Shipments", "bg-purple-600", FaBoxes],
  ["total_trips", "Total Trips", "bg-yellow-500", FaTruck],
  ["total_fuel_records", "Fuel Records", "bg-red-500", FaGasPump],
  ["total_maintenance", "Maintenance Records", "bg-indigo-600", FaTools],
];

export default function Reports() {
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api.get("/reports/summary").then((response) => setSummary(response.data)).catch((requestError) => setError(requestError.response?.data?.detail || "Unable to load reports."));
  }, []);

  function exportCsv() {
    if (!summary) return;
    const csv = `Metric,Count\n${reportCards.map(([key, label]) => `${label},${summary[key]}`).join("\n")}\nNotifications,${summary.total_notifications}\nAttendance,${summary.total_attendance}`;
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv" }));
    const link = document.createElement("a");
    link.href = url;
    link.download = "fleetflow-report.csv";
    link.click();
    URL.revokeObjectURL(url);
  }

  if (error) return <div className="p-8 text-red-700">{error}</div>;
  if (!summary) return <div className="p-8">Loading reports…</div>;

  return (
    <div className="p-8 bg-gray-100 min-h-screen">
      <h1 className="text-4xl font-bold mb-2">Reports Dashboard</h1>
      <p className="text-gray-600 mb-6">Live totals from the FleetFlow database.</p>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reportCards.map(([key, label, color, Icon]) => <div key={key} className={`${color} text-white rounded-xl shadow-lg p-6`}><Icon size={35} /><h2 className="text-3xl font-bold mt-3">{summary[key]}</h2><p>{label}</p></div>)}
      </div>
      <div className="flex flex-wrap gap-4 mt-8">
        <button onClick={window.print} className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-5 py-3 rounded-lg"><FaFilePdf /> Save / Print PDF</button>
        <button onClick={exportCsv} className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-5 py-3 rounded-lg"><FaFileExcel /> Export CSV</button>
        <button onClick={window.print} className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-3 rounded-lg"><FaPrint /> Print Report</button>
      </div>
    </div>
  );
}
