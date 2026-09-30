# <Name> profile
Kind: framework | database
Verified against: <name and exact version>, <date>. Sources: <official documentation URLs>.

Notes for whoever fills this in:
- A **framework** profile covers the app layer (routing, rendering, folders, tooling, SEO, accessibility). A **database** profile covers data storage (client, migrations, queries, tests). Keep them separate so any framework can pair with any database.
- Every rule must be specific and checkable. Prefer "every server action checks ownership" over "be secure".
- Verify version-specific claims in the official docs before writing them.
- Library choices for cross-cutting concerns (styling, icons, CMS, search, and so on) do not belong here. They are capabilities: see `_capability-template.md`.

## Stack
<What this profile assumes: language and runtime, key libraries, default hosting.>

## Scaffold contract
<Frameworks: folder layout, layering, env module, health endpoint, test tooling, E2E config, and how the standard scripts map to this stack: `dev`, `build`, `typecheck`, `lint`, `test`, `check`, `test:e2e`.>
<Databases: client or ORM, connection module, env variable, migrations, seed, test database, and the local container command for tests.>

## Conventions
<Rules Claude must follow when writing code for this stack.>

## Security checks (added to security-audit)
<Stack-specific checks, each pointing at the standard's section number where it applies.>

## SEO checks (frameworks only, added to seo-audit)

## Performance checks (added to performance-audit)

## Accessibility checks (frameworks only, added to accessibility-audit)

## Adaptation notes (only for a new language or toolchain)
The project template assumes Node and pnpm. For anything else, list the changes:
- `.claude/typecheck-cmd`: first line is the fast static check the Stop hook runs (for example `mypy .`).
- `.claude/format-cmd`: first line is the formatter; the edited file path is appended (for example `ruff format`).
- `.claude/settings.json`: replace the `pnpm` entries in the allow list with this stack's commands.
- `.husky/` and `.lintstagedrc.json`: replace the linters or drop lint-staged.

## Sources
<Documentation URLs consulted.>
