# Framework profile: React SPA + Express API
Kind: framework. Use for dashboards, admin tools, and apps behind login. For public, SEO-relevant content use the Next.js profile: an SPA serves crawlers an empty shell unless pre-rendered. Pair it with a database profile. With the MongoDB profile this is the classic MERN stack.

## Stack
pnpm workspaces monorepo: `apps/web` (React + Vite + TypeScript), `apps/api` (Express + TypeScript), `packages/shared` (Zod schemas and types used by both). Vitest, Playwright, Tailwind. Default hosting: Railway.

## Scaffold contract
- API layering: route → controller → service → repository. Only repositories touch the database.
- API feature folders: `src/features/<name>/{routes,controller,service,repo,schema,tests}`.
- `apps/api/src/config/env.ts`: Zod-validated env, fail fast at boot. Same in web (`VITE_` prefix only for public values).
- Central error middleware with a typed `AppError`, a `/health` endpoint, pino structured logging with request IDs, graceful shutdown.
- Root scripts fan out to workspaces: `dev`, `build`, `typecheck`, `lint`, `test`, `check`, plus `test:e2e` (`playwright test`).
- Also: `packageManager`, `.nvmrc`, Prettier, ESLint, Vitest, supertest for API integration tests, `.env.example` per app, one passing test.
- E2E dev dependencies: `@playwright/test`, `@axe-core/playwright`. Playwright `webServer` starts both the API and the built web app. Reuse the `a11y.spec.ts` pattern from the Next.js profile for the main screens.
- No `lighthouse` script by default. Add `@lhci/cli` only if the app has public pages.

## Conventions
- Every request body, param, and query is validated by a Zod schema from `packages/shared` through a validation middleware. The web app reuses the same schema for form validation.
- Never return raw database records. Map to DTOs (no password hashes or internal fields).
- Auth: short-lived access token plus rotating refresh token, in `HttpOnly`, `Secure`, `SameSite` cookies. Authorization in one shared middleware or policy function, default deny.
- Pagination on every list endpoint with a capped page size.
- React: server state in a query library (TanStack Query), not global stores. Routes lazy-loaded.

## Security checks (added to security-audit)
- `helmet` enabled and `x-powered-by` removed.
- CORS uses an explicit origin allowlist. Never `*` with credentials.
- `express.json({ limit })` set. Rate limiting on auth, password reset, search, and email-sending routes.
- `trust proxy` set to the real hop count behind Railway's proxy, so rate limiting keys on the true client IP (§6). Confirm the origin is not reachable around the proxy.
- Cookie-authenticated mutations: SameSite plus Origin check, or a CSRF token.
- Error middleware never returns stack traces in production.
- Refresh-token reuse detection. Logout revokes server-side (§2).
- Tokens never in `localStorage`.

## SEO checks (added to seo-audit)
- SPA pages are not reliably indexable. For any public route, confirm pre-rendering, or move that content to a Next.js app.
- Logged-in areas are `noindex`.
- Per-route titles and meta must be present in the served HTML, not only after JS runs.

## Performance checks (added to performance-audit)
- Route-level code splitting with `React.lazy`. Inspect the bundle with a visualizer.
- Compression via `compression` middleware or at the proxy.
- Profile React re-renders before adding memoization.

## Accessibility checks (added to accessibility-audit)
- Client-side route changes update `document.title` and move focus to the new page heading or main region.
- Modals, menus, and toasts follow the WAI-ARIA Authoring Practices patterns: focus moves in, is trapped while open, and returns to the trigger on close.
- Every form field has a visible `<label>`. Validation errors are associated with the field and announced.
- Data tables use real `<table>` markup with header cells.
