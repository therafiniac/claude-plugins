---
name: discuss
description: Talk through a new idea or change in an existing project, against its current stack and specs. Saves the outcome and suggests the next step.
argument-hint: <topic, e.g. "online class booking" or "switch to a headless CMS">
disable-model-invocation: true
---
Topic: $ARGUMENTS

For projects that already exist. Write no code, scaffold nothing, install nothing, and do not edit existing docs.

1. If `docs/stack-profile.md` does not exist, the project is not bootstrapped yet: tell me to use `/rafi:brainstorm` instead, and stop.
2. Read `docs/stack-profile.md`, `docs/architecture.md`, the specs in `docs/prd/`, the decision records in `docs/adr/`, and earlier files in `docs/discussions/`. Read code only where the topic touches it.
3. Understand the topic. Ask at most four questions per message, in plain language, and wait for answers: what problem it solves and for whom, what must change for the user, constraints (budget, deadline), and how it relates to what already exists. Stop asking once the goal is clear.
4. Propose 2 or 3 approaches that fit the **current** stack. For each: effort, running cost, what it changes in the existing project, and risks. Recommend one and wait for my pick, or for me to say I only wanted to think it through.
5. Check the catalog for what the chosen approach needs. Read only the summary (everything above the first `## Option:` heading) of the relevant files in `${CLAUDE_PLUGIN_ROOT}/stacks/capabilities/`. List new capabilities with a proposed option that fits the current stack ("works with", never `hold`). List anything the catalog lacks as "not in catalog". Flag any change to a choice already in the Stack table, because it needs a decision record.
6. Write `docs/discussions/<YYYY-MM-DD>-<topic-in-kebab-case>.md`, under 60 lines: topic, the problem, approaches considered and the choice (or "no decision"), new or changed capabilities, open questions, and the next step. Never overwrite an earlier discussion file.
7. Last line: `Next:` plus the one step that fits the outcome:
   - a new feature → `/rafi:spec <feature>`
   - a new library the catalog has → `/rafi:add-capability <concern>`
   - something the catalog lacks → `/rafi:add-capability <concern> <library>` or `/rafi:add-stack <name>`
   - a change to an existing stack choice → a decision record in `docs/adr/`, then `/rafi:add-capability <concern>` to switch
   - no decision → nothing to do; the notes are saved
   It is only a suggestion. Never run it.
