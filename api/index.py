"""
Vercel Python entrypoint.

Vercel's Python runtime looks for an ASGI-compatible `app` object in
files under /api and serves it directly (no adapter needed). The real
app lives in apps/backend/app/main.py as a normal package, so we just
extend sys.path to make `app.*` importable from here and re-export it.
"""
import os
import sys

BACKEND_DIR = os.path.join(os.path.dirname(__file__), "..", "apps", "backend")
sys.path.insert(0, os.path.abspath(BACKEND_DIR))

from starlette.applications import Starlette
from starlette.routing import Mount

from app.main import app as fastapi_app  # noqa: E402

# The rewrite in vercel.json forwards the original request path (e.g.
# "/api/jobs") to this function, but fastapi_app's routes are defined
# unprefixed ("/jobs") so that `uvicorn app.main:app` still works
# unchanged for local dev. Mounting under /api here reconciles the two
# without touching the routers.
app = Starlette(routes=[Mount("/api", app=fastapi_app)])
