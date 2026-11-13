---
name: pr
description: Prepare and open a pull request for the current branch into dev - fills the PR template from the diff, specs, and audit logs, commits a CHANGELOG entry, pushes, and creates the PR with gh when available. Never merges.
argument-hint: "[base branch, default dev]"
disable-model-invocation: true
---
Base: $ARGUMENTS (blank = `dev`; `main` only for `release/` and `hotfix/` branches).

The only file you may edit is `CHANGELOG.md`. Commit it following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md`. Never merge.

1. Read `git log --oneline <base>..HEAD` and `git diff <base>...HEAD --stat`, then the diff itself. If there are no commits on this branch, or there is uncommitted work, say so and stop.
2. Read `.github/pull_request_template.md`, the spec in `docs/prd/` this branch implements (from the branch name and commits; ask if unclear), and `docs/audits/*.md` rows dated since the branch started.
3. Run `pnpm check` and `pnpm build`. If either fails, report the failure and stop: a PR must not go out red.
4. Detect breaking changes from the diff: API routes or action signatures, response shapes, database schema, env variables (`.env.example`), config, removed public functions. For each, one line: what changed and what a caller or deployer must do.
5. Check the definition of done in `CLAUDE.md` against the diff, and mark each template checkbox honestly:
   - tests: do the new or changed tests cover happy path, invalid input, unauthorized, not-found, boundaries?
   - user-facing flow: is there an E2E test?
   - docs: are `docs/architecture.md`, `.env.example`, and `docs/runbook.md` updated where the diff requires it?
   - audits: which audits the diff triggers (Audit triggers table) and whether each ran with findings fixed or logged.
   Leave a box unticked with a short reason rather than ticking it falsely.
6. Add an entry to `CHANGELOG.md` under `## [Unreleased]`, grouped as Added / Changed / Fixed / Removed / Security, in user-facing words, one line per change, and `BREAKING:` first for each breaking change. Skip purely internal changes (refactors, tests, tooling). If `CHANGELOG.md` does not exist, create it with the Keep a Changelog header.
7. Output, in this order:
   - the PR title, Conventional Commits style (`feat(tags): add lesson tags`)
   - the PR body, filled from the template, inside one fenced block ready to paste. Link the spec file. Include a "How to test" list of manual steps.
   - one line: CHANGELOG updated and committed as `docs(changelog): <subject>`
8. Push the branch. If `gh` is installed and logged in, create the PR (`gh pr create --base <base> --title <title> --body-file <file>`) and give its URL; otherwise give the compare URL `https://github.com/<owner>/<repo>/compare/<base>...<branch>`.
9. Last line: `Next:` merge on GitHub with **Create a merge commit** once CI is green, then `git switch <base> && git pull --ff-only` and delete the local branch. If a box is unticked for a missing test or audit, do that first. It is only a suggestion. Never run it.
