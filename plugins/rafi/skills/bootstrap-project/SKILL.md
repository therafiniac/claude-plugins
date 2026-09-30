---
name: bootstrap-project
description: "Bootstrap a new project from the template: pick a framework and database, scaffold, fill placeholders, create the PRD."
argument-hint: <project idea in one line>
disable-model-invocation: true
---
Idea: $ARGUMENTS

1. Ask me everything below in one message and wait for answers:
   - project name, one-line purpose
   - framework: list the files in `${CLAUDE_PLUGIN_ROOT}/stacks/frameworks/`, or give a path to a draft in `docs/stack-drafts/`
   - database: list the files in `${CLAUDE_PLUGIN_ROOT}/stacks/databases/`, or a draft path, or none
   - hosting (default Railway), auth needed, database name, non-goals
   If neither list fits what I want, tell me to run `/rafi:add-stack <name>` first, and stop.
2. Read the chosen framework and database files. Propose the scaffold plan as one merged plan: folders, dependencies with a reason each, scripts, and CI changes (for example a database service container). **Stop and wait for my approval.**
3. After approval, scaffold in the current directory, not a subfolder. Follow both profiles' scaffold contracts. Required in every project:
   - scripts `dev`, `build`, `typecheck`, `lint`, `test`, `check` (check = typecheck + lint + test), a `packageManager` field, `.nvmrc`
   - Prettier, ESLint, Vitest, a validated env module, `.env.example`, a health endpoint, one passing test
   - enforcement: dev dependencies `husky`, `lint-staged`, `@commitlint/cli`, `@commitlint/config-conventional`, and a `"prepare": "husky"` script. The config files (`.husky/`, `commitlint.config.cjs`, `.lintstagedrc.json`) already exist in the repo. Do not overwrite them.
   - if the framework profile defines E2E and Lighthouse: the scripts `test:e2e` and `lighthouse`, plus the config files from the profile
   - if the stack is not Node and pnpm: follow the profile's Adaptation notes and create `.claude/typecheck-cmd` and `.claude/format-cmd`
4. Create `docs/stack-profile.md`: a title line `# Stack profile: <framework> + <database>`, then the full framework file, then the full database file.
5. Fill the placeholders in `CLAUDE.md` (name, purpose, stack, hosting, Architecture section). Keep it under 100 lines. Also replace `README.md`, which is the template's README, with a short project README: name, purpose, stack, hosting, the commands from `CLAUDE.md`, and links to `docs/prd/` and `docs/architecture.md`. Keep no template text.
6. Fill `docs/architecture.md` from what exists. Write `docs/adr/001-stack.md`. Create `docs/prd/<name>.md` from `docs/prd/_template.md` by asking me for users, scope, non-goals, and acceptance criteria. Do not invent them.
7. Run `pnpm install`, then `pnpm run prepare` explicitly (pnpm can skip it on an up-to-date install) and confirm `git config core.hooksPath` prints `.husky/_`. Run `pnpm check` and `pnpm build`. Confirm the commit-msg hook rejects a message like `bad message` and accepts `chore: test`. Show the results and fix failures.
8. Finish with these manual steps. Do not do them yourself:
   - If `command -v gitleaks` fails, install gitleaks. The pre-commit hook needs it.
   - To publish: create an empty private repo on github.com/new with nothing ticked, then run `git remote add origin <url>` and `git push -u origin main`.
   Then list these optional add-ons and install nothing:
   - Superpowers (workflow framework): `/plugin install superpowers@claude-plugins-official`. Try it on one feature and read its files first. If adopted, use its planning commands instead of `/rafi:plan-feature`, and keep `/rafi:slice` for checks and audits.
   - Playwright MCP once UI exists: `claude mcp add playwright -- npx @playwright/mcp@latest`
   - frontend-design skill when building UI: find it under `/plugin` → Discover
