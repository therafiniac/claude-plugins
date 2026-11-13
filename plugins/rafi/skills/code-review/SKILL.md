---
name: code-review
description: Review the current diff or a given path against this project's code standards. Use when asked to review code, a diff, or a branch before commit or PR.
argument-hint: "[diff | path]"
context: fork
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git status)
---
Scope: $ARGUMENTS. Blank or `diff` = current branch vs main. Otherwise a path.

Reference files live in `${CLAUDE_PLUGIN_ROOT}/skills/code-review/references/`, named by section number.

## Baseline
Read the project's `CLAUDE.md` and `.claude/rules/`. Then read only the reference files that match what changed:

| Changed | Sections |
|---|---|
| Any code | 1, 2, 3, 4 |
| Input handling, API, forms | 5 |
| Any logic (confirm tests exist) | 6 |
| Queries, lists, rendering | 7 |
| Logging, config, env vars | 8, 9 |
| UI components | 10 |
| Public API, schema, commits | 11, 12 |
| Migrations, schema changes | 11, plus the stack profile's `## Migration checks` |

## Method
- Check the diff against the baseline. Check that tests cover the cases in section 6.
- Flag risks outside the diff. Do not fix them.
- If the diff touches auth, authorization, uploads, or dependencies, recommend running `/rafi:security-audit` on it.
- Report only. Do not edit code.

## Output
Findings grouped as Blocker / Major / Minor / Nit, one line each with `file:line`. Then one verdict line: approve or changes needed. No log file.
Last line: `Next:` on changes needed, fix the Blocker and Major findings and run `/rafi:code-review` again. On approve, `/rafi:commit`. If another command called this review, that command gives the final next step instead. It is only a suggestion. Never run it.
