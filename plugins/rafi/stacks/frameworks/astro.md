# Framework profile: Astro
Kind: framework. Use for content-driven sites where SEO and speed matter most: blogs, documentation, marketing and portfolio sites, and small shops backed by a headless service. A purely static site needs no database profile (choose none). Add one only if the site has server-side data.
Verified against: Astro 7.x (Vite 8, Rust compiler), September 2026. Read in full: the Astro v7 upgrade guide, https://docs.astro.build/en/guides/upgrade-to/v7/. The rest follows the Astro docs guides named below. Re-verify version-specific behavior before large changes.

## Stack
Astro 7, TypeScript strict, Vitest, Playwright, pnpm. Styling, icons, CMS, search, and other cross-cutting concerns come from the chosen capabilities (`stacks/capabilities/`). Static output by default. Interactive islands use one UI framework only when needed (React is the default choice). Default hosting: a static host (Railway, Netlify, Cloudflare Pages, or Vercel). On-demand rendering needs an adapter for the chosen host.
Node: use a current LTS that the installed Astro version supports, and pin it in `.nvmrc`.

## Scaffold contract
- Create with `pnpm create astro@latest` (minimal template, TypeScript strict), or scaffold by hand.
- Folders: `src/pages` (routes only), `src/layouts` (page shell with head, SEO, skip link), `src/components`, `src/content` (Markdown, MDX, or data), `src/content.config.ts` (collection definitions), `src/lib`, `public/` (static files such as `robots.txt`).
- Collections use the Content Layer API: a loader plus a Zod schema (Zod comes from `astro/zod`). Astro 6 and later have no legacy collections.
- Scripts: `dev` (`astro dev`), `build` (`astro build`), `preview` (`astro preview`), `typecheck` (`astro check`, which needs `@astrojs/check` and `typescript`), `lint` (ESLint with `eslint-plugin-astro`), `test` (Vitest configured with `getViteConfig` from `astro/config`), `check` (typecheck + lint + test), `test:e2e` (`playwright test`), `lighthouse` (`lhci autorun`).
- Also: `packageManager`, `.nvmrc`, Prettier with `prettier-plugin-astro`, `.env.example`, one passing test, `@astrojs/sitemap`, and `site` set in `astro.config.mjs`.
- Overrides to the standard bootstrap list: no health endpoint for static output. Environment variables are declared in the `astro:env` schema instead of a hand-written Zod env module.
- E2E and Lighthouse dev dependencies: `@playwright/test`, `@axe-core/playwright`, `@lhci/cli`. Reuse the `e2e/a11y.spec.ts` pattern from the Next.js profile with this site's real routes. E2E and Lighthouse run against a build served with `pnpm preview`, so run `pnpm build` first.

### `playwright.config.ts`
```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,
  use: { baseURL: 'http://localhost:4321' },
  webServer: {
    command: 'pnpm preview',
    url: 'http://localhost:4321',
    reuseExistingServer: !process.env.CI,
  },
});
```

### `lighthouserc.json` (list the real URLs)
```json
{
  "ci": {
    "collect": {
      "startServerCommand": "pnpm preview",
      "url": ["http://localhost:4321/"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["warn", { "minScore": 0.9 }],
        "categories:accessibility": ["error", { "minScore": 0.95 }],
        "categories:seo": ["error", { "minScore": 0.95 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.1 }]
      }
    }
  }
}
```

## Conventions
- Ship zero client JavaScript by default. Add an island only for real interactivity, and use the lightest directive that works: `client:visible` or `client:idle` before `client:load`. `client:only` skips server rendering, so never use it for content.
- Layouts own the `<head>`. Title, description, canonical, Open Graph, and JSON-LD come from one `SEO` component with typed props. Pages never write raw `<meta>` tags.
- Content lives in collections and pages query it with `getCollection`. Slugs come from the content, not from hand-typed strings.
- Content images use `astro:assets` (`<Image>` or `<Picture>`) with `alt` and dimensions. No raw `<img>` for content.
- Forms and mutations on on-demand routes use Astro Actions with Zod input validation.
- A page that needs per-user data or authentication sets `export const prerender = false` and is served on demand.
- Keep templates valid HTML. Astro 7's compiler no longer repairs bad markup.

## Astro 7 changes that break older habits
- The Rust compiler is stricter: unclosed tags are errors, and invalid nesting (a `div` inside a `p`) is passed through to the browser unchanged.
- `compressHTML` now defaults to `'jsx'`, so whitespace between inline elements is stripped. Add `{" "}` where a space is needed, or set `compressHTML: true`.
- Markdown renders with Sätteri by default. Remark and rehype plugins need `@astrojs/markdown-remark` and `markdown.processor: unified()`.
- `src/fetch.ts` is a reserved file name. `@astrojs/db` is removed.
- Vite 8 is the bundler, so Vite-specific plugins may need updating.

## Security checks (added to security-audit)
- `set:html`, and `dangerouslySetInnerHTML` inside islands, render raw HTML. Use them only with sanitized or trusted content (§4, §12).
- Variables prefixed `PUBLIC_`, or declared with `context: 'client'` in `astro:env`, reach the browser. Secrets are declared with `access: 'secret'` and `context: 'server'` (§5).
- Prerendered pages skip middleware. Any page or endpoint that needs authentication is on-demand (`prerender = false`) and checks the user itself. Middleware alone is not enough (§3).
- Endpoints and Actions validate all input with Zod and check authorization on every call (§3, §4). Confirm `security.checkOrigin` behavior for the installed version on form posts (§6).
- Security headers (CSP, HSTS, `X-Content-Type-Options`, `Referrer-Policy`, `frame-ancestors`): on a static host set them in the host's configuration. On-demand routes can set them in middleware (§10).
- Third-party scripts are few, loaded async, and reviewed. Consider Partytown for heavy ones (§15).
- Integrations and adapters come from trusted publishers, at pinned versions (§9).

## SEO checks (added to seo-audit)
- `site` is set in `astro.config`. `@astrojs/sitemap` generates the sitemap index. `robots.txt` points to it and does not block production.
- Every page has a unique title, a meta description, and a canonical URL built from `Astro.url` and `site`.
- `trailingSlash` and `build.format` are set once and match the canonicals, the sitemap, and internal links. Every changed URL has a redirect (`redirects` config or host rules).
- `src/pages/404.astro` exists and the host serves it with status 404. Verify a missing URL with `curl -I`.
- JSON-LD (Article, BreadcrumbList, Organization) is rendered with `<script type="application/ld+json" set:html={JSON.stringify(data)} />` and validated.
- The LCP image is not lazy-loaded. Blogs publish an RSS feed with `@astrojs/rss`.
- Paginated lists use `paginate()`, and each page has a self-referencing canonical.
- Multilingual sites use Astro's i18n routing and `hreflang` (§9 of the SEO standard).

## Performance checks (added to performance-audit)
- Count the client islands per page and the JavaScript each one ships. A content page should ship almost none.
- No `client:load` without a written reason.
- Fonts use Astro's font handling or self-hosted subsets with `font-display: swap`. Preload only the critical font.
- View transitions and prefetch are on only if measured to help. Each adds client code.
- On-demand pages use route caching (stable in Astro 7) where the content allows. Large pages stream.
- Large collections are paginated at build time.
- Measure the bundle with a bundle-analysis tool. Measure speed with Lighthouse against `astro build` plus `astro preview`, never `astro dev`.

## Accessibility checks (added to accessibility-audit)
- The layout sets `<html lang>` and has landmarks (`header`, `nav`, `main`, `footer`) and a skip link. Each page has one `<h1>`.
- `<Image>` requires `alt`. Decorative images use `alt=""`.
- Islands are keyboard-operable and follow the WAI-ARIA pattern for their widget.
- If view transitions (`ClientRouter`) are on, verify focus handling and route announcements with a screen reader.
- Markdown content: headings do not skip levels and links have descriptive text.
- `e2e/a11y.spec.ts` covers every page template.

## Sources
- https://docs.astro.build/en/guides/upgrade-to/v7/ (read in full)
- https://docs.astro.build/en/upgrade-astro/ (latest release and Node policy)
- Astro docs guides for content collections, images, on-demand rendering, actions, environment variables, testing, and deployment. Section names taken from the docs navigation. Re-verify details before relying on them.
