import { useEffect, useState } from "react";
import { get, post, del } from "../api/client";

function Employees() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const [gname, setGname] = useState("");
  const [fname, setFname] = useState("");
  const [phone, setPhone] = useState("");
  const [emailInput, setEmailInput] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState("T");

  const ROLE_LABELS = { A: "Admin", S: "Supervisor", T: "Technician" };

  async function loadEmployees() {
    setLoading(true);
    setError("");
    try {
      const data = await get("/employees");
      setEmployees(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    (async () => {
      await loadEmployees();
    })();
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError("");
    setSubmitting(true);
    try {
      await post("/employees", {
        emp_gname: gname,
        emp_fname: fname,
        emp_phone: phone,
        emp_email: emailInput,
        emp_passhash: password,
        emp_role: role,
        emp_create_dt: new Date().toISOString().split("T")[0],
      });
      setGname("");
      setFname("");
      setPhone("");
      setEmailInput("");
      setPassword("");
      setRole("T");
      await loadEmployees();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(empNo) {
    if (!confirm("Delete this employee? This cannot be undone.")) return;
    setError("");
    try {
      await del(`/employees/${empNo}`);
      await loadEmployees();
    } catch (err) {
      setError(err.message);
    }
  }

  if (loading) return <p className="text-slate-400">Loading...</p>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Employees</h2>

      <form
        onSubmit={handleSubmit}
        className="bg-slate-800 p-6 rounded-lg mb-8 flex flex-col gap-4 max-w-lg"
      >
        <h3 className="text-lg font-semibold">Add New Employee</h3>

        {formError && (
          <p className="bg-red-500/10 text-red-400 text-sm p-2 rounded">
            {formError}
          </p>
        )}

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-slate-300 text-sm mb-1">First Name</label>
            <input
              type="text"
              value={gname}
              onChange={(e) => setGname(e.target.value)}
              className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label className="block text-slate-300 text-sm mb-1">Last Name</label>
            <input
              type="text"
              value={fname}
              onChange={(e) => setFname(e.target.value)}
              className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
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

        <div>
          <label className="block text-slate-300 text-sm mb-1">Password</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <div>
          <label className="block text-slate-300 text-sm mb-1">Role</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full p-2 rounded bg-slate-700 text-white outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="T">Technician</option>
            <option value="S">Supervisor</option>
            <option value="A">Admin</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white font-semibold py-2 rounded transition"
        >
          {submitting ? "Adding..." : "Add Employee"}
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
              <th className="py-2 pr-4">Role</th>
              <th className="py-2 pr-4"></th>
            </tr>
          </thead>
          <tbody>
            {employees.map((emp) => (
              <tr key={emp.emp_no} className="border-b border-slate-800 hover:bg-slate-800/50">
                <td className="py-2 pr-4">{emp.emp_no}</td>
                <td className="py-2 pr-4">{emp.emp_gname} {emp.emp_fname}</td>
                <td className="py-2 pr-4">{emp.emp_phone}</td>
                <td className="py-2 pr-4">{emp.emp_email}</td>
                <td className="py-2 pr-4">{ROLE_LABELS[emp.emp_role] ?? emp.emp_role}</td>
                <td className="py-2 pr-4">
                  <button
                    onClick={() => handleDelete(emp.emp_no)}
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

export default Employees;