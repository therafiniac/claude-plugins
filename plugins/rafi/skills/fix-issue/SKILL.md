---
name: fix-issue
description: Fix a bug test-first with a minimal change.
argument-hint: <issue description or number>
disable-model-invocation: true
---
Issue: $ARGUMENTS

1. Reproduce: write a failing test that captures the bug. If it cannot be reproduced in a test, explain why and stop.
2. Find the root cause and state it in one sentence. Do not patch symptoms.
3. Make the minimal fix. No unrelated refactors.
4. `pnpm check` must pass.
5. If the root cause is a security or data-integrity issue, run the `rafi:security-auditor` subagent on the affected path.
6. Report: root cause, fix, test added. Then commit following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` (`fix(scope): subject`, no attribution, then push) and give the commit header. On `main` or `dev`, that file first creates a `fix/<name>` branch from `dev`; for a production emergency use `/rafi:hotfix` instead.
7. Last line: `Next:` plus one step. Usually: `/rafi:merge` if this branch is only the fix, else continue where I was (for example the next slice of the current plan). If the bug showed a gap that will recur (a missing rule or check): `/rafi:retro` at the end of the session. It is only a suggestion. Never run it.
