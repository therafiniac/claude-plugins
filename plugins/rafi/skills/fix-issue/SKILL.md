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
6. Report: root cause, fix, test added. End with the commit message only, `fix(scope): subject`, no explanation around it. Do not commit unless I say so.
