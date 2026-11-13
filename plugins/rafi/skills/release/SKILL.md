---
name: release
description: Release dev to production - version, changelog, --no-ff merge into main, annotated tag - directly or through an optional release branch, locally or through GitHub.
argument-hint: "[x.y.z] [branch] | finish"
disable-model-invocation: true
---
Arguments: $ARGUMENTS. A version overrides the computed one. `branch` uses a `release/x.y.z` branch. `finish` completes a release branch or a GitHub-merged release.

Rules: `.claude/rules/git.md`. Merge mode from the `Merge mode:` line in `CLAUDE.md` (default `local`). Pushing `main` and tags needs my explicit "yes" in this conversation, every release.

## Start
1. No uncommitted work. `git fetch origin --tags`. Local `dev` equals `origin/dev` (`git pull --ff-only` on `dev` if behind). `origin/dev`'s latest CI run is green: ask me to confirm.
2. Last tag: `git describe --tags --abbrev=0 origin/main` (none → first release, default `0.1.0` or `1.0.0`: ask me). List commits in `<last tag>..origin/dev`. Version: any `BREAKING CHANGE` or `!` → major; else any `feat` → minor; else patch. Show the version and why, and wait for my confirmation or a different number.
3. Gate: if `/rafi:release-check` has not returned **ship** on this `dev` commit in this conversation, run it now. On **hold**, stop with the blockers.
4. Prepare on a branch, never on `dev` or `main`:
   - without `branch`: `git switch -c chore/release-<x.y.z> dev`.
   - with `branch`: `git switch -c release/<x.y.z> dev` and push it. Only release fixes land here from now on.
   On it: `pnpm version <x.y.z> --no-git-tag-version` (if `package.json` has a version), turn `## [Unreleased]` in `CHANGELOG.md` into `## [x.y.z] - <today>` with a fresh empty `## [Unreleased]` above, and add the compare link if the file uses them. Commit as `chore(release): <x.y.z>` following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md`.
   - with `branch`: stop here. Say that release fixes go on this branch (`fix(<scope>): ...` commits, each with checks), and that `/rafi:release finish` completes it.
   - without `branch`: merge `chore/release-<x.y.z>` into `dev` with `--no-ff`, push `dev`, delete the branch, then continue with **Ship** from `dev`.

## Ship (source = `dev`, or `release/<x.y.z>` on `finish`)
5. Show what will reach production: `git log --oneline --no-merges origin/main..<source>` and the changelog section. Ask: "Merge <source> into main and push main and tag v<x.y.z>?" Wait for yes.
6. `local`: `git switch main`, `git pull --ff-only origin main`, `git merge --no-ff <source> -m "Merge branch '<source>' into main (v<x.y.z>)"`, `pnpm check` and `pnpm build` on the result, `git tag -a v<x.y.z> -m "v<x.y.z>"`, `git push origin main`, `git push origin v<x.y.z>`.
   `github`: open a PR `<source>` → `main` (title `chore(release): <x.y.z>`, body = the changelog section; `gh pr create` if available, else the compare URL). Stop and tell me to merge it with **Create a merge commit** once CI is green, then run `/rafi:release finish`. On `finish` after a GitHub merge: `git switch main`, `git pull --ff-only`, confirm the tip is the merge commit, then tag and push the tag as above.
7. Release branch only: merge it back into `dev` (`git switch dev`, `git pull --ff-only`, `git merge --no-ff release/<x.y.z>`, `pnpm check`, `git push origin dev`), then delete it locally and on the remote.
8. If `gh` is available, create a GitHub Release from the tag with the changelog section as notes (`gh release create v<x.y.z> --notes-file <file>`). Otherwise give me the text to paste.
9. Switch back to `dev`. Report: version, tag, merge commit, what was pushed, and that the host now deploys `main`.
10. Last line: `Next:` watch the production deploy and the health check (`docs/runbook.md`); if it breaks, roll back as the runbook says, then `/rafi:hotfix <name>`. It is only a suggestion. Never run it.
