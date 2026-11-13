# Capability: Background jobs
Kind: capability
Ask when: work is slow (over about a second), must be retried (webhooks, emails, third-party calls), runs on a schedule (reports, cleanups, reminders), or must finish even if the user closes the page.
Default: postgres on a long-running host → pg-boss. Redis already in the stack, or mongodb on a long-running host → bullmq. Serverless hosts → inngest. Static output → skip.
Verified: drafted November 2026, not yet re-verified option by option. Verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| pg-boss | adopt | The project already has Postgres. Queue, retries, and cron schedules with no extra service | postgres; nextjs, react-express, astro (on-demand routes) on a long-running host | free (MIT) |
| bullmq | adopt | Redis is available, or throughput is high. Queues, retries, rate limits, repeatable jobs | mongodb, postgres; nextjs, react-express, astro (on-demand routes) on a long-running host | free (MIT); Redis hosting priced |
| inngest | trial | Serverless host with no place for a long-running worker. Durable steps triggered by events over HTTP | nextjs, react-express, astro (on-demand routes) | free tier; paid plans; self-hostable |
| trigger-dev | trial | Long tasks (minutes to hours) such as video or AI pipelines, with a run dashboard | nextjs, react-express | free tier; paid plans; self-hostable |
| fire-and-forget | hold | Never. An un-awaited promise or `setTimeout` in a request handler is lost on restart or when a serverless function freezes, and has no retries | any | free |

## Option: pg-boss
Setup: `pg-boss`, using the same `DATABASE_URL` (it creates its own schema). A separate worker entry point (`src/worker.ts`) and script (`worker`), deployed as its own process or service on the host. One `jobs/` folder: one file per job with its name, payload schema (Zod), and handler.
Conventions:
- The web app only sends jobs; the worker process runs them. Both import the job definitions from `jobs/`.
- Use `singletonKey` or the job's natural ID to prevent duplicates.
- Schedules are defined in code at worker startup, not created by hand.
Security checks (added to security-audit):
- pg-boss's schema is reachable only by the app's roles; job tables are not exposed through any API (§3).
Sources: https://github.com/timgit/pg-boss, https://timgit.github.io/pg-boss/

## Option: bullmq
Setup: `bullmq` and a Redis connection (`REDIS_URL`, validated). Redis must use `maxmemory-policy noeviction`, or jobs can silently disappear. A separate worker entry point (`src/worker.ts`) and script (`worker`), deployed as its own process or service. One `jobs/` folder: one file per job with its queue name, payload schema (Zod), and processor.
Conventions:
- Use a deterministic `jobId` to prevent duplicates.
- Set `attempts` and exponential `backoff` per job, and `removeOnComplete` / `removeOnFail` limits so Redis does not grow without bound.
- Repeatable jobs are declared in code at worker startup.
Security checks (added to security-audit):
- Redis requires a password and TLS in production and is not exposed to the internet (§10).
Sources: https://docs.bullmq.io/

## Option: inngest
Setup: `inngest`. One client module and a serve route (for example `app/api/inngest/route.ts` in nextjs) that registers the functions. Env: `INNGEST_EVENT_KEY`, `INNGEST_SIGNING_KEY` (server-only). Local development uses the Inngest dev server.
Conventions:
- Split each function into `step.run` calls, so a retry resumes after the last finished step instead of repeating it.
- Trigger by event names in one shared type, so senders and functions cannot drift.
Security checks (added to security-audit):
- The serve route verifies the signing key (the SDK does when the key is set); the key is present in every deployed environment (§6, §15).
Sources: https://www.inngest.com/docs

## Option: trigger-dev
Setup: `@trigger.dev/sdk` and the Trigger.dev CLI. Tasks live in `trigger/`, deployed to Trigger.dev (cloud or self-hosted) separately from the app. Env: `TRIGGER_SECRET_KEY` (server-only).
Conventions:
- The app triggers tasks by ID with a typed payload; tasks never import web-only code.
Security checks (added to security-audit):
- The secret key is server-only and differs per environment (§5).
- The privacy notice names the service as a processor if payloads include personal data (§11).
Sources: https://trigger.dev/docs

## Shared
Conventions:
- Handlers are idempotent: running a job twice has the same effect as once (check state first, use unique constraints or idempotency keys with third parties).
- Payloads carry IDs, not personal data or secrets. The handler loads current data when it runs and re-checks that the action is still allowed (the user may have been deleted or lost access).
- Every job has a timeout, a maximum number of attempts, and exponential backoff. Failed jobs stay visible somewhere a human checks (dashboard or a `warn` log with the job ID).
- The worker stops cleanly on `SIGTERM`: it finishes or releases the current job before exiting.
- `docs/runbook.md` lists the worker process, how to see failed jobs, and how to retry one.
Security checks (added to security-audit):
- Job payloads contain no secrets or unnecessary personal data (§5, §11).
- Handlers authorize against current data, not the payload's claims (§3).
Performance checks (added to performance-audit):
- Request handlers enqueue slow work instead of doing it inline (§7, §8).
- Batch jobs page through data; none loads an unbounded result set (§4).
Testing:
- Test each handler directly: the happy path, a retry after a failure (no duplicate effect), and the case where the referenced record no longer exists.
