# Developer Guide

## Commands

`flake.nix` is split into three independent flakes — root, `frontend/`, `backend/` — each with its
own `flake.lock` and `.envrc`. Run each flake's `nix` commands from its own directory.

### Root (formatting, lint)

- `nix fmt` - Format `*.nix` and `*.json`/`*.md`/`*.yaml` repo-wide
- `nix flake check` - Run format/lint checks (statix, deadnix, actionlint, zizmor, workflow-timeout)

### Frontend

- `cd frontend && nix fmt` - Format `*.purs`
- `cd frontend && nix flake check` - Run checks (format, PureScript test)
- `cd frontend && nix build . --out-link output` - Compile `src/` into per-module ES modules
- `cd frontend && purs-nix compile` - Generate `output/` for editor/LSP use
- `cd frontend && npm install` - Install npm dependencies
- `cd frontend && npm run serve` - Start the dev server at http://localhost:5173
  (`/api/*` proxies to `http://localhost:8080`, see `vite.config.js`)
- `cd frontend && npm run build` - Build for production into `dist/`
  (requires `purs-nix compile` first)
- `cd frontend && npm run preview` - Build for production and preview via `wrangler dev`
- `cd frontend && npm run deploy` - Build for production and deploy to Cloudflare Workers

### Backend

- `cd backend && nix fmt` - Format `*.ml`
- `cd backend && nix flake check` - Run checks (format, build, test)
- `cd backend && nix build .` - Build the backend
- `cd backend && nix run .#backend-services` - Start a local Postgres (creates the `todo`
  database and applies `schema.sql` on first run; keep running in its own terminal). The
  devShell exports `DATABASE_URL` for it automatically — no manual setup needed. Data lives
  in `backend/data/`, gitignored.
- `cd backend && psql $DATABASE_URL -f schema.sql` - Re-apply the schema after editing it
  (the automatic apply above only runs once, when the database is first created)
- `cd backend && dune exec backend` - Run the backend HTTP server at http://localhost:8080
  (requires the local Postgres from `nix run .#backend-services` to be running)
- `cd backend && dune utop bin` - Start a REPL (utop) with the backend's modules loaded
- `cd backend && dune build backend.opam` - Regenerate `backend.opam` after editing
  `dune-project`'s `depends`
- `cd backend && nix build .#container` - Build the backend container image via nix2container
