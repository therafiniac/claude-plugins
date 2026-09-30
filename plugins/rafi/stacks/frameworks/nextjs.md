# Framework profile: Next.js (App Router)
Kind: framework. Use for public or SEO-relevant sites: blogs, marketing and content sites, SaaS with public pages. Pair it with a database profile.
Next.js behavior changes between major versions. Verify version-specific claims in the installed version's docs.

## Stack
Next.js (App Router), TypeScript strict, Zod, Vitest, Playwright, pnpm. Default hosting: Railway. Styling, icons, CMS, search, and other cross-cutting concerns come from the chosen capabilities (`stacks/capabilities/`).

## Scaffold contract
- Folders: `src/app` (routes only, thin), `src/features/<name>/{actions,service,repo,schema,tests}`, `src/lib` (database client, auth, utils), `src/config/env.ts` (Zod-validated env, used instead of `process.env`).
- Layering: route handler or server action → service → repo. Only repos touch the database.
- Scripts: `dev`, `build`, `typecheck` (`tsc --noEmit`), `lint`, `test`, `check` (typecheck + lint + test), `test:e2e` (`playwright test`), `lighthouse` (`lhci autorun`).
- Also: `packageManager`, `.nvmrc`, Prettier, ESLint (Next config), Vitest, `.env.example`, `/api/health`, one passing test.
- E2E and Lighthouse dev dependencies: `@playwright/test`, `@axe-core/playwright`, `@lhci/cli`.
- Never prefix a secret with `NEXT_PUBLIC_`.

### `playwright.config.ts`
```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,
  use: { baseURL: 'http://localhost:3000' },
  webServer: {
    command: 'pnpm start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### `e2e/a11y.spec.ts` (list the real public routes)
```ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

for (const path of ['/']) {
  test(`no detectable accessibility violations on ${path}`, async ({ page }) => {
    await page.goto(path);
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'])
      .analyze();
    expect(results.violations).toEqual([]);
  });
}
```

### `lighthouserc.json` (list the real public URLs)
```json
{
  "ci": {
    "collect": {
      "startServerCommand": "pnpm start",
      "url": ["http://localhost:3000/"],
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
- Server Components by default. Add `'use client'` only for interactivity, at the smallest leaf.
- Validate every server-action and route-handler input with Zod, schemas in `features/<name>/schema`.
- Never return raw database records to the client. Map to DTOs with only the fields the page needs.
- Pagination is server-side with a capped page size.
- Mutations revalidate affected pages (`revalidatePath` or `revalidateTag`).

## Security checks (added to security-audit)
- Server actions and route handlers are public endpoints. Each checks authentication and ownership itself. Middleware or layout guards alone are not enough (§3).
- Only `NEXT_PUBLIC_` variables reach the browser. No secrets there.
- `dangerouslySetInnerHTML` only with sanitized input (§4).
- Security headers (CSP, HSTS, nosniff, frame-ancestors, Referrer-Policy) set via `headers()` in `next.config` (§6).
- Route handlers with cookie auth need an Origin check or CSRF token. Server actions have a built-in Origin check; confirm for the installed version.
- `next/image` `remotePatterns` is an allowlist, never a wildcard.
- Rate limit auth and search route handlers.

## SEO checks (added to seo-audit)
- Every dynamic route exports `generateMetadata` built from its content. Layout titles use a template.
- `app/sitemap.ts` and `app/robots.ts` exist, generate from real content, and robots does not block production.
- Canonical via `alternates.canonical` on every indexable page.
- JSON-LD (Article, BreadcrumbList, Organization) rendered as `<script type="application/ld+json">` and validated.
- Metadata merge is shallow: a page that sets `openGraph` drops the parent's siteName, locale, and images. Use one shared helper that builds a complete `openGraph` for every page.
- Missing detail pages must return a real 404. A `loading.tsx` above a dynamic segment can make missing slugs return 200 with a streamed body. Keep `loading.tsx` out of `[slug]` routes, call `notFound()`, and verify with `curl -I`.
- `next/image` with explicit dimensions and `next/font` protect CLS.

## Performance checks (added to performance-audit)
- Classify each route: static, revalidated, or dynamic. Using `cookies()`, `headers()`, or `searchParams` makes a route dynamic. Confirm that is intended.
- Heavy client-only dependencies (rich-text editor, charts) load via `next/dynamic` and never on public pages.
- Measure the bundle with `@next/bundle-analyzer`.
- Stream slow below-the-fold data with `Suspense`.
- Run Lighthouse against a production build (`pnpm build`, then `pnpm lighthouse`). Never measure with `next dev`.

## Accessibility checks (added to accessibility-audit)
- Use `next/link` and real `<a>` and `<button>` elements. No clickable `div`s.
- Route changes move focus or announce the new page title. Verify with a screen reader.
- Every form field has a visible `<label>`. Server-action errors render in an element with `role="alert"` or `aria-live`.
- `next/image` always gets meaningful `alt` text, or `alt=""` for decoration.
- `e2e/a11y.spec.ts` covers every public route.
