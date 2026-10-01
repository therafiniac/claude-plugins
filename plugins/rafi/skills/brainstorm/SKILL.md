---
name: brainstorm
description: Turn a rough idea into a clear spec and a chosen stack before bootstrapping. Writes docs/brainstorm.md.
argument-hint: <idea in a few words>
disable-model-invocation: true
---
Idea: $ARGUMENTS

Run this in the new project folder (a fresh copy of the template). Write no code, scaffold nothing, install nothing.

0. If `docs/stack-profile.md` exists, the project is already bootstrapped. Do not continue and do not touch `docs/brainstorm.md`. Tell me to use `/rafi:discuss <topic>` for ideas in an existing project, and stop. If only `docs/brainstorm.md` exists, show its path and ask whether to replace it or stop.

1. Understand the idea. Ask at most four questions per message and wait for answers. Cover, over as many rounds as needed:
   - who uses it, and the problem it solves for them
   - the 3 to 5 core flows or pages
   - what is out of scope for the first version
   - content: who edits it, how often, and whether they are technical
   - data: user accounts, payments, user-generated content, personal data
   - constraints: budget for hosting and services, hosting preference, deadline, expected traffic, languages
   - what exists already: domain, brand, design, content, accounts
   Stop asking once you could write testable acceptance criteria. Do not ask what the answers already imply.
2. Propose 2 or 3 approaches (for example a static content site versus a full app with a database). For each: effort, running cost, what it makes easy, what it makes hard. Recommend one. Wait for my pick.
3. Build the stack for the chosen approach from the catalog in `${CLAUDE_PLUGIN_ROOT}/stacks/`:
   - framework from `frameworks/`, database from `databases/` (or none), hosting, auth
   - capabilities: read only the summary (everything above the first `## Option:` heading) of each file in `capabilities/`. Skip concerns whose "Ask when" does not fit. Propose the "Default", filtered by "Works with". Never propose `hold`.
   - concerns the idea needs that the catalog lacks: list them as "not in catalog" with a suggested option, and note `/rafi:add-stack` or `/rafi:add-capability` to create them
   Show one table, `Concern | Proposed | Alternatives | Why`, and wait for my confirmation or changes.
4. Write `docs/brainstorm.md`, under 80 lines:
   - Idea (two sentences), Users, Core flows, Non-goals
   - Draft acceptance criteria (Given / When / Then), marked as a draft
   - Chosen approach and why, rejected approaches and why
   - Stack table: `Concern | Choice | Alternatives considered`, including "not in catalog" rows
   - Open questions
5. Last line: `Next:` `/rafi:bootstrap-project <idea>`, which reads `docs/brainstorm.md`. If there are "not in catalog" rows, the next step is `/rafi:add-stack` or `/rafi:add-capability` for them first. It is only a suggestion. Never run it.
