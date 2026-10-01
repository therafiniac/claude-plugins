---
name: plan-feature
description: Explore and plan a feature. No code until approved.
argument-hint: <feature name or docs/prd file>
disable-model-invocation: true
---
Feature: $ARGUMENTS

1. Read `docs/prd/`, `docs/architecture.md`, `docs/stack-profile.md`, and the code this feature touches. Do not write code.
2. If there is no spec for this feature in `docs/prd/`, tell me to run `/rafi:spec <feature>` first, and stop. If acceptance criteria are missing or not testable, ask me. Do not invent them.
3. Produce a plan:
   - Slices in dependency order. Each is a vertical slice (schema → service → route or action → tests → UI).
   - Files per slice, data model changes, API contract.
   - Test cases per slice: happy path, invalid input, unauthorized, not-found, boundaries.
   - Risks, and which audits each slice triggers (see the Audit triggers table in CLAUDE.md).
4. Stop and wait for my approval. Do not create files.
