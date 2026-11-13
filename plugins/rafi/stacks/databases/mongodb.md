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
- Versioned migration scripts in `migrations/`, applied by `db:migrate` and recorded in a `migrations` collection (for example with `migrate-mongo`), so every environment knows which have run.

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

## Migration checks (used by /rafi:migration)
- A new required field: old documents lack it, so saving them fails validation. Backfill first, then make the field required in the schema.
- Renames and type changes: the app reads both shapes during the transition. Backfill with `$rename` or `$set` in batches.
- Backfills use `bulkWrite` in batches filtered on documents not yet migrated (so a rerun skips finished work), iterate by `_id` ranges, and log progress.
- Index builds on large collections use heavy resources: build in a low-traffic window, or as a rolling build on a managed cluster. Create the index before deploying the code that relies on it.
- Dropping a field or collection happens only after the code that reads it is gone from production.

## CI (added to .github/workflows/ci.yml)
None. Tests use `mongodb-memory-server`, which downloads a MongoDB binary on first run. Cache it between CI runs if downloads are slow.
