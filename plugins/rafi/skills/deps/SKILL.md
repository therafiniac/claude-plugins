---
name: deps
description: Review dependency updates (open Dependabot branches, or pnpm outdated) one at a time - changelog and breaking-change scan, install, checks - and give a merge verdict for each.
argument-hint: "[dependabot | outdated | <package name>]"
disable-model-invocation: true
---
Mode: $ARGUMENTS (blank = `dependabot`).

Never edit source code here. Merge only the updates I approve, one at a time. Leave the working tree on the branch I started on when you finish.

1. If there is uncommitted work, say so and stop.
2. Collect the updates:
   - `dependabot`: `git fetch origin`, then list remote branches matching `origin/dependabot/*`. If none, say so and switch to `outdated`.
   - `outdated`: run `pnpm outdated` and list each package with current, wanted, and latest versions.
   - a package name: only that package.
   Show the list, with each update classed as patch, minor, or major, and a GitHub Actions bump as `actions`. Wait for me to pick which to review (default: all).
3. For each picked update, one at a time:
   - Read the package's release notes or changelog for every version between current and target (official repository or docs; web fetch). Note breaking changes, deprecations, security fixes, and new minimum versions (Node, peer dependencies).
   - Search the code for every API the notes mark as changed or removed (`file:line`).
   - Dependabot: `git switch <branch>` (a local tracking branch). Outdated: create a scratch branch `chore/deps-<package>` from an up-to-date `dev` and run `pnpm up <package>@<version>` (major) or `pnpm up <package>` (minor or patch).
   - Run `pnpm install --frozen-lockfile` (Dependabot) or confirm the lockfile changed (outdated), then `pnpm check`, `pnpm build`, and `pnpm test:e2e` if the script exists.
   - Run `pnpm audit --prod` and note whether the update fixes or adds advisories.
   - Verdict: **merge**, **merge after changes** (list the code changes needed, `file:line`), or **hold** (why, and what to wait for). Never edit source code here; a needed change is its own task.
   - Switch back to the starting branch.
4. Report one table: `Package | From → To | Kind | Checks | Breaking items | Verdict`. Then, for any `merge after changes`, the list of changes.
5. Remind me of two rules: merge one update at a time, so a broken one is easy to find; and a major update of a framework, ORM, or auth library gets its own `/rafi:discuss` first.
6. For the **merge** verdicts I approve, one at a time: Dependabot branches target `dev`. In `local` merge mode (`CLAUDE.md`), `git switch dev`, `git pull --ff-only`, `git merge --no-ff <branch>`, `pnpm check`, `git push origin dev`, then delete the remote branch. In `github` mode, tell me to merge the PR with **Create a merge commit** once CI is green. Scratch branches: commit following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` as `chore(deps): bump <package> to <version>`, then `/rafi:merge`.
7. Last line: `Next:` for `merge after changes`, `/rafi:fix-issue upgrade <package>: <first change>`; otherwise continue what I was doing. Delete scratch branches you don't keep. It is only a suggestion. Never run it.
