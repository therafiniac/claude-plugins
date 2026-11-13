---
name: daily
description: Run my daily routine in The Brain (Rafi's Notion system) - morning planning (habits page, today and overdue tasks, pick three) or evening close-out (tick habits, close tasks, reschedule, optional journal). Use when I say "plan my day", "morning", "what's on today", "end my day", "evening review", or "wrap up".
argument-hint: "[morning | evening] (default: by time of day)"
---
Mode: $ARGUMENTS

Read first: `${CLAUDE_PLUGIN_ROOT}/references/notion.md`, `${CLAUDE_PLUGIN_ROOT}/references/databases.md`, `${CLAUDE_PLUGIN_ROOT}/references/conventions.md`.

Mode: `morning` or `evening` from the argument; if none, before 15:00 local time → morning, after → evening.

## Morning (target: one short screen)
1. **Habits.** Ensure today's Habits page exists (title `YYYY-MM-DD`, linked like yesterday's page); create it if missing.
2. **Tasks.** Query Tasks: not archived, `Status` not Done, `Task Date` ≤ today. Split into Overdue and Today. Also show DOING tasks with no date.
3. **Business pulse.** Interactions / Leads / CRM with a follow-up date today or overdue; Transactions Pending with `Due Date` ≤ today. Skip the section if empty.
4. **Pick three.** Suggest at most 3 tasks: P1 then P2, overdue first, mixing in Energy (one High, the rest Medium/Low). Show them as a numbered list with Priority, Energy, project.
5. Ask one question: "Set these to DOING?" On yes, set them DOING. On changes, apply mine instead.

## Evening
1. **Habits.** Ask which habits I did today (list the checkbox names from the schema), unless I already said. Tick them.
2. **Tasks.** List today's DOING and TO DO tasks. Ask which are done. Mark them Done. For the rest, ask once: move to tomorrow (default), another date, or leave. Apply.
3. **Captures.** If I mention anything new (thought, task, payment, call), route it through `${CLAUDE_PLUGIN_ROOT}/skills/capture/SKILL.md` or `${CLAUDE_PLUGIN_ROOT}/skills/client/SKILL.md`.
4. **Journal (optional).** Ask "Journal today?" On yes, create `Daily – YYYY-MM-DD` from the Daily template with my Mood, Energy, Grateful for, and reflection.

## Reply
Morning: the plan and the one question. Evening: counts (done, moved, habits %) in one or two lines. No recap.
