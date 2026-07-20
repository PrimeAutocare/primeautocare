# PrimeAutocare frontend

React 19 + Vite + Tailwind single-page app for the PrimeAutocare service
center management system.

## Running

```bash
cp .env.example .env   # set VITE_API_BASE_URL if not using the default
npm install
npm run dev            # http://localhost:5173
```

## Scripts

| Command | What it does |
| --- | --- |
| `npm run dev` | Dev server with HMR |
| `npm run build` | Production build to `dist/` |
| `npm run lint` | ESLint |
| `npm run preview` | Serve the production build locally |

The API base URL comes from `VITE_API_BASE_URL`; in the Vercel deployment the
frontend and API share a domain, with `/api/*` rewritten to the serverless
backend (see the root [README](../../README.md)).
