# Capability: Search
Kind: capability
Ask when: the site has more than about 20 content pages (blog, docs, catalog), or the PRD mentions search or filtering.
Default: static or content sites → pagefind. Apps on the postgres profile → postgres-fts. Large or typo-sensitive datasets → meilisearch.
Verified: September 2026 (Pagefind 1.5). Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| pagefind | adopt | Static or mostly static content site. Index built from the HTML at build time, no server | astro, any static output | free |
| postgres-fts | adopt | App already on Postgres; search over its own tables | postgres | free |
| meilisearch | trial | Large or fast-changing dataset, typo tolerance, facets, instant results | any server-side framework | free self-hosted; cloud plan |
| algolia | trial | Hosted search with minimal ops, or DocSearch for public documentation | any | paid beyond the free tier; DocSearch free for eligible docs |

## Option: pagefind
Setup: `pagefind` as a dev dependency. Run it after the framework build on the build output folder: `"build": "astro build && pagefind --site dist"`. Pagefind writes `dist/pagefind/`. Search UI: the Component UI (Pagefind 1.5 and later), loaded only on pages with search:
```html
<link href="/pagefind/pagefind-component-ui.css" rel="stylesheet">
<script src="/pagefind/pagefind-component-ui.js" type="module"></script>
<pagefind-modal-trigger></pagefind-modal-trigger>
<pagefind-modal></pagefind-modal>
```
Conventions:
- Put `data-pagefind-body` on the main content element of every page that should be searchable. Once it appears anywhere, pages without it are not indexed.
- Mark navigation, footers, and related-post lists with `data-pagefind-ignore`.
- Use `data-pagefind-meta` for the title, date, and image shown in results, and `data-pagefind-filter` for facets such as tags.
- Search does not work under `astro dev`. Test it with a build plus `astro preview`.
Security checks (added to security-audit):
- The index is public and downloadable. Never index drafts, private pages, or anything behind login (§11).
Performance checks (added to performance-audit):
- The search script and CSS load only on pages with search, or when the search opens.
Accessibility checks (added to accessibility-audit):
- The search dialog is reachable by keyboard, traps focus while open, closes on Escape, and returns focus to the trigger. Verify with a keyboard walkthrough (§2).
- The trigger has an accessible name and the result count is announced (§4).
Sources: https://pagefind.app/docs/, https://pagefind.app/docs/indexing/

## Option: postgres-fts
Setup: no new service. Add a generated `tsvector` column over the searchable fields with a GIN index, in a migration. Query with `websearch_to_tsquery` and rank with `ts_rank`.
Conventions:
- One search function in the repo layer. Routes never build SQL for search.
- Set the text search configuration (for example `'english'`) explicitly and consistently.
- Results are paginated with a capped page size.
Security checks (added to security-audit):
- The search input is passed as a parameter, never concatenated into SQL (§4).
- The search endpoint is rate limited (§13).
- Results apply the same authorization filter as the list pages (§3).
Performance checks (added to performance-audit):
- `EXPLAIN` shows the GIN index is used on the search query.
Sources: https://www.postgresql.org/docs/current/textsearch.html

## Option: meilisearch
Setup: a Meilisearch instance (self-hosted container or Meilisearch Cloud) and the official JS client. Indexing happens on write through a job or queue, plus a full reindex script.
Conventions:
- The server uses the master or admin key. The browser gets only a search key scoped to specific indexes, or queries go through your own API.
- Define searchable, filterable, and sortable attributes explicitly per index.
Security checks (added to security-audit):
- The master key never reaches the client or the logs (§5).
- Documents for private data are either not indexed or filtered with tenant tokens (§3, §11).
Performance checks (added to performance-audit):
- Indexing runs outside the request path.
Sources: https://www.meilisearch.com/docs

## Option: algolia
Setup: the Algolia JS client and an index per content type. For public docs, apply to DocSearch instead of building the crawler yourself.
Conventions:
- Push records from the server or build step. The browser uses only the search-only API key.
Security checks (added to security-audit):
- The admin API key is server-only. The frontend key is search-only and, for private data, a secured API key with filters (§5, §3).
Sources: https://www.algolia.com/doc/, https://docsearch.algolia.com
