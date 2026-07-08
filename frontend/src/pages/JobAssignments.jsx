import { useEffect, useState } from "react";
import { get } from "../api/client";

function JobAssignments() {
  const [assignments, setAssignments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    loadAssignments();
  }, []);

  async function loadAssignments() {
    setLoading(true);
    setError("");
    try {
      const data = await get("/job-assignments");
      setAssignments(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <p className="text-slate-400">Loading...</p>;
  if (error) return <p className="text-red-400">{error}</p>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Job Assignments</h2>

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-700 text-slate-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">Visit</th>
              <th className="py-2 pr-4">Job</th>
              <th className="py-2 pr-4">Assigned By</th>
              <th className="py-2 pr-4">Status</th>
              <th className="py-2 pr-4">Cost</th>
              <th className="py-2 pr-4">Notes</th>
            </tr>
          </thead>
          <tbody>
            {assignments.map((a) => (
              <tr key={a.jobassign_id} className="border-b border-slate-800 hover:bg-slate-800/50">
                <td className="py-2 pr-4">{a.jobassign_id}</td>
                <td className="py-2 pr-4">{a.visit_id}</td>
                <td className="py-2 pr-4">{a.job_no}</td>
                <td className="py-2 pr-4">{a.jobassign_assigned_by}</td>
                <td className="py-2 pr-4">{a.jobassign_status}</td>
                <td className="py-2 pr-4">{a.jobassign_cost ?? "-"}</td>
                <td className="py-2 pr-4">{a.jobassign_notes ?? "-"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default JobAssignments;