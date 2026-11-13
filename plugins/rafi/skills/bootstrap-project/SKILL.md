---
name: bootstrap-project
description: "Bootstrap a new project from the template: pick a framework, database, and capabilities, scaffold, fill placeholders, create the PRD."
argument-hint: <project idea in one line>
disable-model-invocation: true
---
Idea: $ARGUMENTS

Catalog: `${CLAUDE_PLUGIN_ROOT}/stacks/frameworks/`, `.../databases/`, `.../capabilities/`. Reading a capability file's **summary** means reading everything above its first `## Option:` heading, nothing more.

1. If `docs/brainstorm.md` exists, read it and treat its answers and Stack table as already given. Ask only for what it leaves out. Otherwise ask me everything below in one message and wait for answers:
   - project name, one-line purpose
   - framework: list the files in `stacks/frameworks/`, or give a path to a draft in `docs/stack-drafts/`
   - database: list the files in `stacks/databases/`, or a draft path, or none
   - hosting (default Railway), auth needed, database name, non-goals
   - merge mode: `local` (merge on this machine) or `github` (pull requests); default `local`
   If neither list fits what I want, tell me to run `/rafi:add-stack <name>` first, and stop.
2. Capabilities. Read the summary of every file in `stacks/capabilities/`, and of any `docs/stack-drafts/capability-*.md` in this project. Skip concerns whose "Ask when" does not fit this project. Show one table and wait for my confirmation:
   `Concern | Proposed | Alternatives`. Proposed is the "Default" for the chosen framework, filtered by "Works with" against the chosen framework and database. Alternatives are the other options with status `adopt` or `trial` that also fit. Never propose a `hold` option.
   If the idea needs a concern that is not in the catalog (for example payments or email), list it under the table and say `/rafi:add-capability <concern>` will draft it. Do not invent a profile for it here.
3. Read the chosen framework and database files, and for each capability only the chosen `## Option:` section plus its `## Shared` section if the file has one. For every chosen option, check its install steps and version constraints against the current official docs (web search and fetch), and note any difference from the profile. Propose the scaffold plan as one merged plan: folders, dependencies with a reason each, config files, and scripts. **Stop and wait for my approval.**
4. After approval, scaffold in the current directory, not a subfolder. Prefer the framework's official generator (`pnpm create astro@latest`, `pnpm create next-app@latest`, and so on) when the profile names one, then apply the profiles on top.
   - Run the generator into a temporary subfolder, then move its files up. Never overwrite the template's files (`CLAUDE.md`, `README.md`, `.gitignore`, `.claude/`, `.husky/`, `.github/`, `docs/`, `SECURITY.md`, `CHANGELOG.md`). If the generator created its own `CLAUDE.md` or `AGENTS.md`, fold any useful lines into the template's `CLAUDE.md` and remove the generated copies.
   - If pnpm reports ignored build scripts, list the packages and ask me before approving them with `pnpm approve-builds <package>`.
   Follow every profile's scaffold contract. Required in every project, unless the chosen profile's scaffold contract explicitly overrides an item:
   - scripts `dev`, `build`, `typecheck`, `lint`, `test`, `check` (check = typecheck + lint + test), a `packageManager` field, `.nvmrc`
   - Prettier, ESLint, Vitest, a validated env module, `.env.example`, a health endpoint, one passing test
   - enforcement: dev dependencies `husky`, `lint-staged`, `@commitlint/cli`, `@commitlint/config-conventional`, and a `prepare` script `husky && git config branch.main.mergeOptions --no-ff && git config branch.dev.mergeOptions --no-ff`, so a plain `git merge` into `main` or `dev` never fast-forwards. The config files (`.husky/`, `commitlint.config.cjs`, `.lintstagedrc.json`) already exist in the repo. Do not overwrite them.
   - if the framework profile defines E2E and Lighthouse: the scripts `test:e2e` and `lighthouse`, plus the config files from the profile
   - if the stack is not Node and pnpm: follow the profile's Adaptation notes and create `.claude/typecheck-cmd` and `.claude/format-cmd`
   - CI: `.github/workflows/ci.yml` already exists. Apply every `## CI` section of the chosen profiles to it (service containers, env, setup steps) and keep the actions pinned to commit SHAs. Add `.env.example` values that pass the env module's validation, because CI builds with them
   - `.claude/template-version`: if it is missing, tell me to run `git -C <template clone> rev-parse HEAD > .claude/template-version` (or note it as unknown); `/rafi:sync-template` uses it
5. Create `docs/stack-profile.md` in this order:
   - title line `# Stack profile: <framework> + <database>`
   - `## Stack` table `Concern | Choice` with one row each for framework, database, hosting, auth, and every chosen capability option
   - the full framework file, then the full database file
   - for each chosen capability: a heading `# Capability: <concern> (<option>)` followed by that option's section. After a concern's chosen options, add the file's `## Shared` section once, if it has one. Nothing from the other options
6. Fill the placeholders in `CLAUDE.md` (name, purpose, stack, hosting, Architecture section, and the `Merge mode:` line). Keep it under 100 lines. Also replace `README.md`, which is the template's README, with a short project README: name, purpose, the Stack table, hosting, the commands from `CLAUDE.md`, and links to `docs/prd/` and `docs/architecture.md`. Keep no template text.
7. Fill `docs/architecture.md` from what exists. Fill `docs/runbook.md` from the hosting choice and the profiles: production (`main`) and staging (`dev`) environments, deploy, rollback, health check URL, where logs and errors go, backups (or "none: no database"); leave `<placeholders>` only for facts I must supply, and list them. Ask me for the security contact in `SECURITY.md`. Write `docs/adr/001-stack.md` with each choice and the alternatives considered (use the reasons from `docs/brainstorm.md` if present). Create `docs/prd/<name>.md` from `docs/prd/_template.md`. Take users, scope, non-goals, and acceptance criteria from `docs/brainstorm.md` if present and ask me only for what is missing. Do not invent them.
8. Run `pnpm install`, then `pnpm run prepare` explicitly (pnpm can skip it on an up-to-date install) and confirm `git config core.hooksPath` prints `.husky/_`. Run `pnpm check` and `pnpm build`. Confirm the commit-msg hook rejects `bad message`, `chore: test` (no scope), and a message with a `Co-authored-by:` line, and accepts `chore(test): check hooks` (pipe each message into `pnpm exec commitlint`). Show the results and fix failures.
   Then the first commit and `dev`: check `git config user.name` and `user.email` are mine (ask if they look like a tool), `git add -A`, review that no `.env` or secret is staged, commit on `main` as `chore(scaffold): initial project` with no attribution, then `git switch -c dev`. All further work branches come from `dev`.
9. Finish with these manual steps. Do not do them yourself:
   - If `command -v gitleaks` fails, install gitleaks. The pre-commit hook needs it.
   - To publish: create an empty private repo on github.com/new with nothing ticked, run `git remote add origin <url>`, then `git push -u origin main` and `git push -u origin dev` (or ask me to). Open the repo's Actions tab and confirm CI is green on both.
   - GitHub settings: set `dev` as the default branch (Settings → General), so pull requests target it. In `github` merge mode, under Pull Requests allow only **merge commits** (untick squash and rebase) and tick "Automatically delete head branches".
   - Protect `main` and `dev` (Settings → Rules → Rulesets): require a pull request (in `github` mode) and the `check` and `secret scan` status checks, block force pushes and deletion. Free plans offer this only on public repos; on a private repo without GitHub Pro, the guard hook and the git hooks are the protection.
   - Hosting: production deploys from `main`, staging from `dev`, each with its own env vars, database, and keys. Set the health check path and (with a database) the pre-deploy migrate command from the profile. Set up the uptime monitor and error tracking if the stack includes them.
   Then list these optional add-ons and install nothing:
   - Playwright MCP once UI exists: `claude mcp add playwright -- npx @playwright/mcp@latest`
   - frontend-design skill when building UI: find it under `/plugin` → Discover
10. Last line: `Next:` publish to GitHub as above, then `/rafi:branch feat <first feature from the PRD>`. It is only a suggestion. Never run it.
