---
name: migration
description: Plan and write a safe database schema or data migration (expand, backfill, contract) with rollback and tests.
argument-hint: <the schema or data change, e.g. "rename users.name to full_name">
disable-model-invocation: true
---
Change: $ARGUMENTS

Production data is the one thing a redeploy cannot restore. Every migration must be safe to run while the previous version of the app is still serving traffic.

1. Read `docs/stack-profile.md` (its database section, including `## Migration checks`), `docs/architecture.md` (Data model), the existing migrations, and the code that reads or writes the affected data. If `docs/stack-profile.md` does not exist, or names no database, say so in one line and stop: do not classify, plan, or write anything, and do not ask follow-up questions. Suggest `/rafi:bootstrap-project` (no profile) or `/rafi:add-stack` (a database the catalog lacks).
2. Classify the change and state it in one line:
   - **Additive**: new table or collection, new nullable column or optional field, new index. One step.
   - **Breaking**: rename, type change, new required field, split or merge, drop. Needs expand → backfill → contract across separate deploys.
   - **Data only**: rewrite existing values. Needs a backfill script.
3. Check the risks against the database's `## Migration checks` in the stack profile: locks and table rewrites, index builds on large tables, long transactions, constraint validation, data volume. Ask me for row or document counts of the affected tables if the size matters and you cannot see it.
4. Propose the plan and **wait for my approval**:
   - Phases, each one deployable on its own:
     1. **Expand**: add the new shape. Old and new app versions both work.
     2. **Dual-write or compatibility code** in the app, if readers and writers change.
     3. **Backfill**: batched, idempotent, resumable, with progress logs and no unbounded queries.
     4. **Switch reads** to the new shape.
     5. **Contract**: drop the old shape, in a later release, after the switch is verified in production.
   - Deploy order per phase: does the migration run before or after the app deploy?
   - Rollback per phase: the down migration, or the forward fix if a phase destroys data. Name any step that cannot be undone.
   - Backup: before any destructive phase, confirm a restore point exists (`docs/runbook.md`, Backups). Never skip this for a drop or a type change.
   - Tests (below) and the slices this splits into.
5. After approval, implement only the current phase:
   - Migration files through the profile's tool and scripts (`db:generate`, then edit only what the tool cannot express). Never edit an applied migration.
   - Backfill as a script under `scripts/` with a `--dry-run` flag, batch size, and resume point.
   - Tests: the migration applies to an empty database; it applies to a database seeded with the previous schema's data and preserves it; the backfill is idempotent (running it twice gives the same result); the app's tests pass against the new schema.
6. Run `pnpm check`, then `db:migrate` against the local test database. Fix failures.
7. Update `docs/architecture.md` (Data model) and, for a breaking change, add an ADR from `docs/adr/_template.md`. Add the remaining phases to `docs/runbook.md` under "Pending migrations" with their deploy order, so they are not forgotten.
8. Report in five lines or fewer: phase done, phases left, rollback, risks. Then commit following `${CLAUDE_PLUGIN_ROOT}/skills/commit/SKILL.md` (`feat(db): subject` or `fix(db): subject`) and give the commit header.
9. Last line: `Next:` plus one step. Phases left: `/rafi:merge` and `/rafi:release` to deploy this phase, verify it in production, then `/rafi:migration <same change>` for the next phase. All done: remove the entry from "Pending migrations". It is only a suggestion. Never run it.
