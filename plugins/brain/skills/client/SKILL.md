---
name: client
description: Run the freelance business pipeline in The Brain (Rafi's Notion system) - new lead, log a call or message, discovery, proposal, convert lead to client, direct client, project kick-off, project log, deliverable, payment or invoice, client website, and closing a project. Use whenever I mention a lead, prospect, client, CRM, call with a client, follow-up, proposal, advance, payment, invoice, hours worked on a client project, deliverable, or a client site.
argument-hint: "<what happened, e.g. 'new lead Lakshmi Kashi NGO via referral' or 'got 15k advance from X'>"
---
Request: $ARGUMENTS

Read first, and follow throughout:
- `${CLAUDE_PLUGIN_ROOT}/references/notion.md` (write protocol)
- `${CLAUDE_PLUGIN_ROOT}/references/databases.md` (IDs, section 6)
- `${CLAUDE_PLUGIN_ROOT}/references/conventions.md` (titles, statuses)

Identify the stage from the request, then do only that stage's steps. A request can span stages ("call went well, they accepted, 10k advance") → run each in order.

Always resolve the client first: search Leads and CRM by company or person name. Before the sale, the Lead is the record; after, CRM is. Never edit contact details on both.

## Stages

**1. New lead.** Check Leads for a duplicate. Create: title = company (or person), `Company Name`, `First / Mid / Last Name`, `Lead ID` (if it is not auto-generated, query the highest existing `LD###` and use the next), `Entry date` today, `Lead Source`, `Industry`, `Job Title`, `Status` New Lead, contacts (`Whatsapp` is a phone field), socials, `Deal value`, `Probability`, `Expected Closing Date`, `Pain Points` — only what I gave. Link the Service if named. Never write to `Call Notes` / `Post-call Notes`; notes go to Interactions. Offer a follow-up Task (Type Professional).

**2. Interaction (any call, meeting, message, email).** Title `What — Who`. Set `Date` (today default), `Type`, `Channel`, `Outcome`, `Notes`, `Next Action`, `Next Follow-up Date`. Link the Lead and/or CRM client, plus the Project or Discovery if relevant. Then advance the Lead `Status` if the conversation moved it (e.g. first reply → Connected, meeting booked → Meeting Scheduled) and say so. If a follow-up date is set, offer a dated Task.

**3. Discovery.** Title `Discovery — Client`. Tick only the requirements I confirmed; leave the rest empty, never guess yes/no. Link Lead / CRM / Services. After saving, read back `Recommended Platform`, `Recommended Tech Stack`, `Price Band` (formulas) and report them. Lead `Status` → Meeting Scheduled if it was earlier.

**4. Proposal.** Point me to the Proposal Template page; do not write the proposal unless I ask. Log an Interaction (Type Proposal Discussion). Lead `Status` → Proposal Sent, or Negotiation if we are discussing terms.

**5. Won → convert to client.** Lead `Status` Close Won. Create the CRM record: `Client Name`, `Company Name`, `Email`, `Phone`, `City`, `Website` copied from the Lead, `Client Since` today, `Status` Active, `Health Score` 🟢 Healthy, `Sources` Converted Lead, `Preferred Communication`. Link CRM ↔ Lead, and link the Lead's Discovery, Interactions and Services to the CRM record. From now on edit contacts only in CRM. Lost → `Status` Close Lost, log the reason as an Interaction.

**5b. Direct client (no lead).** Create in CRM with `Sources` Direct / Referral / Repeat, `Status` Active; `Leads` stays empty. Continue at stage 6 if there is work.

**6. Kick-off.** Create the Project with the Professional template: title `Client – Project`, `Type` Professional, `Project Status` Not started (In progress if work started), `Start Date`, `End Date`, `Client Market`, `Project Value`. Link `CRM - MD`, `Services - MD`, `Discovery - MD`, `Tech Stack Options - MD`, and the career Area/Goal if obvious. If an advance is agreed, create the Advance Transaction (stage 9). Offer the first Tasks. Suggest the Drive folder `YYYY-MM_Client_ProjectName`.

**7. Work log.** "Worked 2h on X", "blocked on Y", "milestone done" → Project Logs: title `YYYY-MM-DD — Project — Log Type`, `Report Date`, `Log Type` (Update / Milestone / Blocker / Meeting Note), `Summary`, `Next Steps`, `Hours Spent`, `Minutes Spent`, `Type` Professional, linked to the Project. A conversation with the client is an Interaction, not a log. Status changes I mention → update `Project Status` (Waiting for feedback, Revision, …).

**8. Deliverable.** Pick the database: Design (logo, mockup, UI/UX, landing page, print), Branding (guidelines, logo files, palette, typography, voice), Marketing (Meta, Google Ads, SEO, social, email). Title `Client — Deliverable`, set type/status/`Revision Count`, link the Project. "Client asked for changes" → `Status` In Revision, raise `Revision Count` by 1. Delivery of the whole project → `Project Status` Done, `Delivered Date` today.

**9. Payment.** One Transaction per payment. Title `Client — Type`. Set `Amount`, `Transaction Type`, `Payment Status`, `Payment Method`, `Due Date`, `Received Date` (if received), `GST Applicable` / `GST Amount` if given, `Invoice Number` (next `INV-YYYY-###`: query the highest this year), `Invoice Link`, `Notes`. Link the Project and CRM client. Never set `Overdue`. "Payment received" for an existing pending one → update that Transaction, do not create a new one. Report the Project's pending amount after (rollup).

**10. Website.** On delivery of a site: Website page titled with the company, `URL`, `GitHub`, providers, statuses Live / Active; link Project, Tech Stack. Logins → remind me to store them in Bitwarden; never put them in Notion.

**11. Close.** When the Project is Done and the pending amount is 0: set CRM `Status` Completed if there is no other active project, log a closing Interaction if I mention one, then set `Archived` on the Project. If money is still pending, do not archive; say how much is pending.

## Pipeline questions
"Who do I need to follow up with", "pending payments", "lead pipeline", "how much did I earn this month": query the relevant databases (non-archived), answer as a compact table with links. Follow-ups = Leads / CRM with next follow-up in the next 7 days or overdue. Stuck leads = no status change for 14+ days.

## Reply
Per `notion.md` Reporting, listing every page touched. Last line: `Next:` plus one suggested step in the pipeline (only a suggestion).
