# The Brain: conventions

## Vocabulary
| Term | Meaning | Finishes? |
|---|---|---|
| Area | Fixed life domain (Health, Career, Finance) | Never |
| Goal | Year/quarter target | Yes |
| Project | Deadline-bound work | Yes |
| Discipline | Skill being mastered (MERN, Photography, Trading) | Never |
| Task | Single disposable action | Yes |
| Note | Atomic thought / knowledge | — |
| Idea | Pre-project, no deadline | Becomes a Project or is shelved |
| Resource | Collected from outside | — |
| Asset | Created by me, reusable | — |

Promotion: Note → Idea → Project → linked to Goal → Area. Finished → Archived.

## Routing ("where does this go?")
| I give you | Database |
|---|---|
| A thought, learning, lecture note | Notes |
| Something to do | Tasks |
| A "someday" project, no deadline | Ideas (`Exploring`) |
| Work with a deadline | Projects |
| A link / tool / inspiration tied to a Discipline or Project | Resources (otherwise suggest Raindrop) |
| Something I made and will reuse (template, snippet, preset) | Assets |
| A book, audiobook, ePub, summary | Library |
| A course | Courses |
| A person in my life | People |
| An AI prompt | Prompt |
| A reflection, mood, gratitude | Journaling |
| Habit ticks | Habits (today's page) |
| Anything for a trip | Trips + Itinerary / Places / Food / Accommodations / Transport / Packing List |
| A prospect, client, call, payment, work log, deliverable, client site | Business → `/brain:client` |
| Unclear | Notes (sorted on Sunday) |

## Statuses (exact wording)
- Tasks `Status`: TO DO → DOING → Done. `Priority` P1–P4. `Energy` High / Medium / Low.
- Projects `Project Status`: Planned · Not started · Hold → In progress → Waiting for feedback → Revision → Done.
- Goals `Goal Status`: Get Ready → In Progress → In the Middle → So Close → You did it.
- Ideas: Exploring → Developing → On Hold.
- Library `Reading Status`: To Consume → In Progress → Writing Summary → Close to finish → Finished / Abandoned.
- Courses: Not started · Hold → In progress → Completed.
- Leads: New Lead → Attempted → Connected → Meeting Scheduled → Proposal Sent → Negotiation → Close Won / Close Lost.
- CRM: On Hold · Paused → Active → Completed. Health 🔴 Critical / 🟡 At Risk / 🟢 Healthy.
- Transactions `Payment Status`: Pending, Partially Paid, Received, Cancelled.
- Always confirm against the live schema; it wins over this list.

## Defaults when I don't say
- `Type`: Professional if it mentions a client, lead, company work, freelancing, or a Professional project; otherwise Personal.
- New task: `Status` TO DO, `Priority` P3, `Energy` Medium, `Task Date` only if I gave a date.
- Every Task links to a Project, Goal, or Area. If I gave none, infer the most likely Area and say which; if unsure, leave it for the Sunday review and say so.
- Every Project, Task and Asset gets a `Type`.

## Page titles
| Database | Pattern | Example |
|---|---|---|
| Areas | Single noun, Title Case | `Health` |
| Goals | Outcome statement | `Land a Tier-1 Product Dev Role` |
| Projects (Personal) | Plain descriptive name | `Portfolio Redesign` |
| Projects (Professional) | `Client – Project` | `Lakshmi Kashi NGO – Website` |
| Disciplines | Subject | `MERN Stack` |
| Tasks | Verb first, specific | `Fix navbar overflow on mobile` |
| Notes | `Topic – detail` | `AZ-900 – Lecture 4 Networking` |
| Ideas | Short pitch | `Lightroom preset store` |
| Resources | `Source – what` | `Mobbin – UI patterns` |
| Assets | Name + kind | `Proposal Template v02` |
| Library / Courses | Exact title | `Atomic Habits` |
| Habits | Date | `2026-11-14` |
| Journaling | Cadence + date | `Daily – 2026-11-14`, `Weekly – 2026-W46`, `Monthly – 2026-11`, `Yearly – 2026` |
| Trips | `YYYY-MM Place` | `2026-12 Manali Trek` |
| People | Full name | `Moloy Saha` |
| Prompt | What it does | `SEO meta description writer` |
| Leads / CRM / Website | Company (or person if no company) | `Lakshmi Kashi NGO` |
| Interactions | `What — Who` | `Discovery Call — Lakshmi Kashi NGO` |
| Discovery | `Discovery — Client` | `Discovery — Debamitra Dey` |
| Services | `Service – Tier` | `Business Website – Standard` |
| Project Logs | `YYYY-MM-DD — Project — Log Type` | `2026-11-14 — Lakshmi Kashi Website — Update` |
| Transactions | `Client — Type` | `Lakshmi Kashi NGO — Advance` |
| Deliverables | `Client — Deliverable` | `Lakshmi Kashi NGO — Logo v02` |

Lead IDs `LD001`, `LD002`, … (three digits, sequential). Invoice numbers `INV-YYYY-###`.

Note the dash: `–` (en dash) in Projects, Notes, Resources, Services, Journaling; `—` (em dash) in Interactions, Discovery, Project Logs, Transactions, Deliverables.

## Drive and files (for suggestions only; skills do not create Drive files unless I ask)
- No spaces; underscores. Dates `YYYY-MM-DD`, months `YYYY-MM`. Versions `_vNN`.
- Personal project folder `01_Personal/01_Projects/YYYY-MM_Name`. Client project `YYYY-MM_Client_ProjectName`. Invoices `01_Freelancing/02_Areas/Contracts_Invoices`, file `YYYY-MM_Invoice_###_Client.pdf`. Archive `99_Archive/YYYY`.
- Inboxes: Drive `00_Inbox`, `03_Quick_Share`, `Photography/Unsorted`; Raindrop unsorted.

## Other tools
Notion is the map. Files → Google Drive. Bookmarks → Raindrop. Passwords, keys, client logins → Bitwarden. Email: `myselfrafi001` private · `therafiniac` public/tools · `@rafiera.com` client communication.

## Rules
1. Every Project, Task, Asset has a `Type`.
2. No orphan Tasks after Sunday.
3. Contact details: Leads before the sale, CRM after. Never edit both.
4. Conversations → Interactions. Own work progress → Project Logs.
5. One payment = one Transaction.
6. Never set Overdue or Completion Date by hand.
7. Archive, never delete.
8. No secrets in Notion.
9. Capture fast, organise on Sunday.
