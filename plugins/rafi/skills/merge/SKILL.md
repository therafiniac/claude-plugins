---
name: merge
description: Merge the current work branch into dev with --no-ff, locally or through a GitHub pull request, after the branch is updated and checks pass.
argument-hint: "[local | github] (default: Merge mode in CLAUDE.md, else local)"
disable-model-invocation: true
---
Mode: $ARGUMENTS (blank = the `Merge mode:` line in `CLAUDE.md`, else `local`).

Rules: `.claude/rules/git.md`. This merges work branches into `dev` only. `release/` and `hotfix/` branches go through `/rafi:release` and `/rafi:hotfix`.

1. The current branch must be a work branch (`feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/`). On `main` or `dev`, or with uncommitted work, say so and stop.
2. **Update with dev.** `git fetch origin`. If the branch was never pushed, `git rebase origin/dev`; otherwise `git merge --no-ff origin/dev`. Resolve conflicts by keeping both sides' intent; ask me when intent is unclear. Never drop someone else's change.
3. **Gate.** `pnpm check` and `pnpm build`. Then the `rafi:code-reviewer` subagent on `dev...HEAD`, and the audits the diff triggers (Audit triggers table in `CLAUDE.md`). Stop on failure, a Blocker, or a Critical or High finding, and report it.
4. **Changelog.** If the branch has user-facing changes and `CHANGELOG.md` has no entry for them under `## [Unreleased]`, add it (as `/rafi:pr` step 6 does) and commit it on the branch as `docs(changelog): <subject>`.
5. **Merge.**
   - `local`: `git push` the branch (so its final state is on the remote). `git switch dev`, `git pull --ff-only origin dev`, `git merge --no-ff <branch>` with the default message `Merge branch '<branch>' into dev`. Run `pnpm check` on the result. `git push origin dev`. Delete the branch: `git branch -d <branch>` and `git push origin --delete <branch>`.
   - `github`: follow `${CLAUDE_PLUGIN_ROOT}/skills/pr/SKILL.md` with base `dev`, then push the branch. If `gh` is installed and logged in, create the PR with `gh pr create --base dev --title <title> --body-file <file>`; otherwise print the compare URL `https://github.com/<owner>/<repo>/compare/dev...<branch>`. Tell me to merge with **Create a merge commit** once CI is green and delete the branch on GitHub, then run `git switch dev && git pull --ff-only` and `git branch -d <branch>` locally.
6. Report in four lines or fewer: what merged, the merge commit or PR, checks run, branch deleted or not.
7. Last line: `Next:` the next feature (`/rafi:branch feat <name>`), or `/rafi:release` when `dev` holds what should ship. It is only a suggestion. Never run it.
