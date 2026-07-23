import { useState, useEffect } from "react";
import { post, get } from "../api/client";
import { AuthContext } from "./AuthContextInstance";

export function AuthProvider({ children }) {
  const [employee, setEmployee] = useState(null);
  const [loading, setLoading] = useState(true);

  async function checkAuth() {
    try {
      const data = await get("/me");
      setEmployee(data);
    } catch {
      setEmployee(null);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    (async () => {
      await checkAuth();
    })();
  }, []);

  async function login(emp_username, password) {
    await post("/login", { emp_username, password });
    await checkAuth();
  }

  async function logout() {
    await post("/logout", {});
    setEmployee(null);
  }

  return (
    <AuthContext.Provider value={{ employee, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}