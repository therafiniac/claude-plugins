# Capability: Analytics
Kind: capability
Ask when: the site or app is public and you want traffic or usage numbers.
Default: content sites → umami (cloud free tier or self-hosted). Hosted on Cloudflare and only need basic traffic → cloudflare-web-analytics. Apps that need funnels or product analytics → posthog.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| umami | adopt | Cookieless, simple dashboard, open source (MIT). Cloud or self-hosted on a small server with Postgres | any | free cloud tier with a cap, or free self-hosted |
| plausible | adopt | Cookieless, polished hosted product, or self-hosted Community Edition | any | paid cloud; self-hosted CE is free but needs Docker and a few GB of RAM |
| cloudflare-web-analytics | adopt | Site already on Cloudflare and page views are enough | any | free |
| posthog | trial | App needs funnels, retention, feature flags, or session replay | nextjs, react-spa, react-express, astro | free tier with caps; usage-based |
| google-analytics | hold | Do not use by default. Uses cookies, so a consent banner is needed in many regions, and the script is heavier | — | — |

## Option: umami
Setup: one `<script defer src="<umami host>/script.js" data-website-id="...">` in the base layout, with the website ID and host from env vars. Self-hosting runs Umami with Docker and Postgres.
Security checks (added to security-audit):
- A self-hosted instance runs behind HTTPS with its admin login protected and the default password changed (§10).
Sources: https://umami.is/docs

## Option: plausible
Setup: the snippet from the Plausible site settings in the base layout, domain from an env var. For self-hosting, Plausible Community Edition via its Docker Compose setup.
Security checks (added to security-audit):
- A self-hosted instance runs behind HTTPS with registration closed after the first account (§10).
Sources: https://plausible.io/docs, https://plausible.io/docs/self-hosting

## Option: cloudflare-web-analytics
Setup: enable it for the site in the Cloudflare dashboard. On Cloudflare Pages it can be injected automatically; otherwise add the beacon snippet to the base layout.
Conventions:
- Use it for page views only. It does not replace product analytics.
Sources: https://developers.cloudflare.com/web-analytics/

## Option: posthog
Setup: `posthog-js` (plus `posthog-node` for server events), initialized once in the app shell with the project key and API host from env vars.
Conventions:
- Decide up front which features are on (autocapture, session replay, feature flags) and record it in an ADR.
- Identify users by an internal ID, never by email.
Security checks (added to security-audit):
- Session replay masks all inputs and any element showing personal data (§11).
- Cookies or session replay require consent where the law asks for it; the consent choice is honored before init (§11).
Performance checks (added to performance-audit):
- PostHog loads after the page is interactive, and not on pages that do not need it.
Sources: https://posthog.com/docs

## Shared
Conventions:
- The analytics script loads only in production builds, never in dev or previews.
- Custom events are named in one module (`src/lib/analytics.ts`), in a consistent `noun-verb` style.
Security checks (added to security-audit):
- The CSP allows scripts and connections only from the analytics host (§10, §12).
- No personal data (emails, names, IDs) goes into event properties or tracked URLs (§11).
- Cookieless tools usually avoid a consent banner, but confirm this for your jurisdiction (§11).
Performance checks (added to performance-audit):
- The script is `defer` or `async` and does not delay LCP.
