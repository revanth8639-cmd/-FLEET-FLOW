import { useState } from "react";

export default function FuelRecords() {
  const [records, setRecords] = useState([
    {
      vehicle: "AP39AB1234",
      driver: "Ravi",
      fuel: "Diesel",
      liters: "50",
      price: "4800",
      date: "2026-08-05",
    },
    {
      vehicle: "TS09XY5678",
      driver: "Kiran",
      fuel: "Petrol",
      liters: "35",
      price: "3500",
      date: "2026-08-06",
    },
  ]);

  const [form, setForm] = useState({
    vehicle: "",
    driver: "",
    fuel: "Diesel",
    liters: "",
    price: "",
    date: "",
  });

  const [search, setSearch] = useState("");
  const [editIndex, setEditIndex] = useState(null);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const saveRecord = () => {
    if (!form.vehicle || !form.driver) return;

    if (editIndex !== null) {
      const temp = [...records];
      temp[editIndex] = form;
      setRecords(temp);
      setEditIndex(null);
    } else {
      setRecords([...records, form]);
    }

    setForm({
      vehicle: "",
      driver: "",
      fuel: "Diesel",
      liters: "",
      price: "",
      date: "",
    });
  };

  const editRecord = (i) => {
    setForm(records[i]);
    setEditIndex(i);
  };

  const deleteRecord = (i) => {
    setRecords(records.filter((_, index) => index !== i));
  };

  const filtered = records.filter(
    (r) =>
      r.vehicle.toLowerCase().includes(search.toLowerCase()) ||
      r.driver.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-8 bg-gray-100 min-h-screen">

      <h1 className="text-4xl font-bold mb-6">Fuel Records</h1>

      <div className="bg-white rounded-xl shadow p-6">

        <div className="grid grid-cols-2 gap-4">

          <input
            name="vehicle"
            placeholder="Vehicle Number"
            value={form.vehicle}
            onChange={handleChange}
            className="border rounded-lg p-3"
          />

          <input
            name="driver"
            placeholder="Driver Name"
            value={form.driver}
            onChange={handleChange}
            className="border rounded-lg p-3"
          />

          <select
            name="fuel"
            value={form.fuel}
            onChange={handleChange}
            className="border rounded-lg p-3"
          >
            <option>Diesel</option>
            <option>Petrol</option>
            <option>CNG</option>
          </select>

          <input
            name="liters"
            placeholder="Fuel Quantity (L)"
            value={form.liters}
            onChange={handleChange}
            className="border rounded-lg p-3"
          />

          <input
            name="price"
            placeholder="Amount"
            value={form.price}
            onChange={handleChange}
            className="border rounded-lg p-3"
          />

          <input
            type="date"
            name="date"
            value={form.date}
            onChange={handleChange}
            className="border rounded-lg p-3"
          />

          <button
            onClick={saveRecord}
            className="col-span-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg p-3"
          >
            {editIndex !== null ? "Update Record" : "Add Fuel Record"}
          </button>

        </div>

      </div>

      <div className="bg-white rounded-xl shadow p-6 mt-6">

        <input
          placeholder="Search Vehicle / Driver..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="border rounded-lg p-3 w-full mb-5"
        />

        <table className="w-full">

          <thead className="bg-gray-100">
            <tr>
              <th className="p-3">Vehicle</th>
              <th>Driver</th>
              <th>Fuel</th>
              <th>Liters</th>
              <th>Amount</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>

          <tbody>

            {filtered.map((r, i) => (

              <tr key={i} className="border-b text-center">

                <td className="p-3">{r.vehicle}</td>
                <td>{r.driver}</td>
                <td>{r.fuel}</td>
                <td>{r.liters} L</td>
                <td>₹{r.price}</td>
                <td>{r.date}</td>

                <td className="space-x-2">

                  <button
                    onClick={() => editRecord(i)}
                    className="bg-yellow-500 text-white px-3 py-1 rounded"
                  >
                    Edit
                  </button>

                  <button
                    onClick={() => deleteRecord(i)}
                    className="bg-red-600 text-white px-3 py-1 rounded"
                  >
                    Delete
                  </button>

                </td>

              </tr>

            ))}

          </tbody>

        </table>

      </div>

    </div>
  );
}