# Database profile: PostgreSQL
Kind: database. Pair it with a framework profile.

## Stack
PostgreSQL with a typed query layer: Drizzle or Prisma. Choose in bootstrap and record the choice and the reason in `docs/adr/001-stack.md`. Migrations are versioned files committed to git.

## Scaffold contract
- Env: `DATABASE_URL` in `.env.example` and in the validated env module.
- One database module (client and pool). In serverless, use the provider's pooler or a very small pool.
- Scripts: `db:generate` (create a migration), `db:migrate` (apply), `db:seed` (idempotent seed). Map them to the chosen tool's commands.
- Tests run against a real Postgres, never mocks: a local container (Podman or Docker) whose major version matches production. Reset state between tests with rolled-back transactions or table truncation.
- Test database, started once before running tests locally:
```bash
podman run -d --name <project>-pg-test -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=test -p 5432:5432 postgres:17
```
  Tests use `DATABASE_URL=postgres://postgres:postgres@localhost:5432/test`.

## Conventions
- Schema changes happen only through migrations. Never edit an applied migration; add a new one.
- Put constraints in the database: primary keys, foreign keys, `NOT NULL`, `UNIQUE`, `CHECK`. The app validates too, but the database is the last line of defense.
- Use `timestamptz` for times. Store money as integer minor units or `numeric`, never floating point.
- Select only the columns you need. No `SELECT *` in application queries.
- Writes that must succeed together run in one transaction.
- Pagination: keyset (cursor) for large tables, and always a capped page size.
- Map rows to DTOs before returning them (no password hashes or internal columns).

## Security checks (added to security-audit)
- Parameterized queries only. Never build SQL by string concatenation or template-literal interpolation of input, including inside an ORM's raw-SQL escape hatch (§4).
- The app's database role has no DDL rights in production. Migrations run with a separate role or step.
- Multi-tenant data: row-level security or an explicit owner filter on every query (§3).
- TLS to the database in production. Credentials only in env. The database is not exposed to the public internet.
- Backups are configured and a restore has been tested.

## Performance checks (added to performance-audit)
- Run `EXPLAIN (ANALYZE, BUFFERS)` on list and search queries. Look for sequential scans on large tables and confirm index use.
- Index every foreign key (Postgres does not do this automatically) and every column filtered or sorted on often. Composite index column order matches the query.
- No N+1: use joins or `WHERE id = ANY(...)`.
- The connection pool is sized for the deployment. Slow-query logging or `pg_stat_statements` is enabled.
- No long transactions, and no locks held across network calls.

## Migration checks (used by /rafi:migration)
- Every migration sets a short `lock_timeout` (for example `SET lock_timeout = '5s'`), so blocked DDL fails fast instead of queueing all traffic behind it.
- Indexes on populated tables: `CREATE INDEX CONCURRENTLY`. It cannot run inside a transaction, so put it in its own migration and disable the tool's transaction wrapper for that file.
- New column with a constant default: safe (no rewrite). A volatile default (for example `gen_random_uuid()`, `random()`, `clock_timestamp()`) rewrites the table: add the column nullable, backfill, then set the default.
- `SET NOT NULL` on a populated column: first `ADD CONSTRAINT ... CHECK (col IS NOT NULL) NOT VALID`, then `VALIDATE CONSTRAINT`, then `SET NOT NULL`, then drop the check.
- New foreign key on a populated table: `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` in a separate migration.
- Column type changes usually rewrite the table under an exclusive lock. Treat them as breaking: add a new column, backfill, switch reads, drop the old one.
- Renames and drops break the running app version. Always expand → contract across deploys.
- Migrations run as a release step before the new app version starts (for example the host's pre-deploy command running `db:migrate`), with a role that has DDL rights. The app's runtime role has none.

## CI (added to .github/workflows/ci.yml)
Add a service container to the `check` job, with the same major version as production, and point the tests at it:
```yaml
    services:
      postgres:
        image: postgres:17
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        ports: ["5432:5432"]
        options: >-
          --health-cmd "pg_isready -U postgres" --health-interval 5s --health-timeout 5s --health-retries 10
    env:
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
```
Run `pnpm db:migrate` before `pnpm check`.
