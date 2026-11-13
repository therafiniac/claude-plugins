---
name: release-check
description: Pre-release gate. Full checks, all four audits, dependency advisories, and operational readiness (CI, runbook, observability, rate limits, changelog).
disable-model-invocation: true
---
1. Run `pnpm check` and `pnpm build`. Run `pnpm test:e2e` and `pnpm lighthouse` if those scripts exist. Run `pnpm audit --prod`; any high or critical advisory is a blocker unless an ADR accepts it.
2. Invoke the `rafi:security-audit`, `rafi:performance-audit`, and `rafi:accessibility-audit` skills with `full`. Also invoke `rafi:seo-audit` with `full` unless the site has no public pages.
3. Operational readiness. Each item is Pass, Fail (a blocker), or Needs manual verification:
   - Run this on `dev` (or a `release/` branch). `.github/workflows/ci.yml` exists. Ask me to confirm the latest CI run on this branch is green; you cannot see GitHub.
   - Staging: the `dev` build is deployed to staging and the main flows were tried there (ask me).
   - `docs/runbook.md` has no `<placeholders>` left: deploy, rollback, health check, backups and restore, secrets rotation, where logs and alerts are, contacts.
   - `docs/runbook.md` "Pending migrations" holds nothing that must finish before this release.
   - Observability from `docs/stack-profile.md` is wired: error tracking initialised for every runtime, structured logging on the server, the health endpoint checks dependencies. If the profile has no observability capability, that is a High finding: `/rafi:add-capability observability`.
   - Every endpoint the stack profile's rate-limiting rules cover is limited. No rate-limiting capability on a project with a server and logins or forms is a High finding.
   - `SECURITY.md` has a real contact. `.env.example` lists every variable the env module validates.
   - `CHANGELOG.md` has entries under `## [Unreleased]`. Propose the release heading (`## [x.y.z] - <today>`) with the version from Semantic Versioning; do not edit it until I agree.
4. Report Critical and High findings only, and confirm each log in `docs/audits/` is updated. End with a verdict: ship or hold, with blockers listed.
5. Remind me of the manual checks: Search Console, Lighthouse field data, keyboard and screen-reader pass on core flows, env vars set in hosting, a tested restore from backup, the uptime monitor and its alert, and the rollback steps in `docs/runbook.md`.
6. Last line: `Next:` on ship, do the manual checks above, then `/rafi:release`. On hold, `/rafi:fix-issue <first blocker>`, then run `/rafi:release-check` again. It is only a suggestion. Never run it.
