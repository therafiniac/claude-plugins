# claude-plugins

My personal Claude Code marketplace, `rafi-tools`. It holds one plugin, **`rafi`**: the toolkit that every project uses. Once installed, you get slash commands that run a complete build process: plan a feature, build it one piece at a time, review it, audit it for security, SEO, speed and accessibility, and check it before launch.

You do not need to know how plugins work. Install it once (section 2) and use the commands (section 3).

## Contents
1. [What this is and why it is a separate repo](#1-what-this-is-and-why-it-is-a-separate-repo)
2. [Install, check, disable, remove](#2-install-check-disable-remove)
3. [Everything the plugin gives you](#3-everything-the-plugin-gives-you)
4. [Using it day to day](#4-using-it-day-to-day)
5. [Stacks: how to handle any technology](#5-stacks-how-to-handle-any-technology)
6. [The audit standards](#6-the-audit-standards)
7. [Maintaining the plugin](#7-maintaining-the-plugin)
8. [Repo layout](#8-repo-layout)
9. [Design decisions](#9-design-decisions)
10. [Troubleshooting](#10-troubleshooting)
11. [FAQ](#11-faq)
12. [Known caveats](#12-known-caveats)

---

## 1. What this is and why it is a separate repo

Your setup has two halves that change at different speeds:

| Half | Lives in | Changes |
|---|---|---|
| **The toolkit**: commands, audit standards, agents, hooks, stack profiles | This repo (the plugin) | Often. You keep improving it, and every project gets the improvement |
| **The project files**: `CLAUDE.md`, rules, permissions, CI, docs folders | `claude-template` repo, copied into each project | Rarely. They must live inside the project |

A plugin cannot carry `CLAUDE.md`, rules, or permission settings, which is why the second half exists. You never copy the toolkit into projects. You install it once and every repo can use it.

Everything the plugin provides is prefixed `rafi:`, for example `/rafi:slice`. The prefix keeps your commands separate from Claude's built-in ones and from other plugins.

## 2. Install, check, disable, remove

### Install (once per computer)
```bash
claude plugin marketplace add therafiniac/claude-plugins
claude plugin install rafi@rafi-tools
```
Restart Claude Code afterward. The repo is private, so git on your computer must be logged in to GitHub (an SSH key, or a token used with an `https://` URL).

The first command tells Claude Code where your marketplace is. The second installs the plugin from it. The plugin then works in every project on this computer.

### Check it worked
Open Claude Code and type `/rafi:`. You should see a list of commands. You can also run `/plugin` to see it as enabled, or in a terminal:
```bash
claude plugin list
claude plugin details rafi
```
The second command shows what the plugin contains and roughly how much of Claude's memory it uses.

### Turn it on for one project only
Run this inside the project:
```bash
claude plugin install rafi@rafi-tools --scope project
```
It writes the setting into that project's `.claude/settings.json`. The `claude-template` already does this for you, so projects made from it offer to install the plugin when you trust the folder.

### Disable or remove
```bash
claude plugin disable rafi@rafi-tools
claude plugin uninstall rafi@rafi-tools
```

## 3. Everything the plugin gives you

### 3.1 Workflow commands (you type these)

| Command | Use it to | What happens |
|---|---|---|
| `/rafi:bootstrap-project <idea>` | Start a new project | Asks about name, purpose, framework, database, hosting, and auth. Shows a plan and waits for approval. Then scaffolds, fills the docs, writes the project README, asks you the PRD questions, installs packages, and runs the checks |
| `/rafi:add-stack <name>` | Use a technology that is not in the list | Interviews you, reads the official docs, drafts a stack profile, and waits for approval |
| `/rafi:plan-feature <name>` | Plan a feature | Reads your PRD and code, then proposes slices, files, tests, and risks. Writes no code until you approve |
| `/rafi:slice <name>` | Build one small piece | Implements only that piece, writes tests, runs checks, runs the reviewer and the matching audits, reports briefly, and suggests a commit message. Never commits |
| `/rafi:fix-issue <description>` | Fix a bug | Writes a failing test first, finds the root cause, makes the smallest fix, and runs the checks |
| `/rafi:release-check` | Check before launch | Runs every check, the browser and speed tests, and all four audits at full size. Ends with "ship" or "hold" |
| `/rafi:retro` | Learn from a session | Reviews your corrections and proposes rules to add to `CLAUDE.md`. You approve each one |

### 3.2 Audits and review (you type these, or the workflow calls them)

| Command | Checks against | Ask for it when |
|---|---|---|
| `/rafi:security-audit [scope]` | An OWASP-aligned security standard, 15 sections | You changed login, sessions, APIs, uploads, or packages |
| `/rafi:seo-audit [scope]` | An SEO standard | You changed public pages, URLs, or metadata |
| `/rafi:performance-audit [scope]` | A performance standard | You added queries, lists, or heavy libraries |
| `/rafi:accessibility-audit [scope]` | A WCAG 2.2 AA standard | You changed UI, forms, or colors |
| `/rafi:code-review [scope]` | Your production code standards | Before any commit |

**Scope** is optional: `diff` (your current branch compared with `main`, the default), `full` (everything), or a path or feature name such as `src/features/tags`.

How an audit works:
1. It runs in its own separate context, so the reading does not fill up your main chat.
2. It reads the short `SKILL.md`, then only the standard sections that match what changed. The table at the top of each `SKILL.md` maps kinds of change to section numbers.
3. It reads `docs/stack-profile.md` for stack-specific checks.
4. It judges every item: Pass, Fail, Not applicable, or "Needs manual verification" for things code cannot prove, such as a screen reader test or a Search Console check.
5. It writes findings to `docs/audits/<name>.md` in the project (date, section, finding, severity, status) and never deletes old rows.
6. It only reports. It never edits your code. Fixes happen in `/rafi:slice` or `/rafi:fix-issue`.

### 3.3 Agents (Claude uses these itself)

| Agent | Job | Limits |
|---|---|---|
| `rafi:code-reviewer` | Reviews the changes against your standards | Read-only |
| `rafi:security-auditor` | Security review of a change | Read-only, and may write only `docs/audits/security.md` |
| `rafi:test-writer` | Writes tests | Writes tests only, never source code. Reports bugs instead of fixing them |

### 3.4 Hooks (automatic while the plugin is on)

| When | What runs | Why |
|---|---|---|
| After Claude edits a file | `scripts/format-file.sh` formats that file | Consistent code without asking |
| When Claude finishes a turn | `scripts/verify-on-stop.sh` runs a quick type check | Claude fixes type errors before handing work back. It retries once per turn, so it cannot loop |

Both hooks work with any stack:
- **Formatter:** runs the first line of `.claude/format-cmd` if it exists (the edited file path is added at the end). Otherwise, in a pnpm project, it runs Prettier. Otherwise it does nothing.
- **Type check:** runs the first line of `.claude/typecheck-cmd` if it exists. Otherwise, if `package.json` has a `typecheck` script, it runs `pnpm -s typecheck`. Otherwise it does nothing.

For Python you might put `ruff format` in `.claude/format-cmd` and `mypy .` in `.claude/typecheck-cmd`. Both hooks need `jq` installed. Neither can break your work: the formatter ignores its own failures, and the type check only reports errors.

## 4. Using it day to day

The full end-to-end guide, including setup and publishing, is in the `claude-template` README. The core loop:

```
/clear
/rafi:plan-feature <name>      read the plan, approve it
/rafi:slice <first piece>      read the changes, commit
/clear
/rafi:slice <next piece>       ... repeat
```

Then push, check the results on GitHub, and merge. For bugs use `/rafi:fix-issue`. Before launching use `/rafi:release-check`. After a rough session use `/rafi:retro`.

Two habits:
- One task per chat. `/clear` between tasks.
- If Claude gets something wrong twice, add a line to the project's `CLAUDE.md` under `Gotchas`.

## 5. Stacks: how to handle any technology

Projects use different technologies, so the plugin does not hard-code any. A **stack profile** is a short file that tells Claude and the audits the rules for one technology. Profiles come in two kinds, and every project combines one of each:

| Kind | Folder | Covers | Examples now |
|---|---|---|---|
| **Framework** | `plugins/rafi/stacks/frameworks/` | Folders, layering, tooling, SEO, accessibility, speed | `nextjs`, `react-express` |
| **Database** | `plugins/rafi/stacks/databases/` | Client, migrations, queries, tests, security, speed | `mongodb`, `postgres` |

Because they are separate, combinations cost nothing:

| Project | Framework | Database |
|---|---|---|
| Blog with SEO | `nextjs` | `mongodb` or `postgres` |
| Classic MERN app | `react-express` | `mongodb` |
| Dashboard with SQL | `react-express` | `postgres` |

### How a profile is used
1. `/rafi:bootstrap-project` asks for a framework and a database, reads both files, and proposes one merged scaffold plan.
2. It combines both into **`docs/stack-profile.md`** in your project: a title, then the framework file, then the database file.
3. Every audit reads `docs/stack-profile.md` and applies its checks on top of the general standard. So the Next.js profile adds "server actions must check ownership" and the Postgres profile adds "index every foreign key".

### A technology that is not in the list
Run:
```
/rafi:add-stack SvelteKit
```
Claude asks what you need (kind, language, versions, tools, hosting), reads the official documentation for those exact versions, and drafts a profile in the standard layout, with a Sources section listing the pages it used. You review it and approve. It is saved in your project as `docs/stack-drafts/<kind>-<name>.md`. Then:
- **Use it now:** run `/rafi:bootstrap-project` and give the draft path when it asks for a framework or database.
- **Keep it for every project:** copy the file into your local clone of this repo at `plugins/rafi/stacks/frameworks/` or `.../databases/`, raise the version (section 7), and push.

### A stack that is not Node and pnpm
The project template assumes Node and pnpm. For Python, Go, or anything else, the profile's **Adaptation notes** section lists what to change:
- create `.claude/typecheck-cmd` and `.claude/format-cmd` (section 3.4)
- rewrite `.github/workflows/*.yml` for that language
- replace the `pnpm` entries in the `.claude/settings.json` allow list
- replace or drop `.husky/` and `.lintstagedrc.json`

### Writing or editing a profile by hand
Copy `plugins/rafi/stacks/_template.md` and fill each section. Rules must be specific and checkable ("every server action checks ownership"), never vague ("be secure"). Point each security check at the section number of the standard it belongs to. Verify version-specific claims in the official docs and list the sources.

## 6. The audit standards

Each audit has a standard split into one file per section, so an audit loads only what a change needs. For example the security standard is 585 lines, but a change to an upload endpoint reads only the sections on uploads and access control.

| Audit | Folder | Files |
|---|---|---|
| Security | `plugins/rafi/skills/security-audit/references/` | `01-authentication.md` to `15-third-party-integrations.md`, plus overview and appendix |
| SEO | `.../seo-audit/references/` | `01` to `10`, plus overview and appendix |
| Performance | `.../performance-audit/references/` | `01` to `08`, plus overview and appendix |
| Accessibility | `.../accessibility-audit/references/` | `01` to `07`, plus overview and appendix (a WCAG 2.2 AA standard) |
| Code review | `.../code-review/references/` | `01` to `12`, from your production code standards |

Rules for the files:
- The number in the file name is the section number. The mapping table in each `SKILL.md` uses those numbers.
- The `00-overview.md` of each standard holds the severity scale and how to judge items.
- Findings logs are never stored here. They live in each project's `docs/audits/`.

To change a standard, edit the section file and follow section 7. If you add or renumber a section, update the mapping table in that skill's `SKILL.md`. Standards change slowly, and an audit reflects the version in place when it ran.

## 7. Maintaining the plugin

### 7.1 Get a working copy
```bash
git clone git@github.com:therafiniac/claude-plugins.git
cd claude-plugins
```

### 7.2 Change something

| You want to change | Edit |
|---|---|
| An audit standard | The section file in `plugins/rafi/skills/<audit>/references/` |
| How a command or audit behaves | `plugins/rafi/skills/<name>/SKILL.md` |
| A stack profile | `plugins/rafi/stacks/frameworks/<name>.md` or `.../databases/<name>.md` |
| A hook | `plugins/rafi/scripts/*.sh` or `plugins/rafi/hooks/hooks.json` |
| An agent | `plugins/rafi/agents/<name>.md` |

### 7.3 Raise the version
Change `version` in **both** files, to the same number:
- `plugins/rafi/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

**This step is easy to forget and it matters.** Claude Code keeps every installed copy on its current version until the number changes, so without a version bump nobody receives your edit.

| Change | Bump |
|---|---|
| A typo or a small fix | Patch: `1.1.0` to `1.1.1` |
| A new skill, stack profile, or standard section | Minor: `1.1.0` to `1.2.0` |
| Something that changes how existing commands work | Major: `1.1.0` to `2.0.0` |

### 7.4 Check the files are valid
```bash
claude plugin validate .
claude plugin validate ./plugins/rafi
```
Both should say "Validation passed".

### 7.5 Test before you rely on it
Create a throwaway project from the template and run the command you changed. Better: install the plugin from a local folder to try it before pushing:
```bash
claude plugin marketplace add /full/path/to/claude-plugins
```

### 7.6 Publish
```bash
git add -A
git commit -m "feat: add mysql database profile"
git push
```

### 7.7 Update your computers
```bash
claude plugin marketplace update rafi-tools
claude plugin update rafi@rafi-tools
```
Restart Claude Code to apply the update. Every project on that computer then uses the new version.

### 7.8 Roll back
If a release breaks something, use `git revert` on the bad commit, raise the version again, and repeat 7.6 and 7.7. Going forward with a higher number is safer than going back to an old one.

## 8. Repo layout

```
claude-plugins/
├── README.md
├── .claude-plugin/
│   └── marketplace.json          the catalog: lists the plugin and its version
└── plugins/
    └── rafi/
        ├── .claude-plugin/
        │   └── plugin.json       the plugin's name and version
        ├── skills/               commands and audits, one folder each with a SKILL.md
        │   ├── bootstrap-project/  plan-feature/  slice/  fix-issue/
        │   ├── release-check/  retro/  add-stack/
        │   └── security-audit/  seo-audit/  performance-audit/
        │       accessibility-audit/  code-review/   (each has references/)
        ├── agents/               code-reviewer, security-auditor, test-writer
        ├── hooks/hooks.json      when the hooks run
        ├── scripts/              format-file.sh, verify-on-stop.sh
        └── stacks/
            ├── _template.md      blank profile
            ├── frameworks/       nextjs.md, react-express.md
            └── databases/        mongodb.md, postgres.md
```

## 9. Design decisions

- **A generic core with a swappable stack layer.** The standards are framework-agnostic. Anything about a specific technology lives only in `stacks/`.
- **Frameworks and databases are separate profiles**, so a new database never means rewriting a framework profile.
- **Standards are split by section**, so an audit does not load hundreds of lines it does not need.
- **Audits only report.** They never edit code. Changes happen in a slice or a fix, where tests and review wrap them.
- **Findings logs are per project**, never in this repo.
- **Workflow commands are manual-only** (`disable-model-invocation`), so they never fire by surprise and cost nothing in Claude's memory until you use them.
- **The hooks default to Node and pnpm but read two optional files**, so other languages work without editing the plugin.
- **Nothing here needs GitHub settings**, secrets, or paid features.

## 10. Troubleshooting

| Symptom | Fix |
|---|---|
| `/rafi:` shows nothing | Run `claude plugin list`. If `rafi` is missing, repeat the install in section 2 and restart Claude Code |
| "marketplace not found" or a git error while adding it | Your git is not logged in to GitHub. Set up an SSH key or a token, then retry |
| You edited the plugin and nothing changed | You did not raise the version in both files (7.3), or you did not run the update commands (7.7) or restart Claude Code |
| `claude plugin validate` reports an error | Read the message. Usual causes are invalid JSON, a missing file, or a `name` in `plugin.json` that does not match the marketplace entry |
| An audit reads the wrong sections | Fix the mapping table at the top of that skill's `SKILL.md` |
| The Stop hook blocks Claude repeatedly | Fix the type error it reports. Or make `.claude/typecheck-cmd` point at a command that passes |
| Hooks print `jq: command not found` | Install `jq` (`sudo dnf install jq`) |
| The formatter does nothing | The project has no Prettier and no `.claude/format-cmd`. Add one of them |
| `/rafi:bootstrap-project` does not list a stack you added | The file must be in `stacks/frameworks/` or `stacks/databases/`, and the plugin version must be raised and updated |

## 11. FAQ

**Do I need this repo on every computer?** No. Only the install commands in section 2. You clone the repo itself only on a computer where you edit the plugin.

**Does it work without the template?** Yes. The plugin works in any repo. Without the template you will be missing `CLAUDE.md`, the rules, the docs folders, the scripts, and CI. See "Using the template in an existing repo" in the template README.

**Can I use only some commands?** Yes. Every command stands alone. `/rafi:code-review` and the four audits work without the rest of the workflow.

**Is my code sent anywhere?** The plugin runs inside Claude Code on your computer, like any other Claude Code session. It adds no services of its own.

**Can other people use it?** It is your private repo. Anyone you give access to can install it the same way.

**How much of Claude's memory does it use?** The manual-only workflow commands cost nothing until used. The audit and review descriptions are always loaded but short. `claude plugin details rafi` shows the projected cost.

## 12. Known caveats

- The plugin and marketplace files pass `claude plugin validate`, and the hook scripts were tested branch by branch. They have not been run through a long live session, so watch the forked audits and the Stop hook in early use.
- Some standards contain Postgres-flavored examples, for instance `EXPLAIN` in the performance standard. The database profiles give the exact commands for MongoDB and Postgres.
- The stack profiles were written from documentation and may lag the newest framework releases. Each profile says what to verify, and `/rafi:add-stack` verifies against current docs.
- The hooks need `jq`, and the default paths need `pnpm`.
