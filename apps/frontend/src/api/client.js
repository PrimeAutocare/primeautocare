// Same origin in production: Vercel rewrites /api/* to the Python function,
// so a relative base works with no env var needed. Local dev overrides this
// via VITE_API_BASE_URL (see .env.example) to point at the standalone backend.
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "/api";

async function request(endpoint, options = {}) {
  const headers = {
    "Content-Type": "application/json",
    ...options.headers,
  };

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
    credentials: "include",
  });

  if (!response.ok) {
    const errorBody = await response.json().catch(() => ({}));
    throw new Error(errorBody.detail || `Request failed: ${response.status}`);
  }

  if (response.status === 204) return null;

  return response.json();
}

export function get(endpoint) {
  return request(endpoint, { method: "GET" });
}

export function post(endpoint, body) {
  return request(endpoint, { method: "POST", body: JSON.stringify(body) });
}

export function patch(endpoint, body) {
  return request(endpoint, { method: "PATCH", body: JSON.stringify(body) });
}

export function del(endpoint) {
  return request(endpoint, { method: "DELETE" });
}