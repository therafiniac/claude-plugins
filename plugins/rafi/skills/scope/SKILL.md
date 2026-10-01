---
name: scope
description: Write or refresh the project's two scopes of work. A short plain-language scope for the client, and a detailed work scope I use to estimate the budget myself. Both show progress. Safe to run at any stage.
argument-hint: "[agreed]"
disable-model-invocation: true
---
Argument: $ARGUMENTS

Two files, written from the project's docs and code:
- `docs/scope/client-scope.md`: for the client. Short, very plain language, no depth.
- `docs/scope/work-scope.md`: for me. Every piece of work in full detail, so I can estimate the budget by hand.

Both files live in the repo and anyone with access may read them. Never write hours, rates, prices, margins, or opinions about the client in either file.

Write no code and do not edit any other doc.

1. Read `docs/brainstorm.md`, `docs/stack-profile.md`, `docs/architecture.md`, the specs in `docs/prd/`, `docs/discussions/`, `docs/adr/`, and both scope files if they exist. If neither `docs/brainstorm.md` nor `docs/stack-profile.md` exists, tell me to run `/rafi:brainstorm` first, and stop.

2. First run (no `docs/scope/client-scope.md` yet): ask, at most four questions per message, only what the docs do not answer:
   - the client's name and the project name to show them
   - what the client provides (content, photos, logins, domain, approvals) and by when
   - deadline or launch date, and any milestone dates
   - revision rounds included, and how sign-off works
   Never invent a date, a count, or a requirement.

3. Work out progress for each item. Use the spec's acceptance criteria, the code, the tests, and `git log`:
   - **Done**: built, and a test covers it.
   - **In progress**: some of it is built.
   - **Not started**: nothing built.
   When unsure, choose the lower status. Never call something done without code and a test to point at.

4. Write `docs/scope/client-scope.md`, under 50 lines. Write for someone who has never built a website: short sentences, everyday words, no technical terms at all. Say "people can send you a message from the site", not "a contact form with spam protection". Sections:
   - Status line: `Draft` or `Agreed on <YYYY-MM-DD>`, and `Last updated: <YYYY-MM-DD>`
   - What we are building (two sentences)
   - What you get: one short line per deliverable, as what the client or their visitors can do
   - Not included
   - What we need from you, with dates
   - Key dates
   - Changes and sign-off: revision rounds, and how the client approves the work
   - Paid services you will need (hosting, domain, any paid service), by name only
   - Progress: each deliverable with Done / In progress / Not started, and one line such as "6 of 10 done"
   - Changes since agreement (only once agreed): items added or changed after the agreed date

5. Write `docs/scope/work-scope.md`, as long as the detail needs. Technical terms are fine. Every deliverable from the client scope appears here with the same name, broken down fully. Sections:
   - Status line, as in the client scope
   - Size summary: counts I estimate from (pages or screens, content types, forms, user roles, integrations, paid services, languages, E2E flows)
   - For each deliverable, a subsection with a status and, where they apply:
     - pages or screens, with what each shows
     - user flows, step by step, including errors and empty states
     - data: content types or entities, fields, who creates and edits them
     - components to build
     - integrations and third-party services, with the plan or tier from the stack profile
     - content to enter or migrate, and who provides it
     - roles and permissions
     - edge cases from the spec's acceptance criteria
     - tests: unit, E2E flows
     - audits it triggers (Audit triggers table in `CLAUDE.md`)
     - open questions that could change its size
   - Project-wide work clients forget: repo and environment setup, CI, hosting and domain, analytics, SEO setup, accessibility pass, `/rafi:release-check`, launch, redirects, backups, handover and training, revision rounds, post-launch support
   - Client dependencies: each item the client provides, its date, and what it blocks
   - Assumptions: what this scope takes as given; if one is wrong, the scope changes
   - Unknowns and risks: what could grow, and why
   - Out of scope: in technical terms, matching "Not included" in the client scope
   - Changes since agreement: each new or changed item, with its full breakdown
   - Baseline (only once agreed): the list of deliverables as agreed

6. Before writing on the first run, show both drafts and wait for my changes. On later runs, write, then show only what changed: status moves, new items, new open questions.

7. Agreement:
   - If the argument is `agreed`, set both status lines to `Agreed on <today>` and write the Baseline section in `docs/scope/work-scope.md`. Never change the baseline afterwards.
   - Once agreed, a deliverable that is not in the baseline goes under "Changes since agreement" in both files, never into "What you get". Flag it to me in one line, because it needs pricing before work starts.

8. Last line: `Next:` plus one step:
   - draft, not yet agreed → estimate from `docs/scope/work-scope.md`, share `docs/scope/client-scope.md` with the client, then `/rafi:scope agreed` once they accept
   - new items since agreement → price them for the client before building
   - agreed, items not started → `/rafi:spec <next deliverable>` if it has no spec, else `/rafi:plan-feature <next deliverable>`
   - everything done → `/rafi:release-check`
   It is only a suggestion. Never run it.
