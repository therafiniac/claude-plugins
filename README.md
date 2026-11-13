# claude-plugins

A private Claude Code plugin marketplace, `rafi-tools`, holding one plugin, **`rafi`**. It adds `/rafi:` commands that take a project from an idea to production: choose the stack, scaffold, specify, plan, build in tested slices, review and audit, branch, commit, merge, release, and maintain.

- **This README** is the reference: every command, the catalog, the audits, the hooks, and how to change the plugin.
- The **[claude-template README](https://github.com/therafiniac/claude-template)** is the user guide: setup, a first project, the daily workflow.

## Contents
1. [Install and update](#1-install-and-update)
2. [Commands](#2-commands)
3. [Git workflow commands](#3-git-workflow-commands)
4. [Capabilities catalog](#4-capabilities-catalog)
5. [Stack profiles](#5-stack-profiles)
6. [Audits](#6-audits)
7. [Agents and hooks](#7-agents-and-hooks)
8. [Changing the plugin](#8-changing-the-plugin)
9. [Repo layout](#9-repo-layout)
10. [Design decisions](#10-design-decisions)
11. [Troubleshooting](#11-troubleshooting)
12. [Known caveats](#12-known-caveats)

---

## 1. Install and update

The repo is private: git on the machine must be authenticated to GitHub (SSH key or token).

| Task | Command |
|---|---|
| Install (once per machine) | `claude plugin marketplace add therafiniac/claude-plugins` then `claude plugin install rafi@rafi-tools` |
| Check | `claude plugin list` (rafi enabled), `claude plugin details rafi` (contents and context cost), or type `/rafi:` |
| Update | `claude plugin marketplace update rafi-tools` then `claude plugin update rafi@rafi-tools` |
| Enable for one project only | `claude plugin install rafi@rafi-tools --scope project` (template projects already have it in `.claude/settings.json`) |
| Pause / remove | `claude plugin disable rafi@rafi-tools` / `claude plugin uninstall rafi@rafi-tools` |

Restart Claude Code after installing or updating.

A plugin cannot ship a project's `CLAUDE.md`, rules, permissions, or git hooks. Those come from the template, copied into each project.

## 2. Commands

Workflow commands are manual-only (`disable-model-invocation`): Claude never starts them itself, and they cost no context until typed. Audits and code review can also be started by Claude when a change needs them.

Every command ends with one `Next:` line suggesting the step that fits the outcome. Claude never runs it. When one command calls another, only the outer command's `Next:` counts.

### Overview

| Stage | Command | Writes |
|---|---|---|
| Idea | `/rafi:brainstorm <idea>` | `docs/brainstorm.md` |
| Idea (existing project) | `/rafi:discuss <topic>` | `docs/discussions/<date>-<topic>.md` |
| Setup | `/rafi:bootstrap-project <idea>` | scaffold, `docs/stack-profile.md`, filled docs, first commit, `dev` |
| Catalog | `/rafi:add-stack <name>` | `docs/stack-drafts/<kind>-<name>.md` |
| Catalog | `/rafi:add-capability <concern> [option]` | code, stack profile, ADR (or a draft) |
| Feature | `/rafi:spec <feature>` | `docs/prd/<feature>.md` |
| Feature | `/rafi:plan-feature <name>` | nothing (plan in chat) |
| Build | `/rafi:slice <name>` | code, tests, docs, a commit |
| Build | `/rafi:fix-issue <description>` | failing test, fix, a commit |
| Build | `/rafi:migration <change>` | migration files, backfill script, tests, a commit |
| Git | `/rafi:branch`, `/rafi:commit`, `/rafi:merge`, `/rafi:pr` | see section 3 |
| Release | `/rafi:release-check` | audit logs |
| Release | `/rafi:release`, `/rafi:hotfix` | see section 3 |
| Maintain | `/rafi:status` | nothing |
| Maintain | `/rafi:deps [mode]` | merges approved updates |
| Maintain | `/rafi:sync-template [path]` | template files, a commit |
| Maintain | `/rafi:retro` | rules, gotchas, a commit |
| Client | `/rafi:scope [agreed]` | `docs/scope/client-scope.md`, `docs/scope/work-scope.md` |
| Check | `/rafi:code-review [scope]` | nothing |
| Check | `/rafi:security-audit`, `/rafi:seo-audit`, `/rafi:performance-audit`, `/rafi:accessibility-audit` `[diff\|full\|path]` | `docs/audits/<name>.md` |

### `/rafi:brainstorm <idea>`
New projects only; in a bootstrapped project it points to `/rafi:discuss`.
- Asks (up to four questions per round): users and problem, 3–5 core flows, non-goals, who edits content, data (accounts, payments, personal data), constraints (budget, hosting, deadline, traffic, languages), what exists.
- Proposes 2–3 approaches with effort, running cost, trade-offs, and a recommendation.
- Builds a stack from the catalog: `Concern | Proposed | Alternatives | Why`. Never proposes `hold`. Lists concerns the catalog lacks.
- Writes `docs/brainstorm.md` (under 80 lines). No code, no install.

### `/rafi:discuss <topic>`
Existing projects only. Reads the stack profile, architecture, specs, ADRs, and earlier discussions. Asks about the problem, users, constraints. Proposes 2–3 approaches that fit the current stack, checks the catalog for new needs, and writes `docs/discussions/<date>-<topic>.md`. `Next:` is `/rafi:spec`, `/rafi:add-capability`, `/rafi:add-stack`, or nothing.

### `/rafi:bootstrap-project <idea>`
Run in a fresh copy of the template.
1. Reads `docs/brainstorm.md` if present; asks only for what is missing: name, purpose, framework, database, hosting (default Railway), auth, non-goals, **merge mode** (`local` or `github`).
2. Capability table (`Concern | Proposed | Alternatives`) for confirmation.
3. Verifies each chosen option against current official docs, then proposes one scaffold plan. **Waits for approval.**
4. Scaffolds with the framework's official generator, then applies the profiles. Never overwrites `CLAUDE.md`, `README.md`, `.gitignore`, `.claude/`, `.husky/`, `.github/`, `docs/`, `SECURITY.md`, `CHANGELOG.md`. Asks before approving package build scripts.
5. Required in every project: scripts `dev`, `build`, `typecheck`, `lint`, `test`, `check`; `packageManager`; `.nvmrc`; Prettier, ESLint, Vitest; a validated env module; `.env.example` whose values pass validation (CI builds with them); a health endpoint; one passing test; husky, lint-staged, commitlint; `prepare` = `husky && git config branch.main.mergeOptions --no-ff && git config branch.dev.mergeOptions --no-ff`. E2E and Lighthouse if the framework profile defines them. The profiles' `## CI` sections are applied to `ci.yml`.
6. Writes `docs/stack-profile.md`, fills `CLAUDE.md` (including `Merge mode:`), replaces `README.md` with a project README, fills `docs/architecture.md`, `docs/runbook.md` (production and staging), `SECURITY.md`, writes `docs/adr/001-stack.md` and `docs/prd/<name>.md`.
7. Installs, enables hooks, runs `pnpm check` and `pnpm build`, and tests commitlint (rejects no-scope and attribution messages).
8. Commits on `main` as `chore(scaffold): initial project`, then creates `dev`.
9. Lists manual steps: create the GitHub repo and push `main` and `dev`, set `dev` as default branch, merge-commit-only (github mode), rulesets, hosting for production and staging.

### `/rafi:add-stack <name>`
Interviews you (kind, language, versions, tooling, deploy, paired databases), reads the official docs for those versions, drafts a profile from `stacks/_template.md` with sources and, for non-Node stacks, full adaptation notes. Saves `docs/stack-drafts/<kind>-<name>.md` after approval.

### `/rafi:add-capability <concern> [option]`
- **Add mode** (concern in the catalog, project bootstrapped): proposes the default for your framework (filtered by "works with"), verifies current docs, shows a plan, **waits**, implements, runs checks, updates `docs/stack-profile.md`, writes an ADR, commits.
- **Draft mode** (concern or option not in the catalog): interviews you, researches official docs, drafts the entry in catalog format, saves `docs/stack-drafts/capability-<concern>.md`.

### `/rafi:spec <feature>`
Asks first: **A)** Claude asks and writes, or **B)** you fill the file and Claude reviews.
- A: up to four plain questions per round (problem, users, scope, non-goals, steps and failures, then performance, personal data, rollout, measurement). Drafts `Given / When / Then` criteria for the normal case, invalid input, not found, no permission, limits. Criteria you didn't state are marked **(proposed)** until you confirm.
- B: creates the file with hints, then reviews: vague criteria, missing failure cases, scope without criteria, empty non-functional sections.
- Fills every section or writes "none". Commits `docs(prd): add <feature> spec` (creating `feat/<feature>` from `dev` if you are on `dev`).

### `/rafi:plan-feature <name>`
Requires a spec. Proposes vertical slices in dependency order (schema → service → route → tests → UI), files per slice, data model changes classed additive or breaking (breaking changes become a `/rafi:migration` slice), API contract, test cases, how non-functional requirements are met, risks, and the audits each slice triggers. Writes nothing. **Waits for approval.**

### `/rafi:slice <name>`
Requires an approved plan.
1. Restates the slice in three lines; builds only that. Schema changes follow the migration rules; for a breaking change only the expand phase is built and the rest goes to `docs/runbook.md` → Pending migrations.
2. Tests per `.claude/rules/testing.md` (test-writer agent for large suites).
3. `pnpm check` until green.
4. code-reviewer agent; fixes Blocker and Major.
5. Matching audits; fixes Critical and High; logs the rest.
6. E2E test for a new user-facing flow. Updates architecture, `.env.example`, runbook.
7. Commits via `/rafi:commit` rules and pushes the work branch. `Next:` next slice, or `/rafi:merge`.

### `/rafi:fix-issue <description>`
Failing test that reproduces the bug (stops if it can't) → one-sentence root cause → minimal fix → `pnpm check` → security-auditor if the cause is security or data → commit `fix(scope): ...`. On `main` or `dev` it first creates `fix/<name>` from `dev`. Production emergencies: `/rafi:hotfix`.

### `/rafi:migration <change>`
Stops at once if there is no stack profile or no database.
- Classifies: **additive** (one step), **breaking** (expand → dual-write → backfill → switch reads → contract, each deployed separately), **data only** (backfill).
- Checks the database's `## Migration checks` (locks, rewrites, index builds, constraint validation, volume).
- Proposes phases, deploy order, rollback per phase, backup before destructive steps, tests. **Waits.**
- Builds the current phase: migration files via the profile's tool, a batched, idempotent, resumable backfill script with `--dry-run`, tests (empty database, existing data preserved, backfill idempotent). Updates the data model, adds an ADR for breaking changes, records remaining phases in the runbook. Commits.

### `/rafi:release-check`
Run on `dev` or a `release/` branch. `pnpm check`, `pnpm build`, `pnpm audit --prod`, E2E and Lighthouse if present; all four audits with `full`; then operational readiness: CI green (asks you), staging tried, runbook and `SECURITY.md` free of placeholders, no blocking pending migration, observability and rate limits wired (missing = High), `.env.example` complete, changelog entries present. Verdict **ship** or **hold** with blockers. `Next:` on ship is `/rafi:release`.

### `/rafi:status`
Read-only. Branch, uncommitted work, commits ahead of base, `dev` ahead of `main`, last tag, stage, per-spec progress (from code and tests; picks the lower status when unsure), plan progress, open Critical and High findings, pending migrations, scope progress, launch blockers. 15 lines, one `Next:` by fixed priority: commit → finish open release or hotfix → fix serious findings → next migration phase → next slice → plan → spec → merge → new branch → release.

### `/rafi:deps [dependabot | outdated | <package>]`
Lists updates (Dependabot branches, or `pnpm outdated`) classed patch, minor, major, actions; you pick. Per update: release notes for every version in between, code search for changed APIs, checks, build, E2E, `pnpm audit --prod`, verdict **merge**, **merge after changes** (with `file:line`), or **hold**. Merges approved ones into `dev` one at a time (`--no-ff` locally, or tells you to merge the PR in github mode). Never edits source code. Major framework, ORM, or auth upgrades go to `/rafi:discuss` first.

### `/rafi:sync-template [path]`
Brings a project up to date with the latest template, using `.claude/template-version` as the merge base.

| Files | Treatment |
|---|---|
| `.husky/*`, `commitlint.config.cjs`, `.lintstagedrc.json`, `.claude/rules/*`, `.github/workflows/*`, `.github/dependabot.yml`, PR, PRD, and ADR templates | Template-owned. Untouched in the project → replaced. Changed on both sides → three-way merge |
| `.claude/settings.json` | Merged; project entries kept |
| `docs/runbook.md`, `SECURITY.md`, `CHANGELOG.md`, `CODEOWNERS` | Created only if missing |
| `CLAUDE.md`, `docs/architecture.md`, `README.md` | Never written; structural additions shown as suggestions |

Shows everything for approval, re-applies the stack's CI additions, updates `.claude/template-version`, re-enables hooks, runs checks, commits.

### `/rafi:retro`
Collects corrections, repeated instructions, failed commands, recurring findings, and time sinks. Proposes up to seven items, each classed: gotcha (`CLAUDE.md`), rule (`.claude/rules/`), enforcement (exact hook, lint, or CI config), plugin improvement (a list for this repo), or ignore. Applies approved project items and commits them. Never edits the plugin.

### `/rafi:scope [agreed]`
Writes `docs/scope/client-scope.md` (plain language, under 50 lines) and `docs/scope/work-scope.md` (full breakdown for estimating). Progress per deliverable: Done (code and test), In progress, Not started. `agreed` freezes a baseline; later additions go under "Changes since agreement". Never writes prices or hours. Commits.

### `/rafi:code-review [diff | path]`
Reviews against the 12-section code standard, choosing sections by what changed (migrations also use the stack profile's `## Migration checks`). Findings Blocker / Major / Minor / Nit with `file:line`, verdict approve or changes needed. Read-only.

## 3. Git workflow commands

The rules live in each project's `.claude/rules/git.md` (from the template). Summary:

```
main ──●────────────────────●──────────────●───   production, tag vX.Y.Z on every merge
        \                  / \            /
dev      ●──●─────●──────●───●──────●────●─────   integration, deploys to staging
             \   / \    /            \  /
feat/a        ●─●   \  /    hotfix/x  ●●  (from main, back into dev)
fix/b                ●●
```

| Branch | From | Into | Merge |
|---|---|---|---|
| `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/` | `dev` | `dev` | `--no-ff` |
| `release/x.y.z` (optional) | `dev` | `main`, then `dev` | `--no-ff` |
| `hotfix/<name>` | `main` | `main` (patch tag), then `dev` | `--no-ff` |
| `dev` | `main` (once) | `main` at release | `--no-ff` |

Commits: `type(scope): subject`, scope required, header at most 72 characters, no attribution lines. Merge mode per project in `CLAUDE.md`: `local` (Claude merges and pushes) or `github` (Claude opens the PR; you merge with **Create a merge commit**).

| Command | Does |
|---|---|
| `/rafi:branch <type> <name>` | Fetches, fast-forwards `dev`, creates `<type>/<kebab-name>`. Carries or stops on uncommitted work. Refuses `hotfix` and `release` (own commands) |
| `/rafi:commit [hint]` | Moves off `main`/`dev` to a work branch if needed; stages only the change's files by path (never `.env*`, `secrets/`, build output); splits unrelated changes; `pnpm check`; writes `type(scope): subject` with optional body and `BREAKING CHANGE:` / `Refs:` footers; no attribution; never `--no-verify`; checks the git identity is the owner's; pushes the work branch. Other commands follow this file when they commit |
| `/rafi:merge [local\|github]` | Updates the branch with `dev` (rebase if never pushed, else merge), runs check, build, code review, triggered audits, adds a changelog entry if missing. `local`: `git merge --no-ff` into `dev`, check, push `dev`, delete the branch. `github`: `/rafi:pr` into `dev` |
| `/rafi:pr [base]` | Base `dev` by default. Runs check and build, fills the PR template honestly from the diff, spec, and audits, lists breaking changes, commits the changelog entry, pushes, creates the PR with `gh` if available (else a compare URL). Never merges |
| `/rafi:release [x.y.z] [branch] \| finish` | Version from commits since the last tag (breaking → major, feat → minor, else patch), confirmed by you. Requires release-check **ship**. Bumps version and changelog on `chore/release-x.y.z` (merged into `dev`) or on `release/x.y.z`. Asks your explicit yes, then `dev` (or the release branch) → `main` `--no-ff`, check, build, annotated tag, push `main` and tag, merge the release branch back into `dev`, GitHub Release via `gh` if available. In github mode it opens the PR and `finish` tags after you merge |
| `/rafi:hotfix <name> \| finish` | Branch from `main`, test-first fix, patch version and changelog, your explicit yes, `--no-ff` into `main`, tag, push, then `--no-ff` back into `dev` (keeping `dev`'s Unreleased section on conflict) |

Pushing `main` and tags happens only in `/rafi:release` and `/rafi:hotfix`, after an explicit yes in the conversation.

## 4. Capabilities catalog

A curated set of vetted options per concern, each with a status:

| Status | Meaning | Proposed? |
|---|---|---|
| `adopt` | Safe default | Yes |
| `trial` | Good when its "pick when" fits; verify more carefully | As an alternative |
| `hold` | Do not start new projects with it; listed only to explain why | Never |

| Concern | Options | Default |
|---|---|---|
| styling | tailwind, tailwind-typography (add-on), native-css, runtime-css-in-js (hold) | tailwind; typography for Markdown text |
| ui-components | none, shadcn, react-aria-components (trial), daisyui (trial), runtime-css-in-js-kits (hold) | React: shadcn. Astro: none |
| icons | lucide, simple-icons (brands), iconify-astro-icon (trial), heroicons (trial), phosphor (trial), icon-fonts (hold) | lucide (+ simple-icons) |
| fonts | astro-fonts, next-font, fontsource, system-stack, google-fonts-cdn (hold) | astro: astro-fonts. nextjs: next-font. Vite: fontsource |
| cms | none, keystatic, sanity, decap (trial), payload (trial) | none; keystatic (git-based); sanity (structured) |
| search | pagefind, postgres-fts, meilisearch (trial), algolia (trial) | static: pagefind. Postgres apps: postgres-fts |
| forms | server-endpoint, turnstile (add-on), web3forms, formspree (trial) | server: server-endpoint + turnstile. Static: web3forms |
| auth | better-auth, clerk (trial), authjs (hold), lucia (hold) | better-auth |
| email | resend, postmark, aws-ses (trial), smtp (trial) | resend |
| analytics | umami, plausible, cloudflare-web-analytics, posthog (trial), google-analytics (hold) | content: umami. Funnels: posthog |
| payments | stripe, razorpay, paddle (trial), stripe-managed-payments (trial), lemon-squeezy (hold) | India: razorpay. Elsewhere: stripe |
| structured-data | hand-written-jsonld, astro-seo-schema (trial), astrolib-seo (hold) | hand-written-jsonld |
| observability | sentry, pino, uptime-monitor, opentelemetry (trial), console-only (hold) | server: sentry + pino + uptime-monitor. Static: sentry + uptime-monitor |
| rate-limiting | express-rate-limit, rate-limiter-flexible, upstash-ratelimit, cloudflare-rules (trial), hand-rolled-map (hold) | Express: express-rate-limit. Long-running host: rate-limiter-flexible. Serverless: upstash-ratelimit |
| file-storage | cloudflare-r2, aws-s3, uploadthing (trial), local-disk (hold) | cloudflare-r2 |
| background-jobs | pg-boss, bullmq, inngest (trial), trigger-dev (trial), fire-and-forget (hold) | Postgres: pg-boss. Redis or Mongo: bullmq. Serverless: inngest |

### File format (`plugins/rafi/stacks/capabilities/<concern>.md`)
```
# Capability: <Concern>
Kind: capability
Ask when: <condition under which brainstorm/bootstrap raise it>
Default: <framework → option>
Verified: <month year>

## Options                        <- summary: everything above the first "## Option:"
| Option | Status | Pick when | Works with | Cost |

## Option: <name>                 <- copied into the project only if chosen
Setup / Conventions / Security, Performance, Accessibility, SEO checks / Sources

## Shared                         <- copied with whichever option is chosen
```
Rules: 2–5 options; `hold` options appear only in the table; every option section stands alone (never "same as X"); "Works with" holds profile names, `any`, and short qualifiers; every rule is specific and checkable; audit checks cite the standard's section (`§n`). `tools/check-plugin.sh` enforces the structure.

### How a choice reaches a project
Brainstorm or bootstrap reads only the summaries → you confirm → the chosen option is verified against current docs → its section plus `## Shared` is copied into `docs/stack-profile.md` → every audit applies its checks from then on.

## 5. Stack profiles

| Kind | Folder | Available |
|---|---|---|
| Framework | `plugins/rafi/stacks/frameworks/` | `astro`, `nextjs`, `react-spa`, `react-express`, `wordpress` |
| Database | `plugins/rafi/stacks/databases/` | `postgres`, `mongodb` |

A project has one framework, zero or one database, and any number of capabilities.

| Framework | For |
|---|---|
| `astro` | Content, docs, marketing, portfolio sites; static by default |
| `nextjs` | Public sites with server features (logins, dashboards, SEO pages) |
| `react-spa` | A React frontend for an existing API |
| `react-express` | React plus an Express API in one repo, apps behind a login |
| `wordpress` | Client or content sites with custom themes and plugins |

Profile sections (`stacks/_template.md`): Stack, Scaffold contract, Conventions, Security / SEO / Performance / Accessibility checks, **Migration checks** (databases: locking operations and safe alternatives, used by `/rafi:migration`, `/rafi:slice`, `/rafi:code-review`), **CI** (what `ci.yml` needs, such as a Postgres service; applied by bootstrap and sync-template), Adaptation notes (non-Node stacks), Sources.

Non-Node stacks: the profile's adaptation notes list the template files to change, plus two one-line files the hooks read: `.claude/typecheck-cmd` (for example `mypy .`) and `.claude/format-cmd` (for example `ruff format`; the file path is appended).

## 6. Audits

| Standard | References | Sections |
|---|---|---|
| Security (OWASP-aligned) | `skills/security-audit/references/` | 01 authentication … 15 third-party integrations |
| SEO | `skills/seo-audit/references/` | 01–10 |
| Performance | `skills/performance-audit/references/` | 01–08 |
| Accessibility (WCAG 2.2 AA) | `skills/accessibility-audit/references/` | 01–07 |
| Code review | `skills/code-review/references/` | 01–12 |

Each folder has `00-overview.md` (severity scale, statuses) and an appendix of standards referenced.

**How one runs:** in a forked context → reads its `SKILL.md` mapping table and only the matching sections → adds the stack profile's checks → measures with read-only commands (security: `pnpm audit --prod`, `pnpm outdated`; performance: `pnpm build`, `pnpm lighthouse`; SEO: built output, Lighthouse; accessibility: `pnpm test:e2e` with axe) → judges each item Pass, Fail (`file:line`), N/A (reason), or Needs manual verification → appends to `docs/audits/<name>.md` (`Date | Section | Finding | Severity | Status`; rows never deleted, fixed ones marked Fixed with a date) → replies with Fails and verifications only, at most 30 lines. Audits never edit code.

| Scope | Meaning |
|---|---|
| `diff` (default) | Current branch against its base |
| `full` | Whole project |
| a path or feature | That part only |

Severity: security and accessibility use Critical / High / Medium / Low (defined in each `00-overview.md`); code review uses Blocker / Major / Minor / Nit. Slices fix Critical, High, Blocker, and Major before reporting.

Changing a standard: edit the section file; if you add or renumber sections, update the mapping table in that audit's `SKILL.md`.

## 7. Agents and hooks

| Agent | Job | Limits |
|---|---|---|
| `rafi:code-reviewer` | Reviews a diff against the code standard | Read-only |
| `rafi:security-auditor` | Security audit of a change | Writes only `docs/audits/security.md`; may run `pnpm audit`, `pnpm outdated`, `pnpm why` |
| `rafi:test-writer` | Writes tests for the standard cases | Test files only; reports bugs instead of fixing; never weakens assertions |

| Hook | Script | Effect |
|---|---|---|
| PreToolUse (Bash, Read, Edit, Write) | `scripts/guard.sh` | Blocks, with a reason: reading `.env*` (not `.env.example`) or `secrets/`, directly or via `cat`/`grep`/…; `rm` with recursive + force in any spelling; `--no-verify`, `commit -n`, `HUSKY=0`; editing lockfiles; direct commits on `main`/`dev` (the repository's first commit excepted); merges into them without `--no-ff` (`--ff-only origin/<same>` allowed for syncing); `git pull` on them without `--ff-only`; rebasing them; pushing them unless the tip is a merge commit (or the root commit); `--force` anywhere and `--force-with-lease` on `main`/`dev`; attribution in commit, merge, or tag messages. Tracks `git switch` within one command line |
| PostToolUse (Edit, Write) | `scripts/format-file.sh` | Formats the edited file: `.claude/format-cmd`, else Prettier in pnpm projects. Never blocks |
| Stop | `scripts/verify-on-stop.sh` | Runs `.claude/typecheck-cmd`, else `pnpm typecheck`; on failure Claude must fix before finishing (one retry, no loops). Skipped when commit, status, diff, and untracked files are unchanged since the last pass |

All hooks need `jq`. Only you can disable the guard for a session: `RAFI_GUARD=off claude`. Its rules are tested by `tools/test-guard.sh`.

## 8. Changing the plugin

```bash
git clone git@github.com:therafiniac/claude-plugins.git && cd claude-plugins
```

| Change | File |
|---|---|
| Command behavior | `plugins/rafi/skills/<name>/SKILL.md` |
| Library option | `plugins/rafi/stacks/capabilities/<concern>.md` |
| Framework or database | `plugins/rafi/stacks/frameworks/<name>.md`, `.../databases/<name>.md` |
| Audit standard | `plugins/rafi/skills/<audit>/references/NN-*.md` |
| Hook | `plugins/rafi/scripts/*.sh`, `plugins/rafi/hooks/hooks.json` |
| Agent | `plugins/rafi/agents/<name>.md` |

1. **Branch** from `main` (`feat/<name>`), make the change.
2. **Version**: raise `version` in both `plugins/rafi/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, to the same number. Without it no machine receives the change. Patch: fixes. Minor: new option, capability, profile, command, or section. Major: changed behavior of existing commands or hooks.
3. **Check**:
   ```bash
   claude plugin validate . && claude plugin validate ./plugins/rafi
   tools/check-plugin.sh     # manifests, versions, skills, agents, catalog structure, scripts
   tools/test-guard.sh       # guard rules
   ```
   CI (`.github/workflows/validate.yml`) runs the same on every PR and push to `main`, and on PRs fails if `plugins/rafi` changed without a version bump.
4. **Evals**: `claude plugin eval plugins/rafi --runs 3 --no-publish` (real sessions on your account; a few cents per run). Cases live in `plugins/rafi/evals/<case>/` (`prompt.md` + `graders/criteria.md`); add one with `claude plugin eval init --bare <name>` from `plugins/rafi`. Judge by pass rate across runs.
5. **Try locally**: `claude plugin marketplace add /full/path/to/claude-plugins`, then run the changed command in a throwaway template copy.
6. **Commit, merge, push**: `type(scope): subject`, `--no-ff` into `main`.
7. **Update machines**: `claude plugin marketplace update rafi-tools && claude plugin update rafi@rafi-tools`, restart.

Roll back: `git revert -m 1 <merge commit>`, raise the version again, publish.

## 9. Repo layout

```
claude-plugins/
├── .claude-plugin/marketplace.json     marketplace and plugin version
├── .github/                            validate.yml, dependabot.yml (actions)
├── tools/                              check-plugin.sh, test-guard.sh
└── plugins/rafi/
    ├── .claude-plugin/plugin.json      name and version
    ├── skills/                         one folder per command (SKILL.md)
    │   ├── brainstorm discuss bootstrap-project add-stack add-capability
    │   ├── spec plan-feature slice fix-issue migration
    │   ├── branch commit merge pr release hotfix release-check
    │   ├── status deps sync-template retro scope
    │   └── code-review security-audit seo-audit performance-audit accessibility-audit (with references/)
    ├── agents/                         code-reviewer, security-auditor, test-writer
    ├── hooks/hooks.json                PreToolUse, PostToolUse, Stop
    ├── scripts/                        guard.sh, format-file.sh, verify-on-stop.sh
    ├── evals/                          eval cases (results/ is git-ignored)
    └── stacks/
        ├── _template.md, _capability-template.md
        ├── frameworks/                 astro nextjs react-spa react-express wordpress
        ├── databases/                  postgres mongodb
        └── capabilities/               16 concerns (section 4)
```

## 10. Design decisions

- **Private plugin**: hooks run shell commands on every tool call, so they must be code you wrote; the standards encode your choices; you control versions and rollback.
- **Generic core, swappable stack layer**: standards name no framework; everything technology-specific is in `stacks/`. Frameworks, databases, and capabilities are separate files so any combination works.
- **Curated catalog, verified at use time**: a few vetted options per concern; bootstrap and add-capability re-check current docs before installing.
- **Standards split by section**: audits load only what a change needs.
- **Audits report, slices fix**: changes happen where tests and review surround them.
- **Suggest, never chain**: each command ends with one `Next:`; you decide.
- **Claude commits, you own production**: Claude commits and pushes work branches and `dev`; `main` and tags move only in release and hotfix, after an explicit yes. Commits carry no attribution and use your git identity.
- **`--no-ff` everywhere into `main` and `dev`**: every feature, release, and hotfix is one revertable merge commit.
- **Hooks for "never"**: what must never happen is blocked by the guard and the project's git hooks, not only written down.
- **Migrations expand → contract**: every phase is safe while the previous version still runs.
- **CI without secrets or paid features**; branch rulesets are recommended but need GitHub Pro on private repos, so local hooks enforce the same rules.

## 11. Troubleshooting

| Symptom | Fix |
|---|---|
| `/rafi:` shows nothing | `claude plugin list`; reinstall (section 1); restart. Check git can reach the private repo |
| A change doesn't arrive | Version not raised in both manifests, update commands not run, or Claude Code not restarted |
| `claude plugin validate` fails | Invalid JSON, a missing file, or `name` mismatch between `plugin.json` and the marketplace entry |
| `validate` CI: "version is still x.y.z" | Raise the version (section 8, step 2) |
| `check-plugin.sh`: option section missing | Every non-`hold` row in `## Options` needs a `## Option: <name>` section, and vice versa |
| An audit reads the wrong sections | Fix the mapping table in that audit's `SKILL.md` |
| Bootstrap never offers an option | Its status is `hold`, or "Works with" excludes your framework |
| "Blocked by rafi guard: …" | Do what the message says. If the rule is wrong for a case, fix `scripts/guard.sh`, add a case to `tools/test-guard.sh`, raise the version. One-off: run the command yourself |
| "pushing dev whose tip is not a merge commit" | Something was committed or fast-forwarded onto `dev`. Move that commit to a work branch and merge it with `--no-ff` |
| Type check keeps stopping Claude | Fix the reported error, or point `.claude/typecheck-cmd` at a passing command |
| `jq: command not found` | Install `jq` |

## 12. Known caveats

- The guard parses shell commands with patterns, not a shell parser. It stops mistakes and common spellings, not a determined workaround such as a script that does the same thing.
- Merge-mode detection reads the `Merge mode:` line in `CLAUDE.md`; projects without it default to `local`.
- The observability, rate-limiting, file-storage, and background-jobs capabilities were drafted in November 2026 without a line-by-line vendor check. Bootstrap and add-capability verify the chosen option before installing.
- Library facts (free tiers, versions) change; the catalog avoids hard numbers. Re-check prices before committing to a paid service.
- As of September 2026, `astro check` refuses TypeScript 7, so the Astro profile pins `typescript@^6`.
- Eval graders are model-judged; use several runs and read the pass rate.
- The hooks need `jq`; their default paths need `pnpm`.
