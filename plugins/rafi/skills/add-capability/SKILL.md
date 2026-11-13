---
name: add-capability
description: Add a capability (icons, CMS, search, and so on) to this project, or research a new capability or option into a draft.
argument-hint: <concern, optionally with an option, e.g. "search", "cms keystatic", "payments">
disable-model-invocation: true
---
Request: $ARGUMENTS

Catalog: `${CLAUDE_PLUGIN_ROOT}/stacks/capabilities/`. A capability file's **summary** is everything above its first `## Option:` heading.

Pick the mode:
- **Add**: the concern has a catalog file, the option I named (if any) is in it, and the project has `docs/stack-profile.md`.
- **Draft**: the concern or the option I named is not in the catalog.

## Add
1. Read `docs/stack-profile.md` (framework, database, capabilities already chosen) and the concern's summary. If the concern is already in the Stack table, say so and ask whether I want to replace the current option.
2. Propose the option: my named option, or the "Default" for this framework, filtered by "Works with". List the other fitting `adopt` and `trial` options as alternatives. Never propose `hold`. Wait for my choice.
3. Read only the chosen `## Option:` section and the file's `## Shared` section if it has one. Check its install steps and version constraints against the current official docs (web search and fetch). Propose a plan: dependencies with a reason each, files, config, and scripts. **Stop and wait for my approval.**
4. Implement it, following the option's conventions. Run `pnpm check` and `pnpm build`. Fix failures.
5. Update `docs/stack-profile.md`: add or replace the row in the Stack table, and append `# Capability: <concern> (<option>)` followed by the option's section and the file's `## Shared` section if it has one. Write `docs/adr/NNN-<concern>.md` (next free number) with the choice and the alternatives considered.
6. Report in five lines or fewer. Then commit following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` and give the commit header.
7. Last line: `Next:` `/rafi:merge` if this branch is only the capability, else continue what I was doing (for example `/rafi:spec <feature>` if this capability was added for a new feature). It is only a suggestion. Never run it.

## Draft
1. Ask me in one message and wait for answers:
   - the concern, and the option or options to cover
   - which framework and database profiles it must work with
   - hosted or self-hosted, and budget
   - anything already decided (existing accounts, vendor lock-in limits)
2. Research. Read the official documentation for current versions with web search and fetch. Verify every claim you plan to write. Keep the URLs.
3. Read `${CLAUDE_PLUGIN_ROOT}/stacks/_capability-template.md` and one existing capability file for structure, depth, and tone.
4. Draft in the template's format: a full capability file for a new concern, or a new options-table row plus `## Option:` section for an existing concern. Give each option a status (`adopt`, `trial`, or `hold`) with a reason. Every rule must be specific and checkable. Audit checks point at section numbers.
5. Show me the draft and wait for approval or edits. Save it to `docs/stack-drafts/capability-<concern>.md`.
6. End with `Next:` and these two options (only suggestions; never run them):
   - To use it in this project now, tell me and continue with the Add steps, reading the option from the draft.
   - To keep it for every project, copy it into my local clone of the plugin repo at `plugins/rafi/stacks/capabilities/` (merge into the existing file for an existing concern), raise the version in `plugin.json` and `marketplace.json`, and push.
