---
name: security-audit
description: Run the security audit standard (OWASP-aligned) against this codebase. Use only when asked to security-audit or security-review, or to check auth, API, upload, or dependency security.
argument-hint: "[diff | full | path or feature]"
context: fork
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git status)
---
Scope: $ARGUMENTS. Blank or `diff` = current branch vs main. `full` = whole codebase. Anything else = a path or feature name.

Reference files live in `${CLAUDE_PLUGIN_ROOT}/skills/security-audit/references/`, named by section number (e.g. `03-access-control-authorization.md`).

## Pick sections
Read `00-overview.md` there (severity scale, statuses). Then read only the files for matching sections:

| Change | Sections |
|---|---|
| Login, sessions, passwords | 1, 2, 3 |
| New endpoint, server action, API route | 3, 4, 6, 8 |
| User-generated or rendered content | 4, 12 |
| File upload or storage | 7, 3 |
| New dependency, CI or deploy change | 9, 14, 10 |
| Third-party integration, webhook | 15, 5 |
| Personal or sensitive data | 11, 5 |
| Multi-step, payment, or abuse-prone flow | 13, 3 |
| `full`, pre-release, quarterly | all |

If `docs/stack-profile.md` exists, also apply its security checks.

## Method
- Judge every in-scope item: Pass, Fail, N/A (one-line reason), or Needs manual verification.
- Cite `file:line` for every Fail. For a Pass, name the file or mechanism that satisfies it. Never write a generic "looks fine".
- Report only. Do not edit code.

## Output
1. Create or update `docs/audits/security.md` with one row per Fail or Needs-verification item: `Date | Section | Finding | Severity | Status`. Never delete rows. Mark resolved rows Fixed with the date.
2. Reply with only Fail and Needs-verification items, grouped by severity, one line each with `file:line`. Maximum 30 lines.
3. Last line: `Next:` plus one step. A Critical or High finding: `/rafi:fix-issue <that finding>`. Only Needs-verification items: do those checks by hand. Nothing found: continue what I was doing. If another command called this audit, that command gives the final next step instead. It is only a suggestion. Never run it.
