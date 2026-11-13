---
name: sync-template
description: Bring an existing project up to date with the latest claude-template - rules, guard rails, commit checks, CI, and doc templates - file by file, keeping the project's own changes.
argument-hint: "[path to a local claude-template checkout]"
disable-model-invocation: true
---
Template source: $ARGUMENTS (blank = clone `git@github.com:therafiniac/claude-template.git`; if SSH fails, try `https://github.com/therafiniac/claude-template.git`).

Never overwrite a file without my approval, and never touch project content (specs, ADRs, audits, scope, code).

1. If there is uncommitted work, say so and stop.
2. Get the latest template into a temporary folder outside the project (`mktemp -d`), with full history. Note its current commit as `NEW`.
3. Read `.claude/template-version` in the project. If present, its first line is the template commit the project started from or last synced to: `BASE`. If missing, there is no base; say so and use a two-way comparison below.
4. Managed files. Compare each that exists in the template at `NEW`:
   - Template-owned, replaced as a whole: `.husky/*`, `commitlint.config.cjs`, `.lintstagedrc.json`, `.claude/rules/*.md`, `.github/workflows/*.yml`, `.github/dependabot.yml`, `.github/pull_request_template.md`, `docs/prd/_template.md`, `docs/adr/_template.md`.
   - Merged: `.claude/settings.json`. Add template `allow` and `deny` entries the project lacks, keep the project's own entries, and keep `deny` entries even if the template dropped them unless I say otherwise. Keep every other key the project has.
   - Created only if missing (project-owned once created): `docs/runbook.md`, `SECURITY.md`, `CHANGELOG.md`, `.github/CODEOWNERS`.
   - Shown, never written: `CLAUDE.md`, `docs/architecture.md`, and `README.md`, which bootstrap filled. Show only template changes to their structure (new sections, new table rows, new workflow lines), as suggested additions I can accept one by one.
   For each template-owned file, classify it:
   - With `BASE`: **unchanged upstream** (template `BASE` = `NEW`) → skip. **Clean update** (project file = template at `BASE`) → replace. **Both changed** → three-way merge (`git merge-file`); show the result and any conflicts.
   - Without `BASE`: **identical** → skip. **Different** → show the diff and ask: take the template's, keep mine, or merge.
5. Show one table: `File | Status | Proposed action`, then the diffs for anything not a clean update. Wait for my approval, per file or all at once.
6. Apply the approved actions. Then:
   - If `.github/workflows/ci.yml` was added or replaced, re-apply the stack's CI additions from the `## CI` sections in `docs/stack-profile.md` (for example a Postgres service). Show the result.
   - Write `NEW` to `.claude/template-version`.
   - Run `pnpm install` if `package.json` or the hooks setup changed, then `pnpm run prepare`, and confirm `git config core.hooksPath` prints `.husky/_`. Run `pnpm check`.
7. Delete the temporary folder. Report the files changed, the suggestions left for `CLAUDE.md` and the other shown files, and the check results. Then commit following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` as `chore(template): sync with claude-template <short NEW>` and give the commit header.
8. Last line: `Next:` `/rafi:merge`, then confirm CI runs on GitHub if the workflow was added for the first time. It is only a suggestion. Never run it.
