# Design

## Storage

Backend persistence is SQLite via caqti (`Dream.sql_pool` / `Dream.sql`), local file `backend/db.sqlite`,
schema in `backend/schema.sql`. Cloudflare D1 is the eventual production target; D1 speaks the same SQLite
dialect, so `schema.sql` and the SQL strings in `main.ml` carry over as-is. Cloudflare Containers cannot
hold a D1 binding directly, so the migration will route queries through the Worker via
`@cloudflare/containers`' `outboundByHost` — only the connection/execution layer changes.
