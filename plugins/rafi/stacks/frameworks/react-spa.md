# Framework profile: React SPA (Vite), frontend only
Kind: framework. Use for a React single-page app that talks to an API that already exists (yours, a client's, or a third party's): dashboards, admin panels, internal tools, widgets. There is no backend in this repo. For a backend in the same repo use `react-express`. For public pages that need SEO use `nextjs` or `astro`: a SPA serves crawlers an empty shell. Choose database: none.
Verified against: Vite 8 (Rolldown), announced at https://vite.dev/blog/announcing-vite8, and create-vite 9.x, September 2026. Vite 8 needs Node 20.19+ or 22.12+. The rest follows the React, Vite, and library docs. Re-verify version-specific behavior before large changes.

## Stack
React with TypeScript strict, Vite, React Router, TanStack Query, Zod, Vitest with React Testing Library, MSW, Playwright, pnpm. Styling, icons, and other cross-cutting concerns come from the chosen capabilities (`stacks/capabilities/`). Default hosting: any static host (Railway, Netlify, Cloudflare Pages, or Vercel) with a fallback that serves `index.html` for every route.

## Scaffold contract
- Create with `pnpm create vite my-app --template react-ts` (or `react-compiler-ts`), then add the libraries above.
- Folders: `src/app` (providers, router, error boundary), `src/features/<name>/{components,api,hooks,schema,tests}`, `src/components/ui` (shared primitives), `src/lib/http.ts` (the one API client), `src/config/env.ts` (Zod-validated `import.meta.env`).
- The API client is the only code that calls `fetch`. It sets the base URL, credentials mode, timeouts and abort, and turns failures into typed errors. Every response is parsed with a Zod schema before the app uses it.
- Scripts: `dev` (`vite`), `build` (`tsc -b && vite build`), `preview` (`vite preview`), `typecheck` (`tsc -b`), `lint` (`eslint .` with `eslint-plugin-jsx-a11y`), `test` (`vitest run`), `check` (typecheck + lint + test), `test:e2e` (`playwright test`), `lighthouse` (`lhci autorun`, only if the app has public pages).
- Also: `packageManager`, `.nvmrc`, Prettier, `.env.example`, one passing test.
- Overrides to the standard bootstrap list: no health endpoint (static output). The env module validates `import.meta.env`. Only `VITE_` variables reach the browser, so everything in them is public.
- E2E dev dependencies: `@playwright/test`, `@axe-core/playwright`. Reuse the `e2e/a11y.spec.ts` pattern from the Next.js profile with this app's real routes. Screens behind login need a test user or a mocked API.

### `playwright.config.ts`
```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,
  use: { baseURL: 'http://localhost:4173' },
  webServer: {
    command: 'pnpm preview --port 4173 --strictPort',
    url: 'http://localhost:4173',
    reuseExistingServer: !process.env.CI,
  },
});
```
The E2E workflow runs `pnpm build` before the tests.

## Conventions
- Server state lives in TanStack Query (a query-key factory per feature, explicit `staleTime`). URL state lives in the router. Local UI state stays in components. No global store for server data.
- Routes are lazy-loaded with `React.lazy` and `Suspense`. Each route has an error boundary and handles loading, empty, error, and success states.
- Forms validate with a Zod schema that mirrors the API contract. Never trust that the API will reject bad input.
- Authentication belongs to the API. Prefer `HttpOnly` cookies set by the API. If tokens are unavoidable, keep them in memory only. Never store tokens in `localStorage` or `sessionStorage`.
- Components render data through JSX. Raw HTML from the API is never rendered without sanitization.
- Tests use MSW at the network boundary and query by role and label, not by class or test id. No snapshot tests for logic.
- Configuration that changes per environment comes from `VITE_` variables, not from code.

## Security checks (added to security-audit)
- `dangerouslySetInnerHTML` only with input sanitized by a maintained library such as DOMPurify (§4, §12).
- No secrets in the bundle. Everything under `VITE_` is public, so a secret placed there is leaked (§5).
- Tokens are not in `localStorage` or `sessionStorage`. Cookie-authenticated requests rely on the API's `SameSite` and CSRF protection, and the client sends `credentials: 'include'` only to the API origin (§2, §12).
- Redirect targets from query parameters (`?next=`) are validated against an allowlist, to prevent open redirects (§4).
- External links that open a new tab use `rel="noopener noreferrer"` (§12).
- Response data is parsed with Zod before use, so unexpected shapes fail safely (§4).
- Security headers (CSP, HSTS, `X-Content-Type-Options`, `Referrer-Policy`, `frame-ancestors`) are set in the host's configuration (§10).
- Production source maps are disabled or not served publicly unless deliberately chosen (§10).
- The dev server is for local use only. Do not expose it with `server.host`, and keep Vite updated (§9).
- Third-party scripts are few, async, and reviewed (§15).

## SEO checks (added to seo-audit)
- A SPA's public pages are not reliably indexable. If any route must rank, move it to `astro` or `nextjs`, or pre-render it.
- Authenticated screens are `noindex`.
- `index.html` has a real title, description, viewport, and favicon. React 19 hoists `<title>` and `<meta>` set in components, but crawlers that do not run JavaScript still miss them.
- The host returns a real 404 status for unknown files (assets) and the SPA fallback only for app routes.

## Performance checks (added to performance-audit)
- Route-level code splitting is in place. Inspect the production bundle with a bundle visualizer that works with the installed Vite.
- Heavy dependencies (charts, editors, date and utility libraries) are lazy-loaded or replaced with lighter ones.
- TanStack Query settings avoid refetching on every mount and focus where data is stable.
- Long lists are virtualized or paginated.
- Images have dimensions, use modern formats, and are lazy-loaded below the fold. The LCP image is not lazy-loaded.
- Profile re-renders in React DevTools before adding `memo` or `useMemo`.
- Measure with Lighthouse against `vite build` plus `vite preview`, never the dev server.

## Accessibility checks (added to accessibility-audit)
- Client-side route changes update `document.title` and move focus to the new page heading or main region.
- Modals, menus, and toasts follow the WAI-ARIA patterns: focus moves in, is trapped while open, and returns to the trigger on close.
- Every form field has a visible `<label>`. Validation errors are tied to the field and announced.
- Loading and error states are announced with `role="status"` or `role="alert"`.
- `eslint-plugin-jsx-a11y` is on and `e2e/a11y.spec.ts` covers the main screens.

## Sources
- https://vite.dev/blog/announcing-vite8 (Vite 8, Node requirement)
- https://www.npmjs.com/package/create-vite (available templates)
- React, React Router, TanStack Query, Vitest, and MSW docs. Re-verify version-specific behavior before relying on it.
