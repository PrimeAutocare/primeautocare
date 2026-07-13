import { useEffect, useState } from "react";
import { get, post, del } from "../api/client";

function VehicleOwners() {
  const [owners, setOwners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [emailInput, setEmailInput] = useState("");

  async function loadOwners() {
    setLoading(true);
    setError("");
    try {
      const data = await get("/vehicle-owners");
      setOwners(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadOwners();
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/vehicle-owners", {
        owner_name: name,
        owner_phone: phone,
        owner_email: emailInput,
      });
      setName("");
      setPhone("");
      setEmailInput("");
      await loadOwners();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(ownerNo) {
    if (!confirm("Delete this owner? This cannot be undone.")) return;
    setError("");
    try {
      await del(`/vehicle-owners/${ownerNo}`);
      await loadOwners();
    } catch (err) {
      setError(err.message);
    }
  }

  if (loading) return <p className="text-slate-400">Loading...</p>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Vehicle Owners</h2>

      <form
        onSubmit={handleSubmit}
        className="bg-slate-800 p-6 rounded-lg mb-8 flex flex-col gap-4 max-w-lg"
      >
        <h3 className="text-lg font-semibold">Add New Owner</h3>

        {formError && (
          <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">
            {formError}
          </p>
        )}

        <div>
          <label className="block text-slate-300 text-sm mb-1">Full Name</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <div>
          <label className="block text-slate-300 text-sm mb-1">Phone</label>
          <input
            type="text"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+94771234567"
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <div>
          <label className="block text-slate-300 text-sm mb-1">Email</label>
          <input
            type="email"
            value={emailInput}
            onChange={(e) => setEmailInput(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition"
        >
          {submitting ? "Adding..." : "Add Owner"}
        </button>
      </form>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-700 text-slate-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">Name</th>
              <th className="py-2 pr-4">Phone</th>
              <th className="py-2 pr-4">Email</th>
              <th className="py-2 pr-4"></th>
            </tr>
          </thead>
          <tbody>
            {owners.map((o) => (
              <tr key={o.owner_no} className="border-b border-slate-800 hover:bg-slate-800/50">
                <td className="py-2 pr-4">{o.owner_no}</td>
                <td className="py-2 pr-4">{o.owner_name}</td>
                <td className="py-2 pr-4">{o.owner_phone}</td>
                <td className="py-2 pr-4">{o.owner_email}</td>
                <td className="py-2 pr-4">
                  <button
                    onClick={() => handleDelete(o.owner_no)}
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

export default VehicleOwners;