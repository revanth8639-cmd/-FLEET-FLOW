import { useEffect, useState } from "react";
import {
  getDrivers,
  createDriver,
  deleteDriver,
} from "../api/driverApi";
import { getShipments } from "../api/shipmentApi";
import { useAuth } from "../context/AuthContext";

export default function Drivers() {
  const { user } = useAuth();
  const canManage = user?.role !== "Driver";
  const [drivers, setDrivers] = useState([]);
  const [shipments, setShipments] = useState([]);

  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    license_number: "",
    status: "Available",
  });

  useEffect(() => {
    loadDrivers();
    loadShipments();
  }, []);

  async function loadDrivers() {
    try {
      const data = await getDrivers();
      setDrivers(data);
    } catch (error) {
      console.error(error);
      alert("Failed to load drivers");
    }
  }

  async function loadShipments() {
    try {
      setShipments(await getShipments());
    } catch (error) {
      console.error(error);
      alert("Failed to load shipment assignments");
    }
  }

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleAdd = async () => {
    try {
      await createDriver(formData);

      setFormData({
        name: "",
        phone: "",
        license_number: "",
        status: "Available",
      });

      loadDrivers();
      loadShipments();
    } catch (error) {
      console.error(error);
      alert("Failed to add driver");
    }
  };

  const assignedShipment = (driverId) =>
    shipments.find((shipment) => shipment.driver_id === driverId);

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this driver?")) return;

    try {
      await deleteDriver(id);
      loadDrivers();
    } catch (error) {
      console.error(error);
      alert("Failed to delete driver");
    }
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Driver Management</h1>

      {/* Driver accounts can view driver details but cannot change them. */}
      {canManage && <div className="flex gap-3 mb-6 flex-wrap">
        <input
          type="text"
          name="name"
          placeholder="Driver Name"
          value={formData.name}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <input
          type="text"
          name="phone"
          placeholder="Phone Number"
          value={formData.phone}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <input
          type="text"
          name="license_number"
          placeholder="License Number"
          value={formData.license_number}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <button
          onClick={handleAdd}
          className="bg-blue-600 text-white px-5 py-2 rounded hover:bg-blue-700"
        >
          Add Driver
        </button>
      </div>}

      {/* Drivers Table */}
      <table className="w-full border border-gray-300">
        <thead className="bg-green-600 text-white">
          <tr>
            <th className="p-3">Driver Name</th>
            <th>Phone</th>
            <th>License Number</th>
            <th>Shipment Assignment</th>
            {canManage && <th>Action</th>}
          </tr>
        </thead>

        <tbody>
          {drivers.length > 0 ? (
            drivers.map((driver) => (
              <tr key={driver.driver_id} className="border-b text-center">
                {(() => {
                  const shipment = assignedShipment(driver.driver_id);
                  return <>
                <td className="p-3">{driver.name}</td>
                <td>{driver.phone}</td>
                <td>{driver.license_number}</td>
                <td>
                  <span className={`px-3 py-1 rounded-full ${shipment ? "bg-blue-100 text-blue-700" : "bg-gray-100 text-gray-600"}`}>
                    {shipment ? `Assigned — ${shipment.tracking_number}` : "Not assigned"}
                  </span>
                </td>
                {canManage && <td>
                  <button
                    onClick={() => handleDelete(driver.driver_id)}
                    className="bg-red-600 text-white px-4 py-1 rounded hover:bg-red-700"
                  >
                    Delete
                  </button>
                </td>}
                  </>;
                })()}
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="5" className="p-4 text-gray-500">
                No drivers found.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
