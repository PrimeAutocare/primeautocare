import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "./context/useAuth";

import Login from "./pages/Login";
import Layout from "./components/Layout";
import Dashboard from "./pages/Dashboard";
import Customers from "./pages/Customers";
import Vehicles from "./pages/Vehicles";
import VehicleVisits from "./pages/VehicleVisits";
import Employees from "./pages/Employees";
import Jobs from "./pages/Jobs";
import JobAssignments from "./pages/JobAssignments";

function App() {
  const { employee, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
        Loading...
      </div>
    );
  }

  if (!employee) {
    return <Login />;
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="job-assignments" element={<JobAssignments />} />
          <Route path="vehicles" element={<Vehicles />} />
          <Route path="vehicle-visits" element={<VehicleVisits />} />  
          <Route path="customers" element={<Customers />} />
          <Route path="employees" element={<Employees />} />
          <Route path="jobs" element={<Jobs />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;