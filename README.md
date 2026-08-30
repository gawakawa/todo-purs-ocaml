# todo-purs-ocaml

## Overview

Todo app: frontend in PureScript + React (`frontend/`), backend in OCaml (`backend/`).

## Features

## Prerequisites

- Nix with flakes enabled

## Usage

## Directory Structure

```
/
├ flake.nix, flake.lock, .envrc
├ nix/            # flake-parts modules shared across frontend/backend
├ .github/
├ frontend/       # PureScript + React
│ ├ index.html, index.js, style.css
│ ├ package.json, vite.config.js
│ └ src/, test/
└ backend/        # OCaml
  ├ dune-project, backend.opam
  └ bin/, test/
```
