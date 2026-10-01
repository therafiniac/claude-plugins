# claude-plugins

**My personal Claude Code toolkit.** This repo is a private plugin marketplace called `rafi-tools`, holding one plugin called **`rafi`**. Once installed, Claude Code gains a set of `/rafi:` commands that take a project from a rough idea to a launched site: shape the idea, pick the technologies, set up the project, plan features, build them piece by piece with tests, review and audit them, and check everything before launch.

> **Which README do I need?**
> - The **[claude-template README](https://github.com/therafiniac/claude-template)** is the user guide: setup, a full worked example from idea to live site, and the daily routine. **New? Start there.**
> - **This one** is the reference manual: every command in detail, the library catalog, the audits, the automatic parts, and how to change the toolkit itself.

## Contents
1. [What this is, and why it is a separate repo](#1-what-this-is-and-why-it-is-a-separate-repo)
2. [Install, check, update, disable, remove](#2-install-check-update-disable-remove)
3. [Command reference](#3-command-reference)
4. [The capabilities catalog (libraries)](#4-the-capabilities-catalog-libraries)
5. [Stack profiles (frameworks and databases)](#5-stack-profiles-frameworks-and-databases)
6. [The audits](#6-the-audits)
7. [The automatic parts: agents and hooks](#7-the-automatic-parts-agents-and-hooks)
8. [Maintaining the plugin (worked example)](#8-maintaining-the-plugin-worked-example)
9. [Repo layout](#9-repo-layout)
10. [Design decisions](#10-design-decisions)
11. [Troubleshooting](#11-troubleshooting)
12. [FAQ](#12-faq)
13. [Known caveats](#13-known-caveats)

---

## 1. What this is, and why it is a separate repo

**In plain words:** a plugin is a package of commands and rules that you install into Claude Code once, and then use in every project. This plugin is my personal way of building software, written down so Claude follows it every time.

The whole setup has two halves that change at different speeds:

| Half | Lives in | How often it changes |
|---|---|---|
| **The toolkit**: commands, audit checklists, agents, hooks, the catalog of frameworks, databases, and libraries | This repo (the plugin) | Often. Improve it once, and every project gets the improvement |
| **The project files**: `CLAUDE.md`, rules, permission settings, commit checks, docs folders | The `claude-template` repo, copied into each project | Rarely. These must live inside each project |

A plugin cannot carry a project's `CLAUDE.md`, rules, or permissions. That's the only reason the template exists. You never copy the toolkit into a project; you install it once per computer.

Everything the plugin provides is prefixed `rafi:` (for example `/rafi:slice`). The prefix keeps these commands separate from Claude's built-in ones and from any other plugin.

## 2. Install, check, update, disable, remove

### Install (once per computer)
```bash
claude plugin marketplace add therafiniac/claude-plugins
claude plugin install rafi@rafi-tools
```
The first command tells Claude Code where the marketplace is. The second installs the plugin from it. **Restart Claude Code** afterwards.

The repo is private, so git on this computer must be logged in to GitHub first: an SSH key (template README, 5.1) or a token with an `https://` address.

### Check it worked
In Claude Code, type `/rafi:`. **Success looks like** a list including `brainstorm`, `bootstrap-project`, `plan-feature`, `slice`, and the audits. Or, in a terminal:
```bash
claude plugin list            # rafi should appear as enabled
claude plugin details rafi    # what it contains and roughly how much of Claude's memory it uses
```

### Update to the newest version
```bash
claude plugin marketplace update rafi-tools
claude plugin update rafi@rafi-tools
```
Restart Claude Code. Every project on this computer then uses the new version.

### Turn it on for one project only
Inside the project:
```bash
claude plugin install rafi@rafi-tools --scope project
```
This writes the setting into the project's `.claude/settings.json`. Projects made from the template already have it, so Claude Code offers to install the plugin when you trust the folder.

### Disable or remove
```bash
claude plugin disable rafi@rafi-tools     # pause it, keep it installed
claude plugin uninstall rafi@rafi-tools   # remove it
```

## 3. Command reference

There are two kinds of commands:
- **Workflow commands** (3.1–3.10) run the building process. They are **manual-only**: Claude never starts them on its own, and they cost nothing in Claude's memory until you type them.
- **Audits and review** (3.11–3.12) check your work. You can type them, and the workflow commands call them for you when a change needs them.

> Example conversations below are **illustrations**. Real wording and choices will differ.

### 3.1 `/rafi:brainstorm <idea>`: shape a rough idea

| | |
|---|---|
| **Use it when** | You have an idea but haven't decided how to build it or with what |
| **It asks you** | A few questions at a time: who it's for, the 3–5 core pages or flows, what's out of scope, who edits content and how technical they are, data (logins, payments, personal data), constraints (budget, hosting, deadline, traffic, languages), and what already exists |
| **It proposes** | 2–3 approaches with effort, running cost, and what each makes easy or hard, plus a recommendation. Then a stack table from the catalog: framework, database, hosting, auth, and every relevant library concern, each with a proposed choice and alternatives |
| **It creates** | `docs/brainstorm.md`: idea, users, core flows, non-goals, draft acceptance criteria, chosen and rejected approaches, the stack table, open questions |
| **It never** | Writes code, scaffolds, or installs anything |

```
you:    /rafi:brainstorm booking site for a yoga studio
claude: 1. Who books, and how far ahead?  2. Does the studio take payment online?
        3. Who manages the class schedule?  4. Budget per month?
...
claude: | Concern  | Proposed     | Alternatives | Why                         |
        | Auth     | better-auth  | clerk        | members log in, low cost    |
        | Payments | razorpay     | stripe       | customers pay by UPI        |
        | Email    | resend       | postmark     | booking confirmations       |
        ...
```
**Next step:** `/rafi:bootstrap-project`, which reads `docs/brainstorm.md` instead of asking again.

### 3.2 `/rafi:bootstrap-project <idea>`: set up a new project

| | |
|---|---|
| **Use it when** | You're in a fresh copy of the template and know (or brainstormed) the stack |
| **It asks you** | Only what `docs/brainstorm.md` leaves out. Without that file: name, purpose, framework, database, hosting, login needs, database name, non-goals |
| **It proposes** | (1) a capabilities table: each concern with a proposed option and fitting alternatives; (2) after that, a scaffold plan: folders, every package with a reason, config files, scripts. Before the plan, it checks the current official docs for every chosen library |
| **It creates** | The scaffolded project (using the framework's official generator, then the profiles on top), `docs/stack-profile.md`, a filled `CLAUDE.md`, a project README replacing the template's, `docs/architecture.md`, `docs/adr/001-stack.md`, and `docs/prd/<name>.md` |
| **It runs** | `pnpm install`, turns on the commit checks and verifies them, then `pnpm check` and `pnpm build` |
| **It never** | Writes anything before you approve the plan; overwrites the template's own files; invents your users or acceptance criteria; approves a package's install script without asking you |

If a framework or library you want isn't in the catalog, it stops and tells you to run `/rafi:add-stack` or `/rafi:add-capability` first.

### 3.3 `/rafi:add-stack <name>`: add a framework or database

| | |
|---|---|
| **Use it when** | Your framework (say SvelteKit, Django) or database (say MySQL) isn't in the catalog |
| **It asks you** | Kind (framework or database), language and exact versions, package manager and tools, deployment, and which databases a framework will pair with |
| **It does** | Reads the official docs for those exact versions, then drafts a profile in the standard layout with a Sources list. For non-Node stacks, it also lists every template file to change |
| **It creates** | `docs/stack-drafts/<kind>-<name>.md` after your approval |
| **Next** | Use it now: give the draft path when bootstrap asks for a framework or database. Keep it for all projects: copy it into this repo (section 8) |

### 3.4 `/rafi:add-capability <concern> [option]`: add a library

Two modes, picked automatically:

**Add mode:** the concern is in the catalog and the project has a `docs/stack-profile.md`.
```
you:    /rafi:add-capability search
claude: Your stack: astro (static), no database.
        Proposed: pagefind (adopt). No other option fits a static site.
you:    ok
claude: (checks Pagefind's current docs) Plan: add pagefind as a dev dependency,
        build script "astro build && pagefind --site dist", search dialog in the
        header, data-pagefind-body on lesson pages. Approve?
```
After approval it builds, runs `pnpm check` and `pnpm build`, adds the choice to `docs/stack-profile.md`, writes an ADR, and ends with a commit message. It never commits.

**Draft mode:** the concern or the library you named isn't in the catalog.
```
you:    /rafi:add-capability payments paypal
```
It asks which frameworks it must work with, hosted or self-hosted, and budget. It researches the official docs and drafts the entry in the catalog format (status, "works with", setup, checks). Once you approve, it's saved to `docs/stack-drafts/capability-<concern>.md`. Use it in this project right away, or copy it into this repo for every project (section 8).

### 3.5 `/rafi:spec <feature>`: write a feature spec

| | |
|---|---|
| **Use it when** | You're about to build a feature and need its spec in `docs/prd/` |
| **It asks you first** | **A)** "Ask me questions and write it for me", or **B)** "Create the file and I'll fill it in myself, then you review it" |
| **A: Claude asks** | Up to four plain-language questions at a time: the problem, who uses it, what's in and out, what the user sees and does, what happens when something goes wrong. Then it drafts the acceptance criteria (Given / When / Then), covering the normal case, bad or empty input, not found, no permission (if the project has logins), and limits. Criteria you didn't state yourself are marked **(proposed)**, and you confirm, change, or remove each one |
| **B: you fill it** | It creates `docs/prd/<feature>.md` from the template with a hint per section and one finished example criterion, then waits. When you say you're done, it reviews the file: vague criteria ("works well"), missing failure cases, scope that no criterion covers. It suggests a rewrite for each problem and edits only what you accept |
| **It creates** | `docs/prd/<feature>.md` |
| **It never** | Asks about code or libraries; writes code or a plan; keeps a requirement you didn't agree to |

```
you:    /rafi:spec lesson tags
claude: How do you want to write this spec?
        A) Ask me questions and write it for me
        B) Create the file and I'll fill it in myself, then you review it
you:    A
claude: 1. What problem do tags solve for students?  2. Who adds the tags?
        3. Should a student be able to see all tags somewhere?  4. Anything out of scope?
...
claude: Acceptance criteria:
        - Given a lesson tagged "grammar", when I open /tags/grammar, then I see that lesson.
        - Given a tag with no lessons, when I open its page, then I get a 404. (proposed)
        Keep, change, or remove the proposed ones?
```
**Next step:** `/clear`, then `/rafi:plan-feature lesson tags`.

### 3.6 `/rafi:plan-feature <name>`: plan a feature

| | |
|---|---|
| **Use it when** | A feature has a spec in `docs/prd/` (from `/rafi:spec`) and you're ready to build. Without a spec, it tells you to run `/rafi:spec` first |
| **It reads** | The PRD, `docs/architecture.md`, `docs/stack-profile.md`, and the code the feature touches |
| **It asks you** | For acceptance criteria if they're missing or not testable. It never invents them |
| **It proposes** | Slices in build order (each a thin vertical piece: data → logic → route → tests → UI), the files for each, data and API changes, test cases per slice, risks, and which audits each slice will trigger |
| **It never** | Writes code or creates files |

### 3.7 `/rafi:slice <name>`: build one piece

| | |
|---|---|
| **Use it when** | A plan is approved, and you want to build the next piece |
| **It does** | 1. Restates the slice in three lines and builds only that. 2. Writes tests (the test-writer agent for large suites). 3. Runs `pnpm check` until it passes. 4. Has the code-reviewer agent review the change and fixes Blocker and Major findings. 5. Runs the audits that match the change and fixes Critical and High findings; the rest stay logged. 6. Adds a browser test for a new user-facing flow |
| **It reports** | Five lines or fewer, ending with only a commit message such as `feat(tags): add tag pages` |
| **It never** | Starts without an approved plan; commits |

### 3.8 `/rafi:fix-issue <description>`: fix a bug

| | |
|---|---|
| **It does** | 1. Writes a test that fails because of the bug (if it can't reproduce the bug in a test, it explains why and stops). 2. States the root cause in one sentence. 3. Makes the smallest fix, with no unrelated changes. 4. Runs `pnpm check`. 5. Runs a security review if the cause is a security or data problem |
| **It reports** | Root cause, fix, test added, ending with only a commit message such as `fix(tags): match tags case-insensitively` |
| **It never** | Patches symptoms instead of the cause; commits |

### 3.9 `/rafi:release-check`: before launch

Runs `pnpm check` and `pnpm build`, plus `pnpm test:e2e` and `pnpm lighthouse` if they exist, then the security, performance, and accessibility audits on the whole project (and SEO if the site has public pages). It reports Critical and High findings only and ends with a verdict, **ship** or **hold**, listing the blockers. It reminds you of the checks code can't do: search engine setup, real-user speed data, keyboard and screen-reader walkthrough, hosting settings, rollback plan.

### 3.10 `/rafi:retro`: learn from a session

Reviews the conversation and the audit logs for corrections, repeated instructions, failed commands, recurring findings, and time-wasting surprises. It proposes at most seven items, each sorted into one of:
- a project gotcha (goes in `CLAUDE.md`)
- a project rule (goes in `.claude/rules/`)
- mechanical enforcement (a hook or lint rule, with the exact config)
- a plugin improvement (a list you paste into this repo)

It applies only what you approve. It never edits the plugin itself.

### 3.11 The four audits

| Command | Checks against | Run it when you changed |
|---|---|---|
| `/rafi:security-audit [scope]` | An OWASP-aligned standard, 15 sections | Login, sessions, APIs, uploads, packages |
| `/rafi:seo-audit [scope]` | An SEO standard, 10 sections | Public pages, URLs, page titles and descriptions |
| `/rafi:performance-audit [scope]` | A performance standard, 8 sections | Queries, lists, pages, heavy libraries |
| `/rafi:accessibility-audit [scope]` | A WCAG 2.2 AA standard, 7 sections | UI, forms, layout, colors |

**Scope:** `diff` (your branch compared with `main`, the default), `full` (everything), or a path or feature name such as `src/features/tags`. How they work is in section 6.

### 3.12 `/rafi:code-review [scope]`

Reviews changes against the production code standards (12 sections: thinking before coding, security, error handling, quality, validation, tests, performance, logging, configuration, frontend, git discipline, documentation). Findings are graded **Blocker / Major / Minor / Nit**, one line each with `file:line`, ending with **approve** or **changes needed**. Run it before any commit you make outside a slice.

## 4. The capabilities catalog (libraries)

### 4.1 The idea, with an analogy
Think of a restaurant menu with a **chef's recommendation** on each course. For every job a project might need done (icons, fonts, search, a CMS, payments…), the catalog lists a few **tested options** instead of every library in existence, marks which one is the house default for your framework, and explains when to pick another. You usually just say "yes", but you can always order something else.

Industry teams call this a **paved road** (a small set of approved choices, with a template that sets them up) combined with a **tech radar** (a status for each technology).

### 4.2 Status: adopt, trial, hold

| Status | Meaning | Does bootstrap propose it? |
|---|---|---|
| **adopt** | A safe default. Use it without much thought | Yes, often as the default |
| **trial** | Good when its "pick when" fits your case; check it a little more carefully | Yes, as an alternative |
| **hold** | Don't start new projects with it. Kept only to explain why | Never |

Each option also has **works with** (which frameworks and databases it fits), so you're never offered an option that doesn't work with your stack.

### 4.3 Everything in the catalog

| Concern | Options (status) | Default |
|---|---|---|
| **styling** | tailwind (adopt), tailwind-typography (adopt, add-on for Markdown text), native-css (adopt), runtime-css-in-js (hold) | tailwind; add typography for Markdown or CMS text |
| **ui-components** | none (adopt), shadcn (adopt), react-aria-components (trial), daisyui (trial), runtime-css-in-js-kits (hold) | React frameworks: shadcn. Astro: none |
| **icons** | lucide (adopt), simple-icons (adopt, brand logos), iconify-astro-icon (trial), heroicons (trial), phosphor (trial), icon-fonts (hold) | lucide; add simple-icons for brand logos |
| **fonts** | astro-fonts (adopt), next-font (adopt), fontsource (adopt), system-stack (adopt), google-fonts-cdn (hold) | astro: astro-fonts. nextjs: next-font. Vite apps: fontsource |
| **cms** | none (adopt), keystatic (adopt), decap (trial), sanity (adopt), payload (trial) | none; keystatic for a git-based editor; sanity for structured content |
| **search** | pagefind (adopt), postgres-fts (adopt), meilisearch (trial), algolia (trial) | static sites: pagefind. Apps on Postgres: postgres-fts |
| **forms** | server-endpoint (adopt), turnstile (adopt, spam protection add-on), web3forms (adopt), formspree (trial) | with a server: server-endpoint + turnstile. Static: web3forms |
| **auth** | better-auth (adopt), clerk (trial), authjs (hold), lucia (hold) | better-auth |
| **email** | resend (adopt), postmark (adopt), aws-ses (trial), smtp (trial) | resend |
| **analytics** | umami (adopt), plausible (adopt), cloudflare-web-analytics (adopt), posthog (trial), google-analytics (hold) | content sites: umami. Apps with funnels: posthog |
| **payments** | stripe (adopt), razorpay (adopt), paddle (trial), stripe-managed-payments (trial), lemon-squeezy (hold) | India: razorpay. Elsewhere: stripe |

Each concern's file explains *why* for every status (for example, Lucia is on hold because the library was deprecated in 2025). The files are in `plugins/rafi/stacks/capabilities/`.

### 4.4 What one entry looks like
Each capability file has three parts:

```
# Capability: Search
Ask when: the site has more than about 20 content pages, or the spec mentions search.
Default: static sites → pagefind. Apps on postgres → postgres-fts.

## Options                                          <- the summary: the only part
| Option | Status | Pick when | Works with | Cost |      bootstrap and brainstorm read
| pagefind | adopt | static content site ... | astro, any static output | free |

## Option: pagefind                                 <- copied into your project
Setup: packages, config, scripts                       only if you choose it
Conventions: rules Claude follows
Security / Performance / Accessibility checks: extra items the audits check

## Shared                                           <- copied along with whichever
Rules that apply whatever option you pick              option you choose
```

**Why the split matters:** only the options you choose end up in your project's `docs/stack-profile.md`, so an option never says "same as the other option". Anything common goes in `## Shared`.

### 4.5 How a choice reaches your project
1. Brainstorm or bootstrap reads each file's summary and proposes a choice per concern.
2. You confirm or swap.
3. Bootstrap checks the chosen option against the library's **current** official docs, so an outdated note in the catalog doesn't reach your project.
4. It copies the chosen option (plus `## Shared`) into `docs/stack-profile.md`, under a Stack table like this:
   ```
   | Concern  | Choice                   |
   |----------|--------------------------|
   | Framework| astro (static output)    |
   | styling  | tailwind                 |
   | search   | pagefind                 |
   ```
5. From then on, every audit reads `docs/stack-profile.md` and adds that option's checks, for example Pagefind's "never index private pages".

### 4.6 Adding to the catalog
- **During a project:** `/rafi:add-capability <concern> <library>` drafts it (3.4).
- **By hand:** copy `plugins/rafi/stacks/_capability-template.md`, fill it in, and follow section 8.

Rules for a good entry: 2–5 options, never "every package"; every rule specific and checkable ("the secret key is a server-only env var", not "be secure"); every audit check points at a section number of the standard; "works with" holds only profile names; each option stands alone.

## 5. Stack profiles (frameworks and databases)

### 5.1 What a profile is
A **stack profile** is a short file with the rules for one framework or one database: folder layout, how the standard scripts map to that technology, conventions, and extra checks for each audit. The general standards stay the same for every project; profiles add the technology-specific parts.

| Kind | Folder | Covers | Available now |
|---|---|---|---|
| **Framework** | `plugins/rafi/stacks/frameworks/` | Folders, layers, tooling, SEO, accessibility, speed | `nextjs`, `astro`, `react-spa`, `react-express`, `wordpress` |
| **Database** | `plugins/rafi/stacks/databases/` | Client, migrations, queries, tests, security, speed | `mongodb`, `postgres` |

A project has **one framework**, **zero or one database**, and any number of **capabilities** (section 4).

### 5.2 Which framework for what

| Framework | Best for |
|---|---|
| `astro` | Blogs, docs, marketing and portfolio sites. Static by default, very fast |
| `nextjs` | Public sites that also need server features (logins, dashboards, SEO pages) |
| `react-spa` | A React frontend for an API that already exists |
| `react-express` | React plus an Express API in one repo, for apps behind a login |
| `wordpress` | Client or content sites on WordPress (custom themes and plugins) |

Combinations are free because the kinds are separate:

| Project | Framework | Database |
|---|---|---|
| Blog with SEO and an admin | `nextjs` | `postgres` or `mongodb` |
| Classic MERN app | `react-express` | `mongodb` |
| Dashboard with SQL | `react-express` | `postgres` |
| Portfolio, docs, or marketing site | `astro` | none |
| React frontend for an existing API | `react-spa` | none |
| Client site on WordPress | `wordpress` | none (WordPress has its own MySQL) |

### 5.3 A technology that isn't in the list
```
/rafi:add-stack SvelteKit
```
See 3.3. The draft lands in `docs/stack-drafts/`. Use it in the project right away, or copy it into this repo to keep it (section 8).

### 5.4 A stack that isn't Node and pnpm
The template assumes Node and pnpm. For Python, Go, PHP, and others, the profile's **Adaptation notes** list what to change:
- create `.claude/typecheck-cmd` and `.claude/format-cmd` (section 7.2)
- replace the `pnpm` entries in the `.claude/settings.json` allow list
- replace or drop `.husky/` and `.lintstagedrc.json`

### 5.5 Writing a profile by hand
Copy `plugins/rafi/stacks/_template.md` and fill each section. Rules must be specific and checkable ("every server action checks ownership"), never vague ("be secure"). Point each security check at the section number of the standard it belongs to. Verify version-specific claims in the official docs, and list the sources. Library choices (styling, icons, …) don't belong in a framework profile; they're capabilities.

## 6. The audits

### 6.1 What an audit is
An audit is Claude reviewing your code against a written checklist (a **standard**) and logging what it finds. There are four standards plus the code-review standard:

| Standard | Folder | Sections |
|---|---|---|
| Security (OWASP-aligned) | `plugins/rafi/skills/security-audit/references/` | `01-authentication` to `15-third-party-integrations` |
| SEO | `.../seo-audit/references/` | `01` to `10` |
| Performance | `.../performance-audit/references/` | `01` to `08` |
| Accessibility (WCAG 2.2 AA) | `.../accessibility-audit/references/` | `01` to `07` |
| Code review | `.../code-review/references/` | `01` to `12` |

Each folder also has `00-overview.md` (severity scale, how to judge) and an appendix of the standards referenced.

### 6.2 How an audit runs, step by step
1. It runs in a **separate context**, so all its reading doesn't fill up your main chat.
2. It reads the short `SKILL.md`, whose table maps kinds of change to section numbers. Example from security: "New endpoint, server action, API route → sections 3, 4, 6, 8". It reads **only** those sections. The security standard is about 585 lines; an upload change reads only the upload and access-control sections.
3. It reads `docs/stack-profile.md` and adds the framework, database, and capability checks.
4. It judges every item: **Pass**, **Fail**, **N/A** (with a one-line reason), or **Needs manual verification** (things code can't prove, like a screen-reader test). Every Fail cites `file:line`; every Pass names what satisfies it.
5. It writes findings to `docs/audits/<name>.md` in your project and replies with only the Fails and Needs-verification items, at most 30 lines.
6. **It only reports. It never edits code.** Fixes happen in `/rafi:slice` or `/rafi:fix-issue`, where tests and review surround them.

### 6.3 Severity scales

| Security | Meaning |
|---|---|
| **Critical** | Remote, unauthenticated, full compromise or data breach |
| **High** | Auth bypass, privilege escalation, significant data exposure |
| **Medium** | Needs preconditions, limited damage |
| **Low** | Hardening and best-practice gaps |

| Accessibility | Meaning |
|---|---|
| **Critical** | A keyboard or screen-reader user cannot complete a core task |
| **High** | A WCAG Level A failure, or a Level AA failure with no workaround |
| **Medium** | A Level AA failure with a workaround |
| **Low** | A best-practice gap |

The SEO and performance standards define their scales in their own `00-overview.md`. Code review uses **Blocker / Major / Minor / Nit**. In a slice, Critical and High (audits) and Blocker and Major (review) are fixed before the slice is reported done.

### 6.4 Reading a findings log
Example `docs/audits/security.md` in a project:
```
| Date       | Section | Finding                                              | Severity | Status           |
|------------|---------|------------------------------------------------------|----------|------------------|
| 2026-10-02 | §13     | Contact endpoint has no rate limit (src/actions.ts:14) | Medium   | Fixed 2026-10-03 |
| 2026-10-02 | §10     | CSP header not set on the host                        | High     | Open             |
| 2026-10-02 | §5      | Confirm Turnstile secret is set in hosting env        | —        | Needs verification |
```
Rows are never deleted; fixed ones are marked **Fixed** with a date, so the log doubles as a history.

### 6.5 Changing a standard
Edit the section file, then follow section 8. If you add or renumber a section, update the mapping table in that audit's `SKILL.md`, or audits will read the wrong sections.

## 7. The automatic parts: agents and hooks

You never call these yourself.

### 7.1 Agents (helpers Claude hands work to)

| Agent | Job | Limits |
|---|---|---|
| `rafi:code-reviewer` | Reviews a change against the code standards; Blocker / Major / Minor / Nit | Read-only |
| `rafi:security-auditor` | Security review of a change, following the security audit | Read-only, except it may write `docs/audits/security.md` |
| `rafi:test-writer` | Writes tests covering happy path, invalid input, unauthorized access, not-found, boundaries, and concurrency where relevant | Writes tests only, never source code. Reports bugs with `file:line` instead of fixing them. Never weakens an assertion to make a test pass |

### 7.2 Hooks (scripts that run at set moments)

| When | What runs | What you notice |
|---|---|---|
| After Claude edits or writes a file | `scripts/format-file.sh` tidies that file | Code stays consistently formatted without asking |
| When Claude finishes a reply | `scripts/verify-on-stop.sh` runs a quick type check | If it fails, Claude sees the errors and fixes them before handing back. It retries once per reply, so it can't loop |

Both hooks work with any language:
- **Formatter:** runs the first line of `.claude/format-cmd` if the project has it (the edited file's path is added at the end). Otherwise, in a pnpm project, Prettier. Otherwise nothing.
- **Type check:** runs the first line of `.claude/typecheck-cmd` if it exists. Otherwise `pnpm -s typecheck` if `package.json` has a `typecheck` script. Otherwise nothing.

Example for a Python project: `.claude/format-cmd` contains `ruff format`, and `.claude/typecheck-cmd` contains `mypy .`.

Both hooks need `jq`. Neither can damage your work: the formatter ignores its own failures, and the type check only reports.

## 8. Maintaining the plugin (worked example)

**The example:** adding **Tabler Icons** as a new option in the icons capability, from start to finish. The same steps apply to any change.

### 8.1 Get a working copy (once per computer where you edit)
```bash
git clone git@github.com:therafiniac/claude-plugins.git
cd claude-plugins
```

### 8.2 Make the change
Open `plugins/rafi/stacks/capabilities/icons.md`:
1. Add a row to the `## Options` table:
   ```
   | tabler | trial | Very large outline set with a consistent 24px grid | astro, nextjs, react-spa, react-express | free (MIT) |
   ```
2. Add a section **before** `## Shared`:
   ```
   ## Option: tabler
   Setup: <packages per framework, checked in Tabler's official docs>
   Sources: <official documentation URLs>
   ```
   Keep it standalone: don't write "same as lucide". The common icon rules are already in `## Shared`.
3. Update `Verified:` at the top if you re-checked the other options.

Where things live, for other kinds of change:

| You want to change | Edit |
|---|---|
| A library option | `plugins/rafi/stacks/capabilities/<concern>.md` |
| A framework or database profile | `plugins/rafi/stacks/frameworks/<name>.md` or `.../databases/<name>.md` |
| How a command behaves | `plugins/rafi/skills/<name>/SKILL.md` |
| An audit standard | The section file in `plugins/rafi/skills/<audit>/references/` |
| A hook | `plugins/rafi/scripts/*.sh` or `plugins/rafi/hooks/hooks.json` |
| An agent | `plugins/rafi/agents/<name>.md` |

### 8.3 Raise the version (don't skip this)
Change `version` in **both** files, to the **same** number:
- `plugins/rafi/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

Claude Code keeps every installed copy on its current version until the number changes. **Without a bump, no computer receives your edit.**

| Change | Bump | Example |
|---|---|---|
| A typo or small fix | Patch | `1.4.0` → `1.4.1` |
| A new option, capability, profile, command, or standard section | Minor | `1.4.0` → `1.5.0` (our Tabler example) |
| Something that changes how existing commands behave | Major | `1.4.0` → `2.0.0` |

### 8.4 Check the files are valid
```bash
claude plugin validate .
claude plugin validate ./plugins/rafi
```
**Success looks like** `✔ Validation passed` for both.

### 8.5 Test before you rely on it
Install from your local folder instead of GitHub, so you can try the change before pushing:
```bash
claude plugin marketplace add /full/path/to/claude-plugins
```
Then, in a throwaway copy of the template, run the command that uses your change (for the example: `/rafi:add-capability icons tabler`).

### 8.6 Publish
```bash
git add plugins/rafi/stacks/capabilities/icons.md .claude-plugin/marketplace.json plugins/rafi/.claude-plugin/plugin.json
git commit -m "feat(icons): add tabler option"
git push
```

### 8.7 Update every computer
```bash
claude plugin marketplace update rafi-tools
claude plugin update rafi@rafi-tools
```
Restart Claude Code.

### 8.8 Roll back a bad release
`git revert` the bad commit, raise the version **again** (for example `1.5.0` → `1.5.1`), then repeat 8.6 and 8.7. Moving forward to a higher number is safer than going back to an old one.

## 9. Repo layout

```
claude-plugins/
├── README.md                     this manual
├── .claude-plugin/
│   └── marketplace.json          the catalog: lists the plugin and its version
└── plugins/
    └── rafi/
        ├── .claude-plugin/
        │   └── plugin.json       the plugin's name and version
        ├── skills/               one folder per command, each with a SKILL.md
        │   ├── brainstorm/  bootstrap-project/  add-stack/  add-capability/
        │   ├── spec/  plan-feature/  slice/  fix-issue/  release-check/  retro/
        │   └── security-audit/  seo-audit/  performance-audit/
        │       accessibility-audit/  code-review/     (each has references/)
        ├── agents/               code-reviewer, security-auditor, test-writer
        ├── hooks/hooks.json      when the hooks run
        ├── scripts/              format-file.sh, verify-on-stop.sh
        └── stacks/
            ├── _template.md             blank framework or database profile
            ├── _capability-template.md  blank capability
            ├── frameworks/       astro, nextjs, react-spa, react-express, wordpress
            ├── databases/        mongodb, postgres
            └── capabilities/     styling, ui-components, icons, fonts, cms, search,
                                  forms, auth, email, analytics, payments
```

## 10. Design decisions

**Why a private plugin instead of public community plugins?**
- **Trust.** Hooks run shell commands on every edit and every reply. Installing someone else's plugin means running their scripts on your machine; this one is fully readable because you wrote it.
- **Fit.** The standards, commit style, and catalog encode *your* choices. A general-purpose plugin would need constant overriding.
- **Control.** You decide when versions change, and `git revert` is your rollback. A public plugin can change, be renamed, or be abandoned under you.
- **Cost.** Workflow commands are manual-only, so they use none of Claude's memory until typed. Large public collections often load far more.
- **It improves itself.** `/rafi:retro` turns your corrections into rules, and useful ones flow back into this repo.
- **The trade-off:** a public plugin gets many contributors and faster coverage of new tools. Here, coverage grows only as fast as you (or `/rafi:add-stack` and `/rafi:add-capability`) grow it.

**Other decisions:**
- **A generic core with a swappable technology layer.** The standards don't mention any framework. Everything technology-specific lives in `stacks/`.
- **Frameworks, databases, and capabilities are separate**, so a new database or library never means rewriting a framework profile.
- **A curated catalog, not an exhaustive one.** A few vetted options per concern, with status, compatibility, and a default: a paved road plus a tech radar. It grows through `/rafi:add-capability`.
- **Verify at use time.** Bootstrap and add-capability check the current official docs for the options you pick, because any written catalog goes stale.
- **Our own brainstorm, not Superpowers'.** It reads this catalog and writes a file that bootstrap reads, and it's manual-only like the other workflow commands.
- **Standards are split by section**, so an audit loads only what a change needs.
- **Audits only report.** Changes happen in a slice or a fix, where tests and review surround them.
- **Findings logs live in each project**, never in this repo.
- **Claude never commits.** Commands end with a suggested commit message; git stays in your hands.
- **The hooks default to Node and pnpm but read two optional files**, so other languages work without editing the plugin.
- **Nothing needs GitHub settings**, secrets, Actions, or paid features.

## 11. Troubleshooting

| Symptom | Fix |
|---|---|
| `/rafi:` shows nothing | Run `claude plugin list`. If `rafi` is missing, repeat the install (section 2) and restart Claude Code |
| "marketplace not found" or a git error while adding it | Git isn't logged in to GitHub. Set up an SSH key or a token, then retry |
| You edited the plugin and nothing changed | The version wasn't raised in both files (8.3), the update commands weren't run (8.7), or Claude Code wasn't restarted |
| `claude plugin validate` reports an error | Read the message. Usual causes: invalid JSON, a missing file, or a `name` in `plugin.json` that doesn't match the marketplace entry |
| An audit reads the wrong sections | Fix the mapping table at the top of that audit's `SKILL.md` |
| Bootstrap doesn't offer a profile or library you added | The file must be in `stacks/frameworks/`, `stacks/databases/`, or `stacks/capabilities/` (options need a row in the `## Options` table), and the version must be raised and updated |
| Bootstrap never proposes an option | Check its status (hold is never proposed) and its "works with" (it must list your framework or `any`) |
| The type check keeps stopping Claude | Fix the error it reports, or point `.claude/typecheck-cmd` at a command that passes |
| Hooks print `jq: command not found` | Install `jq` (`sudo dnf install jq`) |
| The formatter does nothing | The project has neither Prettier nor `.claude/format-cmd`. Add one |

## 12. FAQ

**Do I need this repo on every computer?** No. Only the install commands in section 2. Clone the repo only where you edit the plugin.

**Does it work without the template?** Yes, in any repo. Without the template you won't have `CLAUDE.md`, the rules, the guard rails, the commit checks, or the docs folders. See the template README, section 13.

**Can I use only some commands?** Yes. Each works on its own. `/rafi:code-review` and the four audits need nothing else.

**Is my code sent anywhere?** The plugin runs inside Claude Code on your computer like any other session. It adds no services of its own. Libraries you choose (a CMS, analytics, a form service) have their own privacy terms.

**Can other people use it?** Anyone you give access to the private repo can install it the same way.

**How much of Claude's memory does it use?** Workflow commands: none until typed. Audit and review descriptions are always loaded but short. The catalog is read only by brainstorm, bootstrap, and add-capability, and then only the summaries. `claude plugin details rafi` shows the estimate.

**Why doesn't the catalog list library X?** It's curated on purpose. Add it with `/rafi:add-capability <concern> X`.

## 13. Known caveats

- The manifests pass `claude plugin validate`, the capability files pass a structural check, and a dry-run project (Astro 7, Tailwind 4, astro-icon, the Astro Fonts API, Pagefind) built cleanly. The interactive commands haven't yet been run end to end in a long real project, so watch them in early use.
- As of September 2026, `astro check` refuses TypeScript 7, so the Astro profile pins `typescript@^6`. Recheck when Astro updates.
- Library facts (free-tier limits, versions) change. The catalog avoids hard numbers, and bootstrap re-checks the docs for what you pick, but re-verify prices before committing to a paid service.
- Some standards use Postgres-flavored examples (for example `EXPLAIN` in performance). The database profiles give the exact commands for MongoDB and Postgres.
- The hooks need `jq`, and their default paths need `pnpm`.
