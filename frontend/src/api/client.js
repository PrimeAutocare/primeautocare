const API_BASE_URL = "http://localhost:8000";

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