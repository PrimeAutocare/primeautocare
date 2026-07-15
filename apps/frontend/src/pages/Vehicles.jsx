import { useEffect, useState } from "react";
import { get, post, del } from "../api/client";
import { useAuth } from "../context/useAuth";
import { canManage } from "../context/AuthContext";
import Modal from "../components/Modal";

function Vehicles() {
  const { employee: currentUser } = useAuth();
  const [vehicles, setVehicles] = useState([]);
  const [owners, setOwners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const [ownerNo, setOwnerNo] = useState("");
  const [license, setLicense] = useState("");
  const [make, setMake] = useState("");
  const [model, setModel] = useState("");
  const [year, setYear] = useState("");

  const canDelete = canManage(currentUser, ["A"]);

  useEffect(() => {
    loadAll();
  }, []);

  async function loadAll() {
    setLoading(true);
    setError("");
    try {
      const [vehiclesData, ownersData] = await Promise.all([get("/vehicles"), get("/vehicle-owners")]);
      setVehicles(vehiclesData);
      setOwners(ownersData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  function resetForm() {
    setOwnerNo("");
    setLicense("");
    setMake("");
    setModel("");
    setYear("");
    setFormError("");
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/vehicles", {
        owner_no: Number(ownerNo),
        vehi_license: license,
        vehi_make: make,
        vehi_model: model,
        vehi_year: Number(year),
      });
      resetForm();
      setShowModal(false);
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

  function ownerName(no) {
    const owner = owners.find((o) => o.owner_no === no);
    return owner ? owner.owner_name : `#${no}`;
  }

  if (loading) return <p className="text-zinc-400">Loading...</p>;

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">Vehicles</h2>
        <button onClick={() => setShowModal(true)}
          className="bg-orange-600 hover:bg-orange-500 text-white font-semibold px-4 py-2 rounded transition">
          + Register Vehicle
        </button>
      </div>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-zinc-700 text-zinc-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">License</th>
              <th className="py-2 pr-4">Make</th>
              <th className="py-2 pr-4">Model</th>
              <th className="py-2 pr-4">Year</th>
              <th className="py-2 pr-4">Owner</th>
              {canDelete && <th className="py-2 pr-4"></th>}
            </tr>
          </thead>
          <tbody>
            {vehicles.map((v) => (
              <tr key={v.vehi_id} className="border-b border-zinc-800 hover:bg-zinc-800/50">
                <td className="py-2 pr-4 text-white">{v.vehi_id}</td>
                <td className="py-2 pr-4 text-white">{v.vehi_license}</td>
                <td className="py-2 pr-4 text-zinc-300">{v.vehi_make}</td>
                <td className="py-2 pr-4 text-zinc-300">{v.vehi_model}</td>
                <td className="py-2 pr-4 text-zinc-300">{v.vehi_year}</td>
                <td className="py-2 pr-4 text-zinc-300">{ownerName(v.owner_no)}</td>
                {canDelete && (
                  <td className="py-2 pr-4">
                    <button onClick={() => handleDelete(v.vehi_id)} className="text-red-400 hover:text-red-300 text-sm">
                      Delete
                    </button>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal isOpen={showModal} onClose={() => { setShowModal(false); resetForm(); }} title="Register New Vehicle">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          {formError && <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">{formError}</p>}
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Owner</label>
            <select value={ownerNo} onChange={(e) => setOwnerNo(e.target.value)}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required>
              <option value="" disabled>Select an owner</option>
              {owners.map((o) => <option key={o.owner_no} value={o.owner_no}>{o.owner_name}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-zinc-300 text-sm mb-1">License Plate</label>
            <input type="text" value={license} onChange={(e) => setLicense(e.target.value)} placeholder="CAB-1234"
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-zinc-300 text-sm mb-1">Make</label>
              <input type="text" value={make} onChange={(e) => setMake(e.target.value)}
                className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required />
            </div>
            <div>
              <label className="block text-zinc-300 text-sm mb-1">Model</label>
              <input type="text" value={model} onChange={(e) => setModel(e.target.value)}
                className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required />
            </div>
          </div>
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Year</label>
            <input type="number" value={year} onChange={(e) => setYear(e.target.value)}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required />
          </div>
          <button type="submit" disabled={submitting}
            className="bg-orange-600 hover:bg-orange-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition">
            {submitting ? "Registering..." : "Register Vehicle"}
          </button>
        </form>
      </Modal>
    </div>
  );
}

export default Vehicles;