---
name: retro
description: End-of-session retrospective. Turns corrections and surprises into proposed CLAUDE.md gotchas, rules, or plugin improvements.
disable-model-invocation: true
---
Review this conversation and the audit logs in `docs/audits/`.

1. Collect: corrections I made, instructions I repeated, failed commands, audit findings that recurred, and surprises that cost time.
2. Classify each as one of:
   - project gotcha → `CLAUDE.md` Gotchas section
   - project rule → `.claude/rules/`
   - mechanical enforcement (hook, lint rule, CI check) → propose the exact config
   - plugin improvement (skill, standard, command, stack profile) → list it for the plugin repo
   - ignore
3. Propose only items that recurred or clearly cost time. Maximum seven. For each: one line of rule text, the target file, and why.
4. Wait for my approval. Then apply the approved project items and commit them following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` (`docs(claude): ...` or `chore(rules): ...`). For plugin items, output a short list I can paste into the plugin repo. Do not edit the plugin.
5. Last line: `Next:` `/rafi:merge`, and if there are plugin items, add them in the plugin repo and raise its version. It is only a suggestion. Never run it.
