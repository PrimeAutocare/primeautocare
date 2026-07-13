import { useEffect, useState } from "react";
import { get } from "../api/client";
import { useAuth } from "../context/useAuth";

function Dashboard() {
  const { employee } = useAuth();
  const [visits, setVisits] = useState([]);
  const [assignments, setAssignments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  async function loadData() {
    setLoading(true);
    setError("");
    try {
      const [visitsData, assignmentsData] = await Promise.all([
        get("/vehicle-visits"),
        get("/job-assignments"),
      ]);
      setVisits(visitsData);
      setAssignments(assignmentsData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    (async () => {
      await loadData();
    })();
  }, []);

  if (loading) return <p className="text-slate-400">Loading...</p>;
  if (error) return <p className="text-red-400">{error}</p>;

  const activeVisits = visits.filter((v) => v.visit_status === "C" || v.visit_status === "I").length;
  const pendingJobs = assignments.filter((a) => a.jobassign_status === "P").length;
  const inProgressJobs = assignments.filter((a) => a.jobassign_status === "I").length;
  const completedToday = assignments.filter(
    (a) => a.jobassign_complete_dt === new Date().toISOString().split("T")[0]
  ).length;

  const cards = [
    { label: "Active Visits", value: activeVisits, color: "bg-blue-600" },
    { label: "Pending Jobs", value: pendingJobs, color: "bg-yellow-600" },
    { label: "In-Progress Jobs", value: inProgressJobs, color: "bg-orange-600" },
    { label: "Completed Today", value: completedToday, color: "bg-green-600" },
  ];

  const recentAssignments = [...assignments]
    .sort((a, b) => b.jobassign_id - a.jobassign_id)
    .slice(0, 5);

  return (
    <div>
      <h2 className="text-2xl font-bold mb-2">
        Welcome, {employee.emp_gname}
      </h2>
      <p className="text-slate-400 mb-8">Here's what's happening at PrimeAutocare today.</p>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
        {cards.map((card) => (
          <div key={card.label} className={`${card.color} rounded-lg p-5`}>
            <p className="text-3xl font-bold text-white">{card.value}</p>
            <p className="text-sm text-white/80 mt-1">{card.label}</p>
          </div>
        ))}
      </div>

      <h3 className="text-lg font-semibold mb-4">Recent Job Assignments</h3>
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-700 text-slate-400 text-sm">
              <th className="py-2 pr-4">ID</th>
              <th className="py-2 pr-4">Visit</th>
              <th className="py-2 pr-4">Job</th>
              <th className="py-2 pr-4">Status</th>
            </tr>
          </thead>
          <tbody>
            {recentAssignments.map((a) => (
              <tr key={a.jobassign_id} className="border-b border-slate-800">
                <td className="py-2 pr-4">{a.jobassign_id}</td>
                <td className="py-2 pr-4">{a.visit_id}</td>
                <td className="py-2 pr-4">{a.job_no}</td>
                <td className="py-2 pr-4">{a.jobassign_status}</td>
              </tr>
            ))}
            {recentAssignments.length === 0 && (
              <tr>
                <td colSpan={4} className="py-4 text-slate-500">No job assignments yet.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Dashboard;