# The Brain: database registry

Every write uses the data source URL below as `parent.data_source_id` (drop the `collection://` prefix). Property names are not listed here on purpose: fetch the data source for its live schema (see `notion.md`).

Root page: `26c15156-ed37-8082-890d-e4549b012565` (The Brain). Operating Manual `41715156ed378128982fccbeea6131c6` · Personal HQ `41715156ed37812dbf3cfcc22a93c23b` · Business HQ `41715156ed37816aa856c60a46a598fc` · Proposal Template `3c915156ed378114bb5cf942c2dedae2` · Client Scripts `3c915156ed37816aa2eac3a05fbd1380`.

## 1. Core
| Database | Data source | Title property / note |
|---|---|---|
| Areas - MD | `collection://26c15156-ed37-81b8-b5f4-000b978d8817` | Life domains. Look up, never create without asking |
| Goals - MD | `collection://26c15156-ed37-8127-9fe0-000b4f40c319` | `Goal` |
| Projects - MD | `collection://26c15156-ed37-813d-ba7e-000b9e576e4c` | `Projects Name`; templates Personal / Professional |
| Disciplines - MD | `collection://26c15156-ed37-8150-833a-000baf39e138` | Look up, never create without asking |
| Resources - MD | `collection://26c15156-ed37-819e-a1e2-000b3e0f8daf` | `Resource` |
| Assets - MD | `collection://30215156-ed37-81f5-be85-000beca8f758` | `Assets` |
| Notes - MD | `collection://26c15156-ed37-8162-a7b6-000b66b7f3f7` | `Name` |
| Tasks - MD | `collection://26c15156-ed37-8173-83d8-000b99939749` | `Tasks`; templates Pre Trip Task, Packing List |
| Ideas - MD | `collection://26c15156-ed37-81cd-802b-000b587879ad` | `Name` |

## 2. Life & Discipline
| Database | Data source | Note |
|---|---|---|
| Habits - MD | `collection://26c15156-ed37-8108-9b3e-000b47af6c2e` | One page per day, titled `YYYY-MM-DD` |
| Journaling - MD | `collection://26c15156-ed37-816b-ae14-000ba4edbfa8` | Daily / Weekly / Monthly / Yearly templates |
| All time Progress - MD | `collection://26c15156-ed37-815f-9902-000b20d56d94` | Aggregates Habits. Read only in practice |
| Productivity Rewards -MD | `collection://26c15156-ed37-814c-b4c7-000b83af1647` | Linked from Tasks via `Today Task Progress` |
| Goals Rewards - MD | `collection://26c15156-ed37-8139-a9af-000bac45bc97` | Linked from Goals via `Rewards` |

## 3. Knowledge
| Database | Data source | Note |
|---|---|---|
| Library - MD | `collection://26c15156-ed37-812f-9523-000b10b19ec5` | Books, audiobooks, summaries |
| Courses - MD | `collection://27015156-ed37-81bb-a8f7-000bfc716529` | Title property is `Book Name` |

## 4. Cross-cutting
| Database | Data source | Note |
|---|---|---|
| People - MD | `collection://27015156-ed37-812f-8a28-000b50202e81` | Personal relationships; travel mates |
| Prompt - MD | `collection://27015156-ed37-81e0-95cf-000ba9fc527a` | AI prompt library |

## 5. Travel
| Database | Data source |
|---|---|
| Trips - MD | `collection://27015156-ed37-81c2-b293-000b4cfedac5` |
| Itinerary - MD | `collection://27015156-ed37-81f9-910e-000bb60879db` |
| Transport - MD | `collection://27015156-ed37-81bf-94c2-000ba473a614` |
| Accommodations - MD | `collection://27015156-ed37-814b-be48-000b2b653188` |
| Food - MD | `collection://27015156-ed37-8181-95a8-000b3f7df7cb` |
| Places - MD | `collection://27015156-ed37-81da-98fe-000bd0fb93d1` |
| Areas - MD (Travel, geographic) | `collection://27015156-ed37-81ed-a0e4-000bc4edbd2a` |
| Countries - MD | `collection://27015156-ed37-8100-8845-000b2bdd7670` |
| Packing List - MD | `collection://27015156-ed37-818b-be18-000b27e9420c` |

Two databases are named `Areas - MD`. Life domains = `81b8…8817`. Geographic regions = `81ed…bd2a`. Never mix them.

## 6. Business
| Database | Data source |
|---|---|
| Leads - MD | `collection://38a15156-ed37-8015-825f-000b3ea1c0c1` |
| CRM - MD | `collection://38a15156-ed37-80eb-9c5b-000bd6e564cc` |
| Interactions - MD | `collection://38a15156-ed37-8062-a2b1-000b1983c787` |
| Discovery - MD | `collection://41ade876-2caf-40ba-9b17-784d2ad904c6` |
| Services - MD | `collection://30215156-ed37-8065-a3dd-000b34de010b` |
| Tech Stack Options - MD | `collection://46526b24-117e-4031-a067-234220a30d10` |
| Project Logs - MD | `collection://39115156-ed37-80d7-9675-000b047ac495` |
| Transactions - MD | `collection://38c15156-ed37-807e-873d-000b8773d525` |
| Design Deliverables - MD | `collection://834f3207-2e74-4f0e-b840-74f6848e6762` |
| Branding Deliverables - MD | `collection://406845ed-feb9-4799-a475-005b755c3560` |
| Marketing Deliverables - MD | `collection://2eaf24f8-e4c3-449b-a4f4-3f4d7bbb24c4` |
| Website - MD | `collection://27015156-ed37-81ee-9b48-000b50cb3424` |

## Out of scope
Never read or write: Investment, Cards, Credit Cards, job Applications, laptop Comparison, Websites Master File, Credentials, Semigon Daily Reports. If asked, say they are excluded from this plugin.

## If an ID stops working
A database was moved or recreated. Fetch the root page above, find the database by name, use its new `data-source-url`, and tell me to update this file.
