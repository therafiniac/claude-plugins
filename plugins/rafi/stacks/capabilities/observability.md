# Capability: Observability
Kind: capability
Ask when: the project will be deployed for real users. Skip only for throwaway prototypes.
Default: frameworks with a server (nextjs, react-express, astro with an adapter) → sentry + pino + uptime-monitor. Static output (astro static, react-spa) → sentry + uptime-monitor. wordpress → uptime-monitor (use a WordPress error-logging plugin for the rest).
Verified: drafted November 2026, not yet re-verified option by option. Verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| sentry | adopt | Error tracking with stack traces, releases, and source maps, on client and server | astro, nextjs, react-spa, react-express | free developer tier; paid plans |
| pino | adopt | Structured JSON logs from a Node server, with levels, request IDs, and redaction | nextjs, react-express, astro (on-demand routes) | free (MIT) |
| uptime-monitor | adopt | Every deployed project. An outside service calls the health endpoint and alerts you when it fails | any | free tiers (Better Stack, UptimeRobot); free to self-host (Uptime Kuma) |
| opentelemetry | trial | Several services, or traces must go to a vendor you already use | nextjs, react-express | free SDK; backend priced by vendor |
| console-only | hold | Never for production. Unstructured `console.log` has no levels, no request IDs, no redaction, and no alerts | any | free |

## Option: sentry
Setup: create a project in Sentry for each app. nextjs → `@sentry/nextjs` via the official wizard (`npx @sentry/wizard@latest -i nextjs`), which adds the client, server, and edge config files, `instrumentation.ts`, and wraps `next.config` with `withSentryConfig`. astro → `npx astro add @sentry/astro`. react-spa → `@sentry/react`, plus `@sentry/vite-plugin` for source maps. react-express → `@sentry/node`, loaded before anything else (`node --import ./instrument.mjs`), and `Sentry.setupExpressErrorHandler(app)` after the routes. Env: `SENTRY_DSN` (or the framework's public variant) in the validated env module; `SENTRY_AUTH_TOKEN` only in the CI or hosting build settings, for source map upload.
Conventions:
- Set `environment` and `release` (the git SHA) on every event, so errors map to a deploy.
- Keep `sendDefaultPii` off. Add a `beforeSend` that drops request bodies, cookies, and auth headers.
- Report only unexpected errors. Validation and not-found errors are expected and are not sent.
- Sample traces (`tracesSampleRate` well below 1 in production). Session replay stays off unless the privacy notice covers it.
- Alert rules: a new issue in production, and a spike in an existing one, go to email or chat.
Security checks (added to security-audit):
- No personal data, tokens, or secrets reach Sentry: `sendDefaultPii` is off and `beforeSend` scrubs (§8, §11).
- `SENTRY_AUTH_TOKEN` is never in the client bundle or the repo (§5).
- Source maps are uploaded to Sentry and not served publicly, or the choice to serve them is recorded in an ADR (§12).
- The privacy notice names Sentry as a processor (§11).
Performance checks (added to performance-audit):
- The browser SDK adds to the bundle. Load only the integrations you use; lazy-load replay if enabled (§6).
Sources: https://docs.sentry.io/platforms/javascript/guides/nextjs/, https://docs.sentry.io/platforms/javascript/guides/astro/, https://docs.sentry.io/platforms/javascript/guides/react/, https://docs.sentry.io/platforms/javascript/guides/express/

## Option: pino
Setup: `pino` (logger), `pino-pretty` as a dev dependency (readable local output only). One `logger` module that every server file imports. react-express → `pino-http` for per-request logs and request IDs. nextjs → check the Next.js docs on whether `pino` needs to be listed in `serverExternalPackages` for your version. Log level from a validated `LOG_LEVEL` env var (default `info`).
Conventions:
- JSON to stdout in production; the host collects it. Pretty output only in development.
- Every request gets an ID (incoming `x-request-id` if trusted, else generated). Child loggers carry it: `logger.child({ requestId })`.
- Levels: `error` needs a human, `warn` is unexpected but handled, `info` is a business event (signup, payment, job done), `debug` is off in production.
- `redact` paths for secrets and personal data: authorization and cookie headers, `password`, `token`, `email` where not needed.
- Log errors as objects (`logger.error({ err }, 'message')`), so the stack is kept.
Security checks (added to security-audit):
- Redaction covers auth headers, cookies, passwords, and tokens. No request bodies are logged by default (§8).
- Auth failures, permission denials, and rate-limit hits are logged at `warn` with the request ID, never with the credential (§8).
Performance checks (added to performance-audit):
- No synchronous logging transports in the request path in production (§7).
Sources: https://getpino.io/, https://github.com/pinojs/pino-http

## Option: uptime-monitor
Setup: in the monitoring service, add an HTTP check on the production health endpoint (the one the scaffold contract requires) every one to five minutes, alerting by email or chat after two failures in a row. Add a second check on the home page for public sites. Record the service and the alert target in `docs/runbook.md`.
Conventions:
- The health endpoint checks the app's real dependencies (database ping) with a short timeout, returns no secrets or versions, and is excluded from rate limits.
- Alerts go to a channel someone reads. Test the alert once by pointing a check at a bad URL.
Security checks (added to security-audit):
- The health response reveals no internal hostnames, versions, or stack traces (§10).
Sources: https://betterstack.com/docs/uptime/, https://uptimerobot.com/, https://github.com/louislam/uptime-kuma

## Option: opentelemetry
Setup: nextjs → `@vercel/otel` registered in `instrumentation.ts`. react-express → `@opentelemetry/sdk-node` with auto-instrumentations, loaded before the app. Export over OTLP to the vendor's endpoint, set by env. Verify the exact packages in the docs; the ecosystem changes often.
Conventions:
- Name the service and set `deployment.environment` and the version on the resource.
- Sample in production. Propagate trace context to every outgoing HTTP call between your services.
Security checks (added to security-audit):
- Span attributes contain no personal data, tokens, or full SQL with values (§8, §11).
Sources: https://opentelemetry.io/docs/languages/js/, https://nextjs.org/docs/app/guides/open-telemetry

## Shared
Conventions:
- `docs/runbook.md` lists where logs, errors, and uptime alerts are, and who receives them.
- Every caught-and-rethrown error keeps its cause (`new AppError('...', { cause: err })`).
Security checks (added to security-audit):
- Clients get a generic error with the request ID; the full detail exists only in logs and error tracking (§8).
