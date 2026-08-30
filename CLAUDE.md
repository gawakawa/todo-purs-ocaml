# CLAUDE.md

## Overview

Todo app: frontend in PureScript + React (`frontend/`), backend in OCaml (`backend/`).

## Docs

- `README.md` — Project overview and usage
- `CONTRIBUTING.md` — Developer guide: commands and workflow
- `docs/DESIGN.md` — Design and architecture

## Skills

## MCP

## opam-nix

- Add dependencies in `backend/dune-project`'s `depends`, regenerate `backend/backend.opam` with
  `dune build backend.opam` from `backend/`, then commit it.
- Version resolution uses IFD (Import From Derivation) by default, so the first eval fetches
  opam-repository.
- To speed this up later, materialize: `materializeOpamProject'` to produce `package-defs.json`,
  commit it, and switch `nix/packages.nix` to `materializedDefsToScope`.
