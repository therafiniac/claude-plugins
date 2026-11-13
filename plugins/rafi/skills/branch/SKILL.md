---
name: branch
description: Start a work branch from an up-to-date dev, named type/kebab-name.
argument-hint: <type> <name>, e.g. "feat lesson tags"
disable-model-invocation: true
---
Branch: $ARGUMENTS

Rules: `.claude/rules/git.md` if the project has it. Without it, the same rules apply with base `dev` if it exists, else `main`.

1. Type must be one of `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`. For `hotfix` say to use `/rafi:hotfix`, for `release` `/rafi:release`, and stop. Name becomes lowercase kebab-case, at most 40 characters.
2. If there is uncommitted work, show `git status --short` and ask whether to carry it onto the new branch, or stop so I can commit or stash it. Never discard it.
3. `git fetch origin`. If `dev` does not exist locally or on the remote, say so and stop: `/rafi:bootstrap-project` creates it, or run `git switch -c dev main && git push -u origin dev` once.
4. `git switch dev`, then `git pull --ff-only origin dev`. If the pull cannot fast-forward, local `dev` has commits the remote lacks: show them and stop.
5. `git switch -c <type>/<name>`. Do not push yet; `/rafi:commit` pushes on the first commit.
6. Report the branch name and the commit it starts from, in two lines.
7. Last line: `Next:` for a feature without a spec, `/rafi:spec <name>`; with a spec, `/rafi:plan-feature <name>`; for a fix, `/rafi:fix-issue <description>`. It is only a suggestion. Never run it.
