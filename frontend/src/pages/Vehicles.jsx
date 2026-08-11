import { useEffect, useState } from "react";

import {
  getVehicles,
  createVehicle,
  deleteVehicle,
} from "../api/vehicleApi";
import { useAuth } from "../context/AuthContext";

export default function Vehicles() {
  const { user } = useAuth();
  const canManage = user?.role !== "Driver";
  const [vehicles, setVehicles] = useState([]);

  const [form, setForm] = useState({
    registration_number: "",
    vehicle_type: "",
    capacity: "",
    fuel_type: "",
    status: "Available",
  });

  useEffect(() => {
    loadVehicles();
  }, []);

  async function loadVehicles() {
    try {
      const data = await getVehicles();
      setVehicles(data);
    } catch (error) {
      console.error(error);
      alert("Failed to load vehicles");
    }
  }

  const resetForm = () => {
    setForm({
      registration_number: "",
      vehicle_type: "",
      capacity: "",
      fuel_type: "",
      status: "Available",
    });

  };

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value,
    });
  };

  // ADD
  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      await createVehicle(form);

      alert("Vehicle Added Successfully");

      resetForm();
      loadVehicles();
    } catch (error) {
      console.error(error);

      alert(error.message || "Failed to add vehicle");
    }
  };

  // DELETE
  const handleDelete = async (id) => {
    if (!window.confirm("Delete this vehicle?")) {
      return;
    }

    try {
      await deleteVehicle(id);

      alert("Vehicle deleted successfully");

      loadVehicles();
    } catch (error) {
      console.error(error);

      alert(
        error.message || "Delete failed"
      );
    }
  };

  return (
    <div className="p-8">

      {/* PAGE TITLE */}
      <h1 className="text-3xl font-bold mb-6">
        Vehicle Management
      </h1>

      {canManage && <form
        onSubmit={handleSubmit}
        className="grid grid-cols-6 gap-3 mb-8"
      >

        {/* Registration */}
        <input
          name="registration_number"
          placeholder="Registration"
          value={form.registration_number}
          onChange={handleChange}
          className="border p-2 rounded"
          required
        />

        {/* Vehicle Type */}
        <input
          name="vehicle_type"
          placeholder="Vehicle Type"
          value={form.vehicle_type}
          onChange={handleChange}
          className="border p-2 rounded"
          required
        />

        {/* Capacity */}
        <input
          name="capacity"
          placeholder="Capacity"
          value={form.capacity}
          onChange={handleChange}
          className="border p-2 rounded"
          required
        />

        {/* Fuel */}
        <input
          name="fuel_type"
          placeholder="Fuel Type"
          value={form.fuel_type}
          onChange={handleChange}
          className="border p-2 rounded"
          required
        />

        {/* Status */}
        <select
          name="status"
          value={form.status}
          onChange={handleChange}
          className="border p-2 rounded"
        >
          <option value="Available">
            Available
          </option>

          <option value="In Service">
            In Service
          </option>

          <option value="Maintenance">
            Maintenance
          </option>

          <option value="Unavailable">
            Unavailable
          </option>
        </select>

        {/* Submit */}
        <button
          type="submit"
          className="bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Add Vehicle
        </button>
      </form>}

      {/* VEHICLE TABLE */}
      <table className="w-full border border-gray-300">

        <thead className="bg-blue-600 text-white">

          <tr>
            <th className="p-3">
              Registration
            </th>

            <th>
              Vehicle Type
            </th>

            <th>
              Capacity
            </th>

            <th>
              Fuel Type
            </th>

            <th>
              Status
            </th>

            {canManage && <th>
              Action
            </th>}
          </tr>

        </thead>

        <tbody>

          {vehicles.length === 0 ? (

            <tr>
              <td
                colSpan="6"
                className="p-6 text-center"
              >
                No vehicles found
              </td>
            </tr>

          ) : (

            vehicles.map((vehicle) => (

              <tr
                key={vehicle.vehicle_id}
                className="border-b text-center"
              >

                <td className="p-3">
                  {vehicle.registration_number}
                </td>

                <td>
                  {vehicle.vehicle_type}
                </td>

                <td>
                  {vehicle.capacity}
                </td>

                <td>
                  {vehicle.fuel_type}
                </td>

                <td>

                  <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full">
                    {vehicle.status}
                  </span>

                </td>

                {canManage && <td className="p-2">

                  {/* DELETE */}
                  <button
                    onClick={() =>
                      handleDelete(
                        vehicle.vehicle_id
                      )
                    }
                    className="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700"
                  >
                    Delete
                  </button>

                </td>}

              </tr>

            ))

          )}

        </tbody>

      </table>

    </div>
  );
}
