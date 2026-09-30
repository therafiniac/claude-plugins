# Capability: CMS
Kind: capability
Ask when: someone other than the developer edits content, or content changes often enough that editing files in the repo is a chore.
Default: none. If editors need a web editor for a Markdown site → keystatic. If content is structured, shared across channels, or needs scheduling or roles → sanity.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| none | adopt | You edit Markdown in the repo yourself (Astro content collections, MDX) | any | free |
| keystatic | adopt | Git-based web editor for Markdown, YAML, or JSON in the repo. Local mode needs no account. Astro needs an adapter for its admin routes | astro (on-demand routes), nextjs | free; Keystatic Cloud optional |
| decap | trial | Git-based editor on a purely static site with no server routes at all | astro, react-spa, any static output | free |
| sanity | adopt | Structured content, several editors, drafts and previews, content reused across sites or apps | nextjs, astro | hosted; free plan, check current limits |
| payload | trial | App and CMS in one Next.js codebase, self-hosted, content in your own database | nextjs + postgres or mongodb | free, self-hosted |

## Option: none
Setup: nothing beyond the framework. Content lives in the repo (Astro: `src/content` collections with a Zod schema).
Conventions: every content file validates against the collection schema; the build fails on invalid frontmatter.
Sources: https://docs.astro.build/en/guides/content-collections/

## Option: keystatic
Setup: `@keystatic/core` plus the framework package (`@keystatic/astro` with `@astrojs/react` and an adapter, or `@keystatic/next`). `keystatic.config.ts` defines collections that point at the same folders the site reads (for Astro, `src/content/...`). Storage: `local` in development, `github` in production (a GitHub App), or Keystatic Cloud.
Conventions:
- The Keystatic schema and the site's content schema describe the same fields. Change both in the same commit.
- Production edits create commits on the repo. Decide whether they go straight to `main` or to branches, and write it in `docs/architecture.md`.
- Limits to accept up front: no scheduling, no approval workflow, no built-in localization, and all content lives in Git.
Security checks (added to security-audit):
- The admin routes (`/keystatic`) are served only in the intended environment, and GitHub mode requires GitHub login (§1, §3).
- GitHub App credentials and `KEYSTATIC_SECRET` are server-only env vars, never `PUBLIC_` (§5).
- The GitHub App has access only to this repository (§15).
Performance checks (added to performance-audit):
- Keystatic's admin UI and React are loaded only on admin routes, never on public pages.
Sources: https://keystatic.com/docs, https://github.com/thinkmill/keystatic

## Option: decap
Setup: `public/admin/index.html` loading `decap-cms` (script tag or the `decap-cms-app` package) and `public/admin/config.yml` with `backend`, `media_folder`, `public_folder`, and `collections` whose `folder` points at the content folder (for Astro, `src/content/<collection>`).
Conventions:
- `config.yml` fields match the content schema. Change both in the same commit.
- Put `media_folder` under `src/assets/` so the framework's image pipeline optimizes uploads.
- Releases are slower since the Netlify CMS rebrand. Pin the version and check the changelog before upgrading.
Security checks (added to security-audit):
- The GitHub backend needs an OAuth flow. Outside Netlify, that means your own OAuth route or proxy (for example a small server route or worker). Its client secret is a server-only secret (§5, §15).
- OAuth scopes are the minimum the backend needs, and the OAuth app is limited to this repository where possible (§15).
Sources: https://decapcms.org/docs/, https://docs.astro.build/en/guides/cms/decap-cms/

## Option: sanity
Setup: nextjs → `next-sanity`, with Studio embedded at `/studio` through `NextStudio` or run separately. astro → `@sanity/astro`. Schemas live in code. Generate TypeScript types with Sanity TypeGen.
Conventions:
- Queries (GROQ) live in one module per feature and select only the fields the page renders.
- Published content is read through the CDN API. Draft and preview reads use a token on the server only.
- Revalidate on publish with a webhook, rather than short cache times.
Security checks (added to security-audit):
- Read tokens that can see drafts, and all write tokens, are server-only (§5).
- The revalidation webhook verifies Sanity's signature before acting (§6, §15).
- Rich text is rendered through Portable Text components, never raw HTML (§4, §12).
- CORS origins in the Sanity project list only your domains (§10).
Performance checks (added to performance-audit):
- Images go through Sanity's image URL builder with explicit width and format, plus the framework's image component.
- No per-request uncached queries on public pages.
Sources: https://www.sanity.io/docs/nextjs/introduction, https://github.com/sanity-io/next-sanity, https://www.sanity.io/docs

## Option: payload
Setup: `npx create-payload-app@latest` (or `--no-next-app` to add it to an existing Next.js app) with the database adapter that matches the database profile: `@payloadcms/db-postgres` or `@payloadcms/db-mongodb`. The admin panel runs inside the Next.js app. Check the Next.js versions Payload supports before upgrading Next.
Conventions:
- Collections and access-control functions are defined in code and reviewed like any other code.
- Use Payload's local API in server code, not HTTP calls to your own app.
Security checks (added to security-audit):
- Every collection defines `access` rules explicitly. No collection relies on the defaults for read or write (§3).
- `PAYLOAD_SECRET` and database credentials are server-only env vars (§5).
- Upload collections restrict MIME types and file size (§7).
Performance checks (added to performance-audit):
- Queries set `depth` and `limit` explicitly. No unbounded relationship population.
Sources: https://payloadcms.com/docs/getting-started/installation, https://payloadcms.com/docs/database/overview
