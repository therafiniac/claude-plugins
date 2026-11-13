---
name: review
description: Run a weekly (Sunday), monthly (1st Sunday), or yearly (December) review of The Brain (Rafi's Notion system), covering both personal life and the freelance business - inboxes, orphan items, projects, overdue tasks, ideas, goals, habits, learning, leads, follow-ups, payments, and renewals. Use when I say "Sunday review", "weekly review", "monthly review", "year review", or "review my system".
argument-hint: "[weekly | monthly | yearly] [personal | business] (default: weekly, both)"
---
Args: $ARGUMENTS

Read first: `${CLAUDE_PLUGIN_ROOT}/references/notion.md`, `${CLAUDE_PLUGIN_ROOT}/references/databases.md`, `${CLAUDE_PLUGIN_ROOT}/references/conventions.md`.

Cadence: weekly (default), monthly, or yearly. Scope: personal, business, or both (default). Monthly includes weekly; yearly includes monthly.

How to run it: gather everything for a section with read-only queries, present it as a compact list, propose concrete fixes, and apply them only after my yes (one confirmation per section, not per item). Skip empty sections silently. Never archive or change status in bulk without the confirmation.

## Weekly — personal
1. **Inbox.** Notes, Ideas, Tasks, Resources with no Area / Project / Discipline / Goal link (not archived). For each, propose the link. Remind me to clear Drive `00_Inbox`, `03_Quick_Share` and Raindrop unsorted (outside Notion).
2. **Projects.** Personal projects In progress / Not started / Waiting for feedback: name, status, Progress, Days Left. Flag past `End Date`. Propose: done → Done + archive; stalled → Hold or new date.
3. **Tasks.** Overdue tasks not Done → propose new dates or archive. Done tasks older than 7 days not archived → propose archiving.
4. **Ideas.** Ideas Developing, or Exploring for 30+ days → propose promote to Project, keep, or On Hold.
5. **Needs Review.** Notes / Ideas / Resources / Assets where `Need Review` is true → list; on review, set `Reviewed Status`.
6. **Plan.** Ask for 3–5 outcomes for next week; create them as dated Tasks with Type and links.

## Weekly — business
1. **Follow-ups.** Due in the next 7 days or overdue (Interactions, Leads, CRM) → propose Tasks.
2. **Stuck leads.** Open leads (not Close Won / Close Lost) with no Interaction for 14+ days → follow up once or Close Lost.
3. **Payments.** Transactions Pending / Partially Paid, overdue first, with amounts and client → offer a reminder Task each.
4. **Waiting.** Professional projects in Waiting for feedback for 7+ days → nudge Task.
5. **Health.** Active CRM clients: propose a `Health Score` change where interactions or payments suggest one.

## Monthly additions (1st Sunday)
- **Goals.** Each active Goal: Progress, Days Left; propose `Goal Status` updates. Each Area: Goals Progress / Achieved Goals.
- **Habits.** All time Progress for the month; name the weakest habit and ask whether to adjust it.
- **Learning.** Library and Courses In Progress with no activity in 30 days → continue, Hold, or Abandoned.
- **Money.** This month: received vs pending (sum Transactions by `Received Date` / `Due Date`), revenue per client, lead sources of Close Won leads. One SQL aggregate query at most.
- **Services.** Ask if any pricing changed; update only on my answer.
- **Renewals.** Website pages: list domain/hosting statuses; remind me that expiry dates are not tracked (open item).
- **Files.** Remind: invoices to Drive `01_Freelancing/02_Areas/Contracts_Invoices`, sort `Photography/Unsorted`.

## Yearly additions (December)
- Close the year's Goals: You did it, or carry over / archive.
- Check `Goals → Year` has next year's option; if not, tell me to add it in Notion.
- Ask for 3–5 new Goals and create them via `${CLAUDE_PLUGIN_ROOT}/skills/capture/SKILL.md`.
- Archive Done projects of the year; remind me to move their Drive folders to `99_Archive/YYYY`.
- Year numbers: projects done, goals achieved, books finished, courses completed, revenue received.
- Remind me to re-read the Operating Manual and delete dead steps.

## Reply
One compact block per section with the proposed fixes, then a single question. After applying: one line per section with counts. No recap.
