import { NavLink, Outlet } from "react-router-dom";
import { useAuth } from "../context/useAuth";

function Layout() {
  const { employee, logout } = useAuth();

  const navItems = [
    { to: "/", label: "Dashboard" },
    { to: "/job-assignments", label: "Job Assignments" },
    { to: "/vehicles", label: "Vehicles" },
    { to: "/vehicle-visits", label: "Visits" },
    { to: "/customers", label: "Customers" },
    { to: "/employees", label: "Employees" },
    { to: "/jobs", label: "Job Catalog" },
  ];

  return (
    <div className="min-h-screen flex bg-slate-900 text-white">
      <aside className="w-64 bg-slate-800 flex flex-col p-4">
        <h1 className="text-xl font-bold mb-8">PrimeAutocare</h1>

        <nav className="flex flex-col gap-1 flex-1">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `px-3 py-2 rounded transition ${
                  isActive
                    ? "bg-blue-600 text-white"
                    : "text-slate-300 hover:bg-slate-700"
                }`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="border-t border-slate-700 pt-4 mt-4">
          <p className="text-sm text-slate-400 mb-2">
            {employee?.emp_gname} {employee?.emp_fname}
          </p>
          <button
            onClick={logout}
            className="w-full bg-red-600 hover:bg-red-500 text-white text-sm py-2 rounded transition"
          >
            Log Out
          </button>
        </div>
      </aside>

      <main className="flex-1 p-8">
        <Outlet />
      </main>
    </div>
  );
}

export default Layout;