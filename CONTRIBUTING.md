# Developer Guide

## Commands

Run `nix` commands from the repository root, and frontend commands from `frontend/`.

- `nix fmt` - Format code
- `nix flake check` - Run checks (format, lint)
- `nix build --out-link frontend/output` - Compile `frontend/src/` into per-module ES modules
- `cd frontend && purs-nix compile` - Generate `frontend/output/` for editor/LSP use
- `cd frontend && npm install` - Install npm dependencies
- `cd frontend && npm run serve` - Start the dev server at http://localhost:5173
- `cd frontend && npm run build` - Build for production into `frontend/dist/`
  (requires `purs-nix compile` first)
