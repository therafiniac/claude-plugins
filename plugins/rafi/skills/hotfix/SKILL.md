---
name: hotfix
description: Fix production urgently - branch from main, test-first fix, --no-ff merge into main with a patch tag, then merge back into dev.
argument-hint: "<short name> | finish"
disable-model-invocation: true
---
Arguments: $ARGUMENTS.

Rules: `.claude/rules/git.md`. Merge mode from `CLAUDE.md` (default `local`). Pushing `main` and the tag needs my explicit "yes" in this conversation.

## Start (`<name>`)
1. No uncommitted work. `git fetch origin --tags`. `git switch main`, `git pull --ff-only origin main`, `git switch -c hotfix/<kebab-name>`.
2. Fix it the `/rafi:fix-issue` way (`${CLAUDE_PLUGIN_ROOT}/skills/fix-issue/SKILL.md` steps 1 to 5): failing test first, root cause, minimal change, `pnpm check`. Nothing else goes on this branch.
3. Version: patch bump of the last tag on `main`. `pnpm version <x.y.z> --no-git-tag-version` if `package.json` has a version, and add `## [x.y.z] - <today>` with a `### Fixed` line to `CHANGELOG.md` (below `[Unreleased]`, which stays as it is). Commit the fix and the release prep separately, following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` (`fix(<scope>): ...`, then `chore(release): <x.y.z>`).
4. Run `pnpm build`, and the `rafi:security-auditor` subagent if the cause is security or data. Then continue with **Finish** in the same run unless I said to wait.

## Finish
5. Ask: "Merge hotfix/<name> into main and push main and tag v<x.y.z>?" Wait for yes.
6. `local`: `git switch main`, `git pull --ff-only`, `git merge --no-ff hotfix/<name> -m "Merge branch 'hotfix/<name>' into main (v<x.y.z>)"`, `pnpm check`, `git tag -a v<x.y.z> -m "v<x.y.z>"`, `git push origin main`, `git push origin v<x.y.z>`.
   `github`: PR `hotfix/<name>` → `main` (`gh pr create` if available). Tell me to merge it with **Create a merge commit** once CI is green, then run `/rafi:hotfix finish`, which pulls `main`, confirms the merge commit, tags, and pushes the tag.
7. Back into `dev`: `git switch dev`, `git pull --ff-only`, `git merge --no-ff hotfix/<name>`. On a conflict in `CHANGELOG.md` or the version, keep `dev`'s `[Unreleased]` section and add the hotfix release section below it. `pnpm check`, `git push origin dev` (in `github` mode, open a PR into `dev` instead). Delete the hotfix branch locally and on the remote.
8. Report: the fix, version, tag, and both merges.
9. Last line: `Next:` watch the deploy and health check; then `/rafi:retro` if the bug points at a missing test or rule. It is only a suggestion. Never run it.
