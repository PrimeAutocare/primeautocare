import { useEffect, useState } from "react";
import { get, post, patch } from "../api/client";
import { useAuth } from "../context/useAuth";
import Modal from "../components/Modal";

function JobAssignments() {
  const { employee } = useAuth();
  const [assignments, setAssignments] = useState([]);
  const [visits, setVisits] = useState([]);
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [updatingId, setUpdatingId] = useState(null);
  const [showModal, setShowModal] = useState(false);

  const [visitId, setVisitId] = useState("");
  const [jobNo, setJobNo] = useState("");
  const [notes, setNotes] = useState("");

  const STATUS_OPTIONS = [
    { value: "P", label: "Pending" },
    { value: "I", label: "In-progress" },
    { value: "C", label: "Completed" },
    { value: "X", label: "Cancelled" },
  ];

  useEffect(() => {
    loadAll();
  }, []);

  async function loadAll() {
    setLoading(true);
    setError("");
    try {
      const [assignmentsData, visitsData, jobsData] = await Promise.all([
        get("/job-assignments"),
        get("/vehicle-visits"),
        get("/jobs"),
      ]);
      setAssignments(assignmentsData);
      setVisits(visitsData);
      setJobs(jobsData);
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
      await post("/job-assignments", {
        visit_id: Number(visitId),
        job_no: Number(jobNo),
        jobassign_assigned_by: employee.emp_no,
        jobassign_assign_dt: new Date().toISOString().split("T")[0],
        jobassign_status: "P",
        jobassign_notes: notes || null,
      });
      setVisitId("");
      setJobNo("");
      setNotes("");
      setShowModal(false);
      await loadAll();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStatusChange(jobassignId, newStatus) {
    setUpdatingId(jobassignId);
    setError("");
    const today = new Date().toISOString().split("T")[0];
    const updatePayload = { jobassign_status: newStatus };
    if (newStatus === "I") updatePayload.jobassign_start_dt = today;
    if (newStatus === "C") updatePayload.jobassign_complete_dt = today;
    try {
      await patch(`/job-assignments/${jobassignId}`, updatePayload);
      await loadAll();
    } catch (err) {
      setError(err.message);
    } finally {
      setUpdatingId(null);
    }
  }

  if (loading) return <p className="text-zinc-400">Loading...</p>;

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">Job Assignments</h2>
        <button onClick={() => setShowModal(true)}
          className="bg-orange-600 hover:bg-orange-500 text-white font-semibold px-4 py-2 rounded transition">
          + Assign Job
        </button>
      </div>

      {error && <p className="text-red-400 mb-4">{error}</p>}

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-zinc-700 text-zinc-400 text-sm">
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
              <tr key={a.jobassign_id} className="border-b border-zinc-800 hover:bg-zinc-800/50">
                <td className="py-2 pr-4 text-white">{a.jobassign_id}</td>
                <td className="py-2 pr-4 text-zinc-300">{a.visit_id}</td>
                <td className="py-2 pr-4 text-zinc-300">{a.job_no}</td>
                <td className="py-2 pr-4 text-zinc-300">{a.jobassign_assigned_by}</td>
                <td className="py-2 pr-4">
                  <select value={a.jobassign_status} disabled={updatingId === a.jobassign_id}
                    onChange={(e) => handleStatusChange(a.jobassign_id, e.target.value)}
                    className="bg-zinc-700 text-white text-sm rounded px-2 py-1 outline-none focus:ring-2 focus:ring-orange-500 disabled:opacity-50">
                    {STATUS_OPTIONS.map((opt) => <option key={opt.value} value={opt.value}>{opt.label}</option>)}
                  </select>
                </td>
                <td className="py-2 pr-4 text-zinc-300">{a.jobassign_cost ?? "-"}</td>
                <td className="py-2 pr-4 text-zinc-300">{a.jobassign_notes ?? "-"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal isOpen={showModal} onClose={() => { setShowModal(false); setFormError(""); }} title="Assign a Job">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          {formError && <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">{formError}</p>}
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Vehicle Visit</label>
            <select value={visitId} onChange={(e) => setVisitId(e.target.value)}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required>
              <option value="" disabled>Select a visit</option>
              {visits.map((v) => <option key={v.visit_id} value={v.visit_id}>Visit #{v.visit_id} — Vehicle #{v.vehi_id}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Job</label>
            <select value={jobNo} onChange={(e) => setJobNo(e.target.value)}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" required>
              <option value="" disabled>Select a job</option>
              {jobs.map((j) => <option key={j.job_no} value={j.job_no}>{j.job_desc}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-zinc-300 text-sm mb-1">Notes (optional)</label>
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} rows={2}
              className="w-full p-2 rounded bg-zinc-700 text-white outline-none focus:ring-2 focus:ring-orange-500" />
          </div>
          <button type="submit" disabled={submitting}
            className="bg-orange-600 hover:bg-orange-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition">
            {submitting ? "Assigning..." : "Assign Job"}
          </button>
        </form>
      </Modal>
    </div>
  );
}

export default JobAssignments;