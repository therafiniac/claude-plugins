---
name: capture
description: Add, update, find, or archive anything personal in The Brain (Rafi's Notion system) - tasks, notes, ideas, resources, assets, projects, goals, books, courses, habits, journal entries, people, prompts, and trips. Use whenever I say "add", "note this", "remind me", "log", "mark done", "move", "archive", "what's on", or "find" for my life or learning. Client, lead, payment, and work-log requests go to the client skill.
argument-hint: "<what to add, change, or find, in plain words>"
---
Request: $ARGUMENTS

Read first, and follow throughout:
- `${CLAUDE_PLUGIN_ROOT}/references/notion.md` (write protocol)
- `${CLAUDE_PLUGIN_ROOT}/references/databases.md` (IDs)
- `${CLAUDE_PLUGIN_ROOT}/references/conventions.md` (routing, statuses, titles, defaults)

If the request is about a lead, client, CRM, interaction, discovery, proposal, project log, transaction, invoice, deliverable, or client website, follow `${CLAUDE_PLUGIN_ROOT}/skills/client/SKILL.md` instead. A request can hold several items ("add a task to call the bank and a note about X"): handle each.

## 1. Classify
Decide the intent (add, update, find, archive) and the database from the routing table. Ask one question only when the database or a required link is truly ambiguous; otherwise apply the defaults and state them in the reply.

## 2. Act by database

**Tasks.** Title verb-first. Set `Type`, `Status`, `Priority`, `Energy`, `Task Date` if given, `Description` for extra detail. Link `Projects`, `Goals` or `Life Area`. Subtasks → `Parent item`. Trip prep → `Pre Trip Task` template and link `Trips - MD`.
- "Done" / "finished" → `Status` Done (Completion Date fills itself). "Start" → DOING. "Move to Friday" → `Task Date`.

**Notes.** Title `Topic – detail`. Put the content in the page body. Link whatever applies: `Discipline`, `Project`, `Goals`, `Life Area`, `Courses`, `Trips`, Library entry. Unclear links → leave unlinked for Sunday and say so.

**Ideas.** `Status` Exploring unless I say otherwise; link `Discipline`, `Life Areas`. "Make it a project" / "promote" → create the Project (step below), link it to the Idea's `Project` relation, set the Idea to `Developing`.

**Projects (Personal).** Use the Personal template. Set `Type` Personal, `Project Status` (Not started if dates given, else Planned), `Start Date`, `End Date`, `Life Areas`, `Goals`. Offer to add the first tasks. Suggest the Drive folder `01_Personal/01_Projects/YYYY-MM_Name`. Professional projects → client skill.
- "Project done" → `Project Status` Done; ask before archiving if any task is not Done.

**Goals.** Set `Life Area`, `Year`, `Start Quarter`, `Start Date`, `End date`, `Goal Status` Get Ready. If `Year` lacks the year needed, say the option must be added in Notion (never change the schema). Offer 2–4 milestone Projects, linked via `Projects/Milestones`, and an optional reward in Goals Rewards.

**Resources / Assets.** Resource = collected, Asset = made by me. Set `Type` / `Category`, `link`, `Discipline`, `Life Area`, `Project`. A bare link with no Discipline or Project → suggest Raindrop instead, and add it only if I insist.

**Library.** Check for the book first. Set `Collection`, `Consume Method`, `Reading Status` To Consume, `Author`, `Genres`, `Language`, `Recommended By`, `Discplines`. "Started" → In Progress + `Start Date`. "Finished" → Finished + `Date Finished` + `Rating` (ask for the rating if not given). Summaries, takeaways, quotes go into the page sections from the template.

**Courses.** Title is `Book Name`. Set `Platform / Institute`, `Instructor`, `Genre`, `Medium`, `Status`, `URL`, Disciplines. Lesson notes → Notes linked to the course.

**Habits.** Today's page title is today's date. If it does not exist, create it. Tick the checkboxes I name (SunRise, Reading 45Min, Meditation, Workout, or whatever the schema has). Link it to the All time Progress page that existing Habits pages use (copy the relation from yesterday's page).

**Journaling.** Pick the template by cadence (Daily by default). Title per conventions. Set `Mood`, `Energy`, `Grateful for` from what I said; write the reflection in the body in my words, lightly cleaned up, not rewritten.

**People.** Check for duplicates. Set `Connection type`, `Tags`, `Status` Active, contact fields. "Talked to X today" → `Last Contact Date`. Clients belong in CRM, not here.

**Prompt.** Title = what it does. Set `AI`, `Category`, `Output Format`, `Level`, `Spaces`; prompt text in the body.

**Travel.** Trip title `YYYY-MM Place`. Itinerary items: `Category`, `Day`, cost and date, linked to the Trip; create or link the matching Places / Food / Accommodations / Transport page; geographic regions go to the *Travel* Areas database. Packing: never duplicate the reusable Packing List; filter it by `Travel Type` and `Climate` and report what is not `Packed`.

## 3. Find and status questions
"What's due today", "show my active projects", "what am I reading": query with filters (non-archived, matching `Type`), return a compact list: title, status, date, link. At most 15 rows; say how many more exist.

## 4. Archive
"Archive / delete / drop X" → find it, set `Archived` to `__YES__`. Never delete.

## 5. Reply
Per `notion.md` Reporting. End with nothing else.
