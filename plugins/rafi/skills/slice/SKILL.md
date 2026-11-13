---
name: slice
description: Implement one approved slice with tests, checks, review, and audits.
argument-hint: <slice name from the approved plan>
disable-model-invocation: true
---
Slice: $ARGUMENTS

Precondition: an approved plan exists in this conversation or in `docs/prd/`. If not, tell me to run `/rafi:plan-feature` first and stop.

1. Restate the slice scope in three lines. Implement only that scope.
   If the slice changes a database schema, apply `${CLAUDE_PLUGIN_ROOT}/skills/migration/SKILL.md` steps 2, 3, and 5 to that change. Additive changes are done in this slice. For a breaking change, build only the expand phase here and list the remaining phases in `docs/runbook.md` under "Pending migrations".
2. Write tests alongside the code (cases in `.claude/rules/testing.md`). Use the `rafi:test-writer` subagent for large test suites.
3. Run `pnpm check`. Fix until it passes.
4. Run the `rafi:code-reviewer` subagent on the diff. Fix Blocker and Major findings.
5. Run the audits that match the change (Audit triggers table in CLAUDE.md). Fix Critical and High findings. Leave the rest logged.
   - auth, sessions, APIs, server actions, uploads, dependencies → `rafi:security-auditor` subagent
   - public pages, routes, metadata, URLs → `rafi:seo-audit` skill with `diff`
   - new queries, lists, pages, heavy dependencies → `rafi:performance-audit` skill with `diff`
   - UI components, forms, layout, color → `rafi:accessibility-audit` skill with `diff`
6. If the slice adds a user-facing flow, add or update a Playwright E2E test for it (`pnpm test:e2e`).
   Update the docs the slice changes: `docs/architecture.md` (data model, routes, env vars), `.env.example`, and `docs/runbook.md` (new services, workers, alerts, or deploy steps).
7. Report in five lines or fewer: what changed, checks run, findings fixed and remaining. Then commit the slice following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` (on its work branch, `type(scope): subject`, no attribution, then push) and give the commit header.
8. Last line: `Next:` plus one step. If the approved plan has slices left: `/clear`, then `/rafi:slice <next slice name>`. If this was the last slice: `/rafi:merge`. If a Critical or High finding is still open: `/rafi:fix-issue <finding>`. It is only a suggestion. Never run it.
