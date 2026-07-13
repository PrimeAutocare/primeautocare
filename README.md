# PrimeAutocare

A vehicle service center management system: tracks owners, vehicles, service
visits, and the job assignments performed on each visit.

## Structure

```
apps/
  backend/     FastAPI + SQLAlchemy API (Python)
  frontend/    React 19 + Vite + Tailwind SPA
database/      Postgres schema, per-table migrations, seed data
docs/          ERD diagrams
```

## Running locally

The fastest way to get everything running is Docker Compose — it starts
Postgres (seeded from `database/schema.sql` and `database/test_data.sql`),
the backend on `:8000`, and the frontend on `:5173`:

```bash
docker compose up --build
```

### Running services individually

**Backend**

```bash
cd apps/backend
cp .env.example .env   # fill in DATABASE_URL / JWT_SECRET_KEY
pip install -r requirements.txt
uvicorn app.main:app --reload
```

**Frontend**

```bash
cd apps/frontend
cp .env.example .env   # fill in VITE_API_BASE_URL if not using the default
npm install
npm run dev
```

## Tests

```bash
cd apps/backend
pytest
```

## CI

- `.github/workflows/backend-ci.yml` — installs deps and runs `pytest` on backend changes.
- `.github/workflows/frontend-ci.yml` — lints and builds the frontend on frontend changes.
