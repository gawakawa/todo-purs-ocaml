# Developer Guide

## Commands

Run `nix` commands from the repository root, and frontend/backend commands from
`frontend/`/`backend/` respectively. There is no `packages.default` — always name the package
(`nix build .#frontend` / `nix build .#backend`).

- `nix fmt` - Format code
- `nix flake check` - Run checks (format, lint, backend build/test)
- `nix build .#frontend --out-link frontend/output` - Compile `frontend/src/` into per-module ES modules
- `cd frontend && purs-nix compile` - Generate `frontend/output/` for editor/LSP use
- `cd frontend && npm install` - Install npm dependencies
- `cd frontend && npm run serve` - Start the dev server at http://localhost:5173
- `cd frontend && npm run build` - Build for production into `frontend/dist/`
  (requires `purs-nix compile` first)
- `nix build .#backend` - Build the backend
- `cd backend && dune exec backend` - Run the backend executable
- `cd backend && dune utop bin` - Start a REPL (utop) with the backend's modules loaded
