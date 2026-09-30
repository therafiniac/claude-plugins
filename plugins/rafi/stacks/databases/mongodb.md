# Database profile: MongoDB (Mongoose)
Kind: database. Pair it with a framework profile.

## Stack
MongoDB with Mongoose. Tests use `mongodb-memory-server`.

## Scaffold contract
- Env: `MONGODB_URI` in `.env.example` and in the validated env module.
- One connection module. In Next.js, cache the connection on `globalThis` so hot reloads and serverless invocations reuse it.
- `mongoose.set('sanitizeFilter', true)` at startup.
- Models are used only in the feature's repo layer. Indexes are declared in the schema.
- Tests use `mongodb-memory-server`, with collections reset between tests.
- Idempotent seed script `db:seed` for local development.

## Conventions
- `.lean()` and field projection on reads. Never return raw documents to clients; map to DTOs (no password hashes, no internal flags).
- Pagination with a capped page size. Use a cursor on an indexed field for large collections.
- Invariants across several documents use a transaction (needs a replica set) or are redesigned as a single-document write.
- Schema changes are additive by default. Backfill with a versioned script.

## Security checks (added to security-audit)
- Zod schemas coerce filter values to strings or numbers, so objects like `{ "$ne": null }` are rejected (§4, NoSQL injection).
- No `$where` or server-side JavaScript. User input inside `$regex` is escaped.
- The database user has only the privileges the app needs. The connection string lives only in env. A hosted database is not open to the whole internet without a reason.

## Performance checks (added to performance-audit)
- Run `.explain('executionStats')` on list and search queries. Look for COLLSCAN. Confirm index use, `.lean()`, projection, and capped limits.
- Compound index order matches the query: equality fields, then sort, then range.
- No N+1: batch with `$in` or an aggregation instead of a query per item.
- The connection pool is sized for the deployment. In serverless, keep it small and reuse the connection.
