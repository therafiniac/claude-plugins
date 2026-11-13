---
name: status
description: Show where the project stands (stage, current feature and slice, open findings, pending migrations, uncommitted work) and suggest one next step. Read-only.
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(git status) Bash(git status *) Bash(git branch) Bash(git branch --show-current) Bash(git log *) Bash(git diff *) Bash(git rev-parse *) Bash(git stash list)
---
Read-only. Change no file, run no checks, and do not start the next step.

1. Gather, skipping whatever does not exist:
   - git: current branch, uncommitted and untracked files (`git status --short`), commits on this branch not on its base (`dev` for work branches, `main` for `release/` and `hotfix/`), commits on `dev` not yet on `main` (`git log --oneline main..dev`), the last tag, stashes.
   - Stage: no `docs/brainstorm.md` and no `docs/stack-profile.md` → not started. Only `docs/brainstorm.md` → brainstormed. `docs/stack-profile.md` → bootstrapped.
   - Features: each spec in `docs/prd/` (skip `_template.md`). For each, compare its acceptance criteria with the code and tests to judge Done / In progress / Not started. When unsure, pick the lower status. Name the feature the current branch most likely belongs to, from the branch name and recent commits.
   - The current plan: if this conversation holds an approved plan, which slices are done (code and tests exist) and which remain.
   - Open audit findings: rows in `docs/audits/*.md` whose status is not Fixed, counted by severity. List each Critical and High one.
   - Pending migrations: the "Pending migrations" section of `docs/runbook.md`.
   - Scope: the status lines and progress counts of `docs/scope/client-scope.md`, if present.
   - Launch readiness: placeholders left (`<...>`) in `CLAUDE.md`, `docs/runbook.md`, `SECURITY.md`; whether `.github/workflows/ci.yml` exists.
2. Report in 15 lines or fewer, in this order: stage and branch; uncommitted work; current feature and slice progress; open Critical and High findings; pending migrations; anything blocking launch.
3. Last line: `Next:` plus exactly one step, chosen by the first rule that applies:
   - uncommitted work after a finished slice or fix → `/rafi:commit`
   - an open `release/` or `hotfix/` branch → `/rafi:release finish` or `/rafi:hotfix finish`
   - an open Critical or High finding → `/rafi:fix-issue <finding>`
   - a pending migration phase that is deployed → `/rafi:migration <change>` for the next phase
   - an approved plan with slices left → `/clear`, then `/rafi:slice <next slice>`
   - a feature with a spec but no plan → `/rafi:plan-feature <feature>`
   - a feature in the brainstorm or scope with no spec → `/rafi:spec <feature>`
   - not started → `/rafi:brainstorm <idea>`; brainstormed → `/rafi:bootstrap-project`
   - on a work branch whose work is done → `/rafi:merge`
   - on `main` or `dev` with nothing in progress → `/rafi:branch <type> <name>`
   - `dev` ahead of `main` and its features done → `/rafi:release-check`, then `/rafi:release`
   It is only a suggestion. Never run it.
