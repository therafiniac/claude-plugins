# Database profile: PostgreSQL
Kind: database. Pair it with a framework profile.

## Stack
PostgreSQL with a typed query layer: Drizzle or Prisma. Choose in bootstrap and record the choice and the reason in `docs/adr/001-stack.md`. Migrations are versioned files committed to git.

## Scaffold contract
- Env: `DATABASE_URL` in `.env.example` and in the validated env module.
- One database module (client and pool). In serverless, use the provider's pooler or a very small pool.
- Scripts: `db:generate` (create a migration), `db:migrate` (apply), `db:seed` (idempotent seed). Map them to the chosen tool's commands.
- Tests run against a real Postgres, never mocks: a service container in CI and a local container (Docker or Podman) for development. Reset state between tests with rolled-back transactions or table truncation.
- CI: add a Postgres service container to the jobs in `.github/workflows/ci.yml` and `e2e.yml` that run tests, and set `DATABASE_URL`. Match the image version to production:
```yaml
    services:
      postgres:
        image: postgres:17
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        ports: ['5432:5432']
        options: >-
          --health-cmd "pg_isready -U postgres"
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10
    env:
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
```

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
