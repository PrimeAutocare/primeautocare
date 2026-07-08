import { useAuth } from "./context/AuthContext";
import Login from "./pages/Login";

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
    <div className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
      <h1 className="text-2xl">Welcome, {employee.emp_gname}!</h1>
    </div>
  );
}

export default App;