# PrimeAutocare

A vehicle service center management system: tracks customers, vehicles, service
visits, and the job assignments performed on each visit.

Built as a portfolio project by a two-person team —
[Inuka Wijerathna](https://github.com/InukaWijerathna) and
[Senuka Wijerathna](https://github.com/SenukaWijerathna) —
under the [PrimeAutocare](https://github.com/PrimeAutocare) organisation. The
project is designed to run itself: the app is deployed on Vercel, and
[Reporting_Automation](https://github.com/PrimeAutocare/Reporting_Automation)
generates business reports from the live database on a fortnightly cron,
publishing them to
[Generated_Reports](https://github.com/PrimeAutocare/Generated_Reports) with no
human in the loop.

## Repositories

| Repository | What it is |
| --- | --- |
| **PrimeAutocare** (this repo) | The application: API, frontend, database schema |
| [Reporting_Automation](https://github.com/PrimeAutocare/Reporting_Automation) | Scheduled Groovy scripts that build Excel reports from the database |
| [Generated_Reports](https://github.com/PrimeAutocare/Generated_Reports) | Where those reports land, current + archive per period |

## Structure

```
apps/
  backend/     FastAPI + SQLAlchemy API (Python)
  frontend/    React 19 + Vite + Tailwind SPA
api/           Vercel serverless entry point wrapping the backend
database/      Postgres schema, per-table migrations, seed data
docs/          ERD diagrams (conceptual + logical, with draw.io source)
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

## Deployment

`vercel.json` deploys the whole thing to Vercel: the frontend is built as a
static SPA, and `/api/*` is rewritten to `api/index.py`, a serverless function
that wraps the FastAPI backend. The database is hosted Postgres (Neon).

## CI

- `.github/workflows/backend-ci.yml` — installs deps and runs `pytest` on backend changes.
- `.github/workflows/frontend-ci.yml` — lints and builds the frontend on frontend changes.

## Team

- [Inuka Wijerathna](https://github.com/InukaWijerathna)
- [Senuka Wijerathna](https://github.com/SenukaWijerathna)
