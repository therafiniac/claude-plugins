# Capability: Rate limiting
Kind: capability
Ask when: the project has a server and any of: login, sign-up, password reset, public forms, search, uploads, paid third-party calls (AI, SMS, email), or a public API.
Default: react-express → express-rate-limit. nextjs or astro (on-demand routes) on a long-running host → rate-limiter-flexible. Serverless or edge hosts → upstash-ratelimit. Static output → skip (use the form service's limits).
Verified: drafted November 2026, not yet re-verified option by option. Verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| express-rate-limit | adopt | Express API. Middleware per route or router | react-express | free (MIT); a Redis store when running more than one instance |
| rate-limiter-flexible | adopt | Any Node server. Memory store for one instance, Redis or Postgres store for several | nextjs, react-express, astro (on-demand routes) | free (ISC) |
| upstash-ratelimit | adopt | Serverless or edge functions, where memory does not survive between requests | nextjs, astro (on-demand routes), react-express | Upstash free tier; pay per request |
| cloudflare-rules | trial | The site is behind Cloudflare and you want a coarse limit before traffic reaches the app. Add-on, not a replacement for per-user limits | any | free plan includes a small number of rules; paid plans |
| hand-rolled-map | hold | Never. A `Map` of counters resets on every restart, is per-instance, grows without bound, and has no tests | any | free |

## Option: express-rate-limit
Setup: `express-rate-limit`. With more than one instance, add `rate-limit-redis` and a Redis client. One `limits.ts` module exports the named limiters (`authLimiter`, `formLimiter`, `apiLimiter`).
Conventions:
- Apply limiters on the routes they protect, not globally only. Login and reset routes get the strictest.
- Set `app.set('trust proxy', <number of proxies>)` to match the host, so `req.ip` is the client's address and not the proxy's. Never `true` unless every hop is trusted.
- Use `standardHeaders` so clients get `RateLimit-*` headers, and a JSON 429 body in the API's error format.
Security checks (added to security-audit):
- `trust proxy` matches the deployment; a client cannot spoof its IP with `X-Forwarded-For` (§6, §13).
Sources: https://express-rate-limit.mintlify.app/, https://github.com/express-rate-limit/rate-limit-redis

## Option: rate-limiter-flexible
Setup: `rate-limiter-flexible`. One instance → `RateLimiterMemory`. Several instances → `RateLimiterRedis` (with `ioredis`) or `RateLimiterPostgres` if the project already has Postgres. One `limits.ts` module exports named limiters; a small helper turns a rejection into the framework's 429 response.
Conventions:
- Call the limiter at the top of each protected server action or route handler, after validation and before any costly work.
- Derive the client IP from the host's documented header only (for example the platform's forwarded-for header with the proxy count known), never from an arbitrary request header.
- For login, use two limiters: per IP, and per account identifier, so one attacker cannot try many passwords on one account from many IPs.
Security checks (added to security-audit):
- The IP source is the host's trusted header, not a client-controlled one (§13).
- The memory store is used only when the app runs as a single instance; the deployment matches (§13).
Sources: https://github.com/animir/node-rate-limiter-flexible/wiki

## Option: upstash-ratelimit
Setup: `@upstash/ratelimit` and `@upstash/redis`. Create a Redis database in Upstash. Env: `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` (server-only) in the validated env module. One `limits.ts` exports named `Ratelimit` instances (for example a sliding window per route group).
Conventions:
- Call `limit(identifier)` at the top of each protected handler; on failure return 429 with `Retry-After` from the result's reset time.
- Use a distinct `prefix` per limiter, so counters for login and search never collide.
- Decide fail-open or fail-closed per limiter if Upstash is unreachable: fail closed for login and paid APIs, open for search. Record it in the code with a comment.
Security checks (added to security-audit):
- The REST token is server-only (§5).
Sources: https://upstash.com/docs/redis/sdks/ratelimit-ts/overview

## Option: cloudflare-rules
Setup: in the Cloudflare dashboard, add a rate limiting rule on the paths that matter (for example `/api/*`, `/login`), with a block or managed challenge action. Record the rule in `docs/runbook.md`.
Conventions:
- Edge rules are a coarse first layer. Per-user and per-account limits stay in the app.
Sources: https://developers.cloudflare.com/waf/rate-limiting-rules/

## Shared
Conventions:
- Key by user ID when authenticated, else by client IP. Login, sign-up, password reset, and one-time codes are also keyed by the account identifier.
- Return 429 with `Retry-After` and an actionable message. Never reveal whether an account exists in the message.
- Health checks and static assets are never limited.
- Limits live in one module with named constants, so audits and tests can find them.
Security checks (added to security-audit):
- Every login, sign-up, reset, one-time-code, public-form, search, and paid-third-party endpoint is limited (§1, §13).
- Limit hits are logged at `warn` with the key type (IP or user), never the raw credential (§8).
Performance checks (added to performance-audit):
- The limiter runs before database queries and third-party calls in the handler (§7).
Testing:
- A test per limited endpoint: the request at the limit passes, the next one gets 429 with `Retry-After`. Fake the clock.
