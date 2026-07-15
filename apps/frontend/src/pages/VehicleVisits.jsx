import { useEffect, useState } from "react";
import { get, post, patch } from "../api/client";
import Modal from "../components/Modal";

function VehicleVisits() {
  const [visits, setVisits] = useState([]);
  const [vehicles, setVehicles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [updatingId, setUpdatingId] = useState(null);
  const [showModal, setShowModal] = useState(false);

  const [vehiId, setVehiId] = useState("");

  const STATUS_OPTIONS = [
    { value: "C", label: "Checked-In" },
    { value: "I", label: "In-progress" },
    { value: "D", label: "Done" },
    { value: "O", label: "Out / Picked Up" },
  ];

  useEffect(() => {
    loadAll();
  }, []);

  async function loadAll() {
    setLoading(true);
    setError("");
    try {
      const [visitsData, vehiclesData] = await Promise.all([get("/vehicle-visits"), get("/vehicles")]);
      setVisits(visitsData);
      setVehicles(vehiclesData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/vehicle-visits", {
        vehi_id: Number(vehiId),
        visit_check_in_dt: new Date().toISOString().split("T")[0],
        visit_status: "C",
      });
      setVehiId("");
      setShowModal(false);
      await loadAll();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStatusChange(visitId, newStatus) {
    setUpdatingId(visitId);
    setError("");
    const updatePayload = { visit_status: newStatus };
    if (newStatus === "O") updatePayload.visit_check_out_dt = new Date().toISOString().split("T")[0];
    try {
      await patch(`/vehicle-visits/${visitId}`, updatePayload);
      await loadAll();
    } catch (err) {
      setError(err.message);
    } finally {
      setUpdatingId(null);
    }
  }

  function vehicleLabel(id) {
    const vehicle = vehicles.find((v) => v.vehi_id === id);
    return vehicle ? `${vehicle.vehi_license} (${vehicle.vehi_make} ${vehicle.vehi_model})` : `#${id}`;
  }

  if (loading) return <p className="text-zinc-400">Loading...</p>;

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">Vehicle Visits</h2>
        <button onClick={() => setShowModal(true)}
          className="bg-orange-600 hover:bg-orange-500 text-white font-semibold px-4 py-2 rounded transition">
          + Check In Vehicle
        </button>
      </div>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-zinc-700 text-zinc-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">Vehicle</th>
              <th className="py-2 pr-4">Checked In</th>
              <th className="py-2 pr-4">Checked Out</th>
              <th className="py-2 pr-4">Status</th>
            </tr>
          </thead>
          <tbody>
            {visits.map((v) => (
              <tr key={v.visit_id} className="border-b border-zinc-800 hover:bg-zinc-800/50">
                <td className="py-2 pr-4 text-white">{v.visit_id}</td>
                <td className="py-2 pr-4 text-zinc-300">{vehicleLabel(v.vehi_id)}</td>
                <td className="py-2 pr-4 text-zinc-300">{v.visit_check_in_dt}</td>
                <td className="py-2 pr-4 text-zinc-300">{v.visit_check_out_dt ?? "-"}</td>
                <td className="py-2 pr-4">
                  <select value={v.visit_status} disabled={updatingId === v.visit_id}
                    onChange={(e) => handleStatusChange(v.visit_id, e.target.value)}
                    className="bg-zinc-700 text-white text-sm rounded px-2 py-1 outline-none focus:ring-2 focus:ring-orange-500 disabled:opacity-50">
                    {STATUS_OPTIONS.map((opt) => <option key={opt.value} value={opt.value}>{opt.label}</option>)}
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal isOpen={showModal} onClose={() => { setShowModal(false); setFormError(""); }} title="Check In a Vehicle">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          {formError && <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">{formError}</p>}
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Vehicle</label>
            <select value={vehiId} onChange={(e) => setVehiId(e.target.value)}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required>
              <option value="" disabled>Select a vehicle</option>
              {vehicles.map((v) => <option key={v.vehi_id} value={v.vehi_id}>{v.vehi_license} — {v.vehi_make} {v.vehi_model}</option>)}
            </select>
          </div>
          <button type="submit" disabled={submitting}
            className="bg-orange-600 hover:bg-orange-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition">
            {submitting ? "Checking In..." : "Check In"}
          </button>
        </form>
      </Modal>
    </div>
  );
}

export default VehicleVisits;