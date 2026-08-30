# CLAUDE.md

## Overview

## Docs

- `README.md` — Project overview and usage
- `CONTRIBUTING.md` — Developer guide: commands and workflow
- `docs/DESIGN.md` — Design and architecture

## Skills

## MCP

## opam-nix

- Add dependencies in `dune-project`'s `depends`, regenerate `hello.opam` with `dune build hello.opam` (inside `nix develop`, or `direnv exec . dune build hello.opam`), then commit it.
- Version resolution uses IFD (Import From Derivation) by default, so the first eval fetches opam-repository.
- To speed this up later, materialize: `materializeOpamProject'` to produce `package-defs.json`, commit it, and switch `nix/packages.nix` to `materializedDefsToScope`.
