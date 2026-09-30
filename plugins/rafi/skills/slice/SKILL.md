---
name: slice
description: Implement one approved slice with tests, checks, review, and audits.
argument-hint: <slice name from the approved plan>
disable-model-invocation: true
---
Slice: $ARGUMENTS

Precondition: an approved plan exists in this conversation or in `docs/prd/`. If not, tell me to run `/rafi:plan-feature` first and stop.

1. Restate the slice scope in three lines. Implement only that scope.
2. Write tests alongside the code (cases in `.claude/rules/testing.md`). Use the `rafi:test-writer` subagent for large test suites.
3. Run `pnpm check`. Fix until it passes.
4. Run the `rafi:code-reviewer` subagent on the diff. Fix Blocker and Major findings.
5. Run the audits that match the change (Audit triggers table in CLAUDE.md). Fix Critical and High findings. Leave the rest logged.
   - auth, sessions, APIs, server actions, uploads, dependencies → `rafi:security-auditor` subagent
   - public pages, routes, metadata, URLs → `rafi:seo-audit` skill with `diff`
   - new queries, lists, pages, heavy dependencies → `rafi:performance-audit` skill with `diff`
   - UI components, forms, layout, color → `rafi:accessibility-audit` skill with `diff`
6. If the slice adds a user-facing flow, add or update a Playwright E2E test for it (`pnpm test:e2e`).
7. Report in five lines or fewer: what changed, checks run, findings fixed and remaining. End with the commit message only, `type(scope): subject`, no explanation around it. Do not commit unless I say so.
