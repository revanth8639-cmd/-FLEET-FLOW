import { useEffect, useState } from "react";
import {
  getShipments,
  createShipment,
  updateShipment,
  deleteShipment,
} from "../api/shipmentApi";
import { getDrivers } from "../api/driverApi";
import api from "../api/axios";
import { useAuth } from "../context/AuthContext";

export default function Shipments() {
  const { user } = useAuth();
  const canEdit = user?.role !== "Driver";
  const [shipments, setShipments] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [attendance, setAttendance] = useState([]);
  const [editingId, setEditingId] = useState(null);

  const [formData, setFormData] = useState({
    tracking_number: "",
    source: "",
    destination: "",
    status: "Created",
    eta: "",
    driver_id: "",
  });

  useEffect(() => {
    loadShipments();
    loadDrivers();
    loadAttendance();
  }, []);

  async function loadDrivers() {
    try {
      setDrivers(await getDrivers());
    } catch (error) {
      console.error(error);
      alert("Failed to load drivers");
    }
  }

  async function loadAttendance() {
    try {
      const response = await api.get("/attendance/");
      setAttendance(response.data);
    } catch (error) {
      console.error(error);
      alert("Failed to load driver attendance");
    }
  }

  const attendanceFor = (driverId) => attendance
    .filter((record) => record.driver_id === driverId)
    .sort((a, b) => new Date(b.check_in) - new Date(a.check_in))[0];

  const isPresent = (driverId) => attendanceFor(driverId)?.status === "Present";
  const presentDrivers = drivers.filter((driver) => isPresent(driver.driver_id));

  async function loadShipments() {
    try {
      const data = await getShipments();
      setShipments(data);
    } catch (error) {
      console.error(error);
      alert("Failed to load shipments");
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
      const payload = {
        ...formData,
        driver_id: formData.driver_id || null,
        status: formData.driver_id && formData.status === "Created" ? "Assigned" : formData.status,
      };
      if (payload.driver_id && !isPresent(payload.driver_id)) {
        alert("This driver is absent and cannot be assigned to a shipment.");
        return;
      }
      if (editingId) {
        await updateShipment(editingId, payload);
        setEditingId(null);
      } else {
        await createShipment(payload);
      }

      setFormData({
        tracking_number: "",
        source: "",
        destination: "",
        status: "Created",
        eta: "",
        driver_id: "",
      });

      loadShipments();
      loadAttendance();
    } catch (error) {
      console.error(error);
      alert("Operation failed");
    }
  };

  const handleEdit = (shipment) => {
    setEditingId(shipment.shipment_id);

    setFormData({
      tracking_number: shipment.tracking_number,
      source: shipment.source,
      destination: shipment.destination,
      status: shipment.status,
      eta: shipment.eta || "",
      driver_id: shipment.driver_id || "",
    });
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this shipment?")) return;

    try {
      await deleteShipment(id);
      loadShipments();
    } catch (error) {
      console.error(error);
      alert("Failed to delete shipment");
    }
  };

  return (
    <div className="p-8">

      <h1 className="text-3xl font-bold mb-6">
        Shipment Management
      </h1>

      {canEdit && <div className="flex gap-3 mb-6 flex-wrap">

        <input
          name="tracking_number"
          placeholder="Tracking Number"
          value={formData.tracking_number}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <select
          name="driver_id"
          value={formData.driver_id}
          onChange={handleChange}
          className="border p-2 rounded"
        >
          <option value="">Assign driver (optional)</option>
          {presentDrivers.map((driver) => (
            <option key={driver.driver_id} value={driver.driver_id}>
              {driver.name} — {driver.license_number}
            </option>
          ))}
        </select>

        <input
          name="source"
          placeholder="Source"
          value={formData.source}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <input
          name="destination"
          placeholder="Destination"
          value={formData.destination}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <select
          name="status"
          value={formData.status}
          onChange={handleChange}
          className="border p-2 rounded"
        >
          <option value="Created">Created</option>
          <option value="Assigned">Assigned</option>
          <option value="In Transit">In Transit</option>
          <option value="Delivered">Delivered</option>
          <option value="Cancelled">Cancelled</option>
        </select>

        <input
          name="eta"
          placeholder="ETA"
          value={formData.eta}
          onChange={handleChange}
          className="border p-2 rounded"
        />

        <button
          onClick={handleAdd}
          className="bg-blue-600 text-white px-5 py-2 rounded hover:bg-blue-700"
        >
          {editingId ? "Update Shipment" : "Add Shipment"}
        </button>

      </div>}

      <table className="w-full border border-gray-300">

        <thead className="bg-blue-600 text-white">
          <tr>
            <th className="p-3">Tracking No</th>
            <th>Source</th>
            <th>Destination</th>
            <th>Status</th>
            <th>ETA</th>
            <th>Assigned Driver</th>
            <th>Action</th>
          </tr>
        </thead>

        <tbody>

          {shipments.length > 0 ? (
            shipments.map((shipment) => (

              <tr
                key={shipment.shipment_id}
                className="border-b text-center"
              >

                <td className="p-3">
                  {shipment.tracking_number}
                </td>

                <td>{shipment.source}</td>

                <td>{shipment.destination}</td>

                <td>
                  <span className="bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full">
                    {shipment.status}
                  </span>
                </td>

                <td>{shipment.eta || "-"}</td>

                <td>
                  {drivers.find((driver) => driver.driver_id === shipment.driver_id)?.name || "Unassigned"}
                </td>

                {canEdit && <td className="space-x-2">

                  <button
                    onClick={() => handleEdit(shipment)}
                    className="bg-green-600 text-white px-4 py-1 rounded hover:bg-green-700"
                  >
                    Edit
                  </button>

                  <button
                    onClick={() => handleDelete(shipment.shipment_id)}
                    className="bg-red-600 text-white px-4 py-1 rounded hover:bg-red-700"
                  >
                    Delete
                  </button>

                </td>}

              </tr>

            ))
          ) : (
            <tr>
              <td colSpan="7" className="p-4 text-center">
                No shipments found.
              </td>
            </tr>
          )}

        </tbody>

      </table>

    </div>
  );
}
