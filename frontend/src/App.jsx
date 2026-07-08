import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import Login from "./pages/Login";
import Layout from "./components/Layout";

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
          <Route index element={<div>Dashboard placeholder</div>} />
          <Route path="job-assignments" element={<div>Job Assignments placeholder</div>} />
          <Route path="vehicles" element={<div>Vehicles placeholder</div>} />
          <Route path="vehicle-visits" element={<div>Visits placeholder</div>} />
          <Route path="vehicle-owners" element={<div>Owners placeholder</div>} />
          <Route path="employees" element={<div>Employees placeholder</div>} />
          <Route path="jobs" element={<div>Job Catalog placeholder</div>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;