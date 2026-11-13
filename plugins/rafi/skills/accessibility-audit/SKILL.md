---
name: accessibility-audit
description: Run the accessibility audit standard (WCAG 2.2 AA) against this UI. Use only when asked to accessibility-audit, or to check keyboard, screen reader, contrast, forms, or focus behavior.
argument-hint: "[diff | full | path or feature]"
context: fork
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git status) Bash(pnpm test:e2e) Bash(pnpm test:e2e *)
---
Scope: $ARGUMENTS. Blank or `diff` = current branch vs main. `full` = whole UI. Anything else = a path, component, or route.

Reference files live in `${CLAUDE_PLUGIN_ROOT}/skills/accessibility-audit/references/`, named by section number.

## Pick sections
Read `00-overview.md` there. Then read only the files for matching sections:

| Change | Sections |
|---|---|
| New page, route, or layout | 1, 2, 3, 4 |
| Forms, inputs, auth screens | 5, 3 |
| Modals, menus, tabs, custom widgets | 2, 4, 5 |
| Images, video, animation | 1, 6 |
| Color, theme, or typography change | 1 |
| `full`, pre-release, quarterly | all (including 7) |

If `docs/stack-profile.md` exists, also apply its accessibility checks.

## Method
- If the project has Playwright with axe (`pnpm test:e2e`), run it first and include its violations.
- Judge every in-scope item: Pass, Fail, N/A (one-line reason), or Needs manual verification.
- Keyboard-only flow, screen reader behavior, zoom, and content-quality items cannot be proven from code. Mark them Needs manual verification with the exact steps to check.
- Cite `file:line` for every Fail. Report only. Do not edit code.

## Output
1. Create or update `docs/audits/accessibility.md` with one row per Fail or Needs-verification item: `Date | Section | Finding | Severity | Status`. Never delete rows. Mark resolved rows Fixed with the date.
2. Reply with only Fail and Needs-verification items, grouped by severity, one line each. Maximum 30 lines.
3. Last line: `Next:` plus one step. A Critical or High finding: `/rafi:fix-issue <that finding>`. Only Needs-verification items: do those checks by hand. Nothing found: continue what I was doing. If another command called this audit, that command gives the final next step instead. It is only a suggestion. Never run it.
