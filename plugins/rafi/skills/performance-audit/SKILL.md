---
name: performance-audit
description: Run the performance audit standard against this codebase. Use only when asked to performance-audit, or to check Core Web Vitals, caching, queries, or bundle size.
argument-hint: "[diff | full | path or feature]"
context: fork
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git status) Bash(pnpm build) Bash(pnpm lighthouse) Bash(pnpm why *) Bash(pnpm list *)
---
Scope: $ARGUMENTS. Blank or `diff` = current branch vs main. `full` = whole codebase. Anything else = a path or feature.

Reference files live in `${CLAUDE_PLUGIN_ROOT}/skills/performance-audit/references/`, named by section number.

## Pick sections
Read `00-overview.md` there. Then read only the files for matching sections:

| Change | Sections |
|---|---|
| New page or layout | 1, 2, 5 |
| New list, query, or endpoint | 4, 3 |
| New dependency or heavy component | 6, 5 |
| Images, fonts, third-party scripts | 5 |
| Deploy or infra change | 7, 3 |
| Loading states, interaction feel | 8 |
| `full`, pre-release, quarterly | all |

If `docs/stack-profile.md` exists, also apply its performance checks.

## Method
- Measure before judging. Use the database's own query planner, a bundle analyzer, and Lighthouse CLI where available. Never propose a fix without a measurement.
- Run `pnpm build` and report route or bundle sizes from its output. Run `pnpm lighthouse` if the script exists and the scope includes pages.
- Judge every in-scope item: Pass, Fail, N/A (one-line reason), or Needs measurement (state the exact tool and command).
- Cite `file:line` for every Fail. Report only. Do not edit code.

## Output
1. Create or update `docs/audits/performance.md` with one row per Fail or Needs-measurement item: `Date | Section | Finding | Severity | Status`. Never delete rows. Mark resolved rows Fixed with the date.
2. Reply with only Fail and Needs-measurement items, grouped by severity, one line each. Maximum 30 lines.
3. Last line: `Next:` plus one step. A Critical or High finding: `/rafi:fix-issue <that finding>`. Only Needs-measurement items: do those checks by hand. Nothing found: continue what I was doing. If another command called this audit, that command gives the final next step instead. It is only a suggestion. Never run it.
