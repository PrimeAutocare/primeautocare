import { useEffect, useState } from "react";
import { get, post, del } from "../api/client";

function Jobs() {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const [jobDesc, setJobDesc] = useState("");

  async function loadJobs() {
    setLoading(true);
    setError("");
    try {
      const data = await get("/jobs");
      setJobs(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    (async () => {
      await loadJobs();
    })();
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/jobs", { job_desc: jobDesc });
      setJobDesc("");
      await loadJobs();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(jobNo) {
    if (!confirm("Delete this job type? This cannot be undone.")) return;
    setError("");
    try {
      await del(`/jobs/${jobNo}`);
      await loadJobs();
    } catch (err) {
      setError(err.message);
    }
  }

  if (loading) return <p className="text-slate-400">Loading...</p>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Job Catalog</h2>

      <form
        onSubmit={handleSubmit}
        className="bg-slate-800 p-6 rounded-lg mb-8 flex flex-col gap-4 max-w-lg"
      >
        <h3 className="text-lg font-semibold">Add New Job Type</h3>

        {formError && (
          <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">
            {formError}
          </p>
        )}

        <div>
          <label className="block text-slate-300 text-sm mb-1">Description</label>
          <input
            type="text"
            value={jobDesc}
            onChange={(e) => setJobDesc(e.target.value)}
            placeholder="e.g. Tyre Rotation"
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition"
        >
          {submitting ? "Adding..." : "Add Job"}
        </button>
      </form>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-700 text-slate-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">Description</th>
              <th className="py-2 pr-4"></th>
            </tr>
          </thead>
          <tbody>
            {jobs.map((j) => (
              <tr key={j.job_no} className="border-b border-slate-800 hover:bg-slate-800/50">
                <td className="py-2 pr-4">{j.job_no}</td>
                <td className="py-2 pr-4">{j.job_desc}</td>
                <td className="py-2 pr-4">
                  <button
                    onClick={() => handleDelete(j.job_no)}
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

export default Jobs;