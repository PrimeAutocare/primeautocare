import { useEffect, useState } from "react";
import { get, post, del } from "../api/client";

function Vehicles() {
  const [vehicles, setVehicles] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const [custNo, setCustNo] = useState("");
  const [license, setLicense] = useState("");
  const [make, setMake] = useState("");
  const [model, setModel] = useState("");
  const [year, setYear] = useState("");

  async function loadAll() {
    setLoading(true);
    setError("");
    try {
      const [vehiclesData, customersData] = await Promise.all([
        get("/vehicles"),
        get("/customers"),
      ]);
      setVehicles(vehiclesData);
      setCustomers(customersData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    (async () => {
      await loadAll();
    })();
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/vehicles", {
        cust_no: custNo,
        vehi_license: license,
        vehi_make: make,
        vehi_model: model,
        vehi_year: Number(year),
      });
      setCustNo("");
      setLicense("");
      setMake("");
      setModel("");
      setYear("");
      await loadAll();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(vehiId) {
    if (!confirm("Delete this vehicle? This cannot be undone.")) return;
    setError("");
    try {
      await del(`/vehicles/${vehiId}`);
      await loadAll();
    } catch (err) {
      setError(err.message);
    }
  }

  function customerName(custNo) {
    const customer = customers.find((c) => c.cust_no === custNo);
    return customer ? customer.cust_name : custNo;
  }

  if (loading) return <p className="text-slate-400">Loading...</p>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Vehicles</h2>

      <form
        onSubmit={handleSubmit}
        className="bg-slate-800 p-6 rounded-lg mb-8 flex flex-col gap-4 max-w-lg"
      >
        <h3 className="text-lg font-semibold">Register New Vehicle</h3>

        {formError && (
          <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">
            {formError}
          </p>
        )}

        <div>
          <label className="block text-slate-300 text-sm mb-1">Customer</label>
          <select
            value={custNo}
            onChange={(e) => setCustNo(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          >
            <option value="" disabled>Select a customer</option>
            {customers.map((c) => (
              <option key={c.cust_no} value={c.cust_no}>
                {c.cust_name}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-slate-300 text-sm mb-1">License Plate</label>
          <input
            type="text"
            value={license}
            onChange={(e) => setLicense(e.target.value)}
            placeholder="CAB-1234"
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-slate-300 text-sm mb-1">Make</label>
            <input
              type="text"
              value={make}
              onChange={(e) => setMake(e.target.value)}
              className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label className="block text-slate-300 text-sm mb-1">Model</label>
            <input
              type="text"
              value={model}
              onChange={(e) => setModel(e.target.value)}
              className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
        </div>

        <div>
          <label className="block text-slate-300 text-sm mb-1">Year</label>
          <input
            type="number"
            value={year}
            onChange={(e) => setYear(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition"
        >
          {submitting ? "Registering..." : "Register Vehicle"}
        </button>
      </form>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-700 text-slate-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">License</th>
              <th className="py-2 pr-4">Make</th>
              <th className="py-2 pr-4">Model</th>
              <th className="py-2 pr-4">Year</th>
              <th className="py-2 pr-4">Customer</th>
              <th className="py-2 pr-4"></th>
            </tr>
          </thead>
          <tbody>
            {vehicles.map((v) => (
              <tr key={v.vehi_id} className="border-b border-slate-800 hover:bg-slate-800/50">
                <td className="py-2 pr-4">{v.vehi_id}</td>
                <td className="py-2 pr-4">{v.vehi_license}</td>
                <td className="py-2 pr-4">{v.vehi_make}</td>
                <td className="py-2 pr-4">{v.vehi_model}</td>
                <td className="py-2 pr-4">{v.vehi_year}</td>
                <td className="py-2 pr-4">{customerName(v.cust_no)}</td>
                <td className="py-2 pr-4">
                  <button
                    onClick={() => handleDelete(v.vehi_id)}
                    className="text-red-400 hover:text-red-300 text-sm"
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

export default Vehicles;