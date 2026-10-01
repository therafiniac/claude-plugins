---
name: add-stack
description: Create a new stack profile (a framework or a database) by interviewing me and researching the current official docs.
argument-hint: <name, e.g. "SvelteKit", "Django", "MySQL">
disable-model-invocation: true
---
New stack: $ARGUMENTS

1. Ask me in one message and wait for answers:
   - kind: framework or database
   - language, runtime, and exact versions
   - package manager, test runner, linter, formatter
   - how it will be deployed
   - for a framework: which databases it will pair with
2. Research. Use web search and fetch to read the official documentation for those exact versions. Verify every claim you plan to write. Do not rely on memory for version-specific behavior. Keep the documentation URLs.
3. Read `${CLAUDE_PLUGIN_ROOT}/stacks/_template.md`, and one existing profile of the same kind in `${CLAUDE_PLUGIN_ROOT}/stacks/frameworks/` or `.../databases/`, for structure, depth, and tone.
4. Draft the profile following the template. Map the standard scripts (`dev`, `build`, `typecheck`, `lint`, `test`, `check`, `test:e2e`) to this stack's real commands. Every rule must be specific and checkable. Fill the Sources section with the URLs you used.
5. If the stack is not Node and pnpm, fill the Adaptation notes completely: list every template file that must change, and propose the contents of `.claude/typecheck-cmd` and `.claude/format-cmd` (first line is the command).
6. Show me the draft. Wait for my approval or edits. Then save it to `docs/stack-drafts/<kind>-<name>.md` in this project.
7. End with `Next:` and these two options (only suggestions; never run them):
   - To use it now, run `/rafi:bootstrap-project` and give the draft path when it asks for the framework or database.
   - To keep it for every project, copy the file into my local clone of the plugin repo at `plugins/rafi/stacks/frameworks/` or `plugins/rafi/stacks/databases/`, raise the version in `plugin.json` and `marketplace.json`, and push.
