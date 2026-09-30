## 4. Database & Query Performance

- [ ] Every query that filters, sorts, or joins on a column has an index
      on that column — check with the database's own query planner
      (`EXPLAIN`/`EXPLAIN ANALYZE` in Postgres/MySQL) rather than assuming.
- [ ] No N+1 query pattern — fetching a list, then issuing one additional
      query per item in a loop. Use a join, a batched `WHERE ... IN (...)`,
      or the ORM's own eager-loading mechanism instead.
- [ ] Every endpoint/query that can return an unbounded result set is
      paginated — no "fetch everything, filter in application code"
      pattern on a table that can grow.
- [ ] Connection pooling is configured appropriately for the deployment
      model — this matters especially for serverless functions, where a
      naive per-invocation connection can exhaust a database's connection
      limit under load; use a pooler (e.g. PgBouncer, or the database
      provider's own pooling layer) rather than raw per-request
      connections in that environment.
- [ ] Queries fetch only the columns/fields actually needed (`SELECT`
      specific columns, not `SELECT *` reflexively) for any table with
      wide rows or large text/blob columns.
- [ ] Slow-query logging/monitoring exists so a query that degrades as
      data grows gets caught before it becomes a production incident, not
      discovered by users first.

