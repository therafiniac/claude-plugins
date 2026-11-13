# Notion write protocol

Applies to every read and write any `brain` skill makes. Tools: Notion MCP (`notion-fetch`, `notion-query-data-sources`, `notion-search`, `notion-create-pages`, `notion-update-page`). If they are not loaded, load them with ToolSearch. If the Notion connector is not connected, stop and say so.

## Before writing
1. **Fetch the schema** of each target data source once per session (`notion-fetch` with its `collection://` URL). Use only property names, option names and types from that schema. Names contain typos (`Discplines`, `LinekedIn`, `Negetive`, `Developemnt`, `Summery`); copy them exactly. Never invent an option; if the value I gave fits none, pick the closest and say so, or ask.
2. **Never write** properties of type `formula`, `rollup`, `button`, `created_time`, `last_edited_time`, or anything the schema marks read-only. Never set `Completion Date`, `Overdue`, `Progress`, `Days Left`, `Full Name`, `Received Amount`, `Net Amount`, `Total Time Spent`, or any Discovery recommendation by hand.
3. **Resolve relations** before creating: find the related page (Area, Project, Goal, Discipline, Lead, CRM client, Trip, Person) with a filtered `rows` query on its data source, or `notion-search` scoped by `data_source_url`. Relation values are page URLs. One clear match → link it. Several → ask once, listing them. None → say so; create the related page only if I confirm (Areas and Disciplines: never without asking).
4. **Check for duplicates** on Leads, CRM, People, Projects, Library, Courses, Website: query by title first. If it exists, update it instead and say so.
5. **Templates**: when the schema lists `page_templates` and one fits (Projects: Personal / Professional; Journaling: Daily / Weekly / Monthly / Yearly; Tasks: Pre Trip Task / Packing List), pass its ID as `template_id` and do not send `content`. Otherwise use the database's `default_page_template` if any.

## Formats
- Dates: `date:<Prop>:start` = `YYYY-MM-DD` (add time only when I gave one; then `is_datetime` 1). "today", "tomorrow", "next Monday" resolve against today's date in my timezone (Asia/Kolkata unless I say otherwise).
- Checkboxes `__YES__` / `__NO__`. Numbers as numbers. Currency in ₹ unless I say otherwise (Client Market International → ask).
- Properties named `URL` or `id` are written as `userDefined:URL`.
- Page body: Notion-flavored Markdown; read `notion://docs/notion-flavored-markdown-spec` once before the first write that has body content.

## Queries
- Prefer `rows` mode with structured filters, or `view` mode on an existing view. The workspace is on a plan with a limited SQL quota, so use SQL only for aggregation that rows mode cannot do, and never in a loop.
- Exclude `Archived = __YES__` unless I ask for archived items.
- Filter by `Type` (Personal / Professional) when the context is clear.

## Safety
- **Never delete.** "Delete", "remove", "finished", "drop it" → set `Archived` to `__YES__` and say it is archived.
- **No secrets** in any property or page: passwords, API keys, tokens, OTPs, card numbers, client logins. Tell me they belong in Bitwarden and leave them out.
- Never change a database's schema, views, or templates. If something needs a schema change, say what and stop.
- Bulk changes (more than 5 pages in one go, or any status change across many pages) → list them and wait for my yes.

## Reporting
After writing, reply in at most 3 lines per item: what was created or changed, in which database, its key fields and links, and the page URL. Mention anything skipped and why. No recap.
