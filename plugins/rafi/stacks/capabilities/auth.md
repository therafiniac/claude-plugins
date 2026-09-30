# Capability: Auth
Kind: capability
Ask when: people log in: admins, members, or customers. Skip for public content sites whose only editor uses a git-based CMS, and for `wordpress` (it has its own users).
Default: nextjs, react-express, astro with an adapter → better-auth. Choose clerk only when a hosted service and its per-user pricing are acceptable.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| better-auth | adopt | Default. Self-hosted TypeScript library, users stored in your own database. Email and password, OAuth, 2FA, organizations through plugins | nextjs, astro (on-demand routes), react-express; postgres or mongodb | free |
| clerk | trial | You want hosted auth with prebuilt UI and user management, and accept the vendor and per-user pricing | nextjs, react-spa, astro, react-express | free tier, then per monthly active user |
| authjs | hold | Do not start new projects with it. Auth.js (NextAuth) is maintained by the Better Auth team in maintenance mode, with a migration guide to Better Auth | — | — |
| lucia | hold | Do not use. The library was deprecated in March 2025 and is now a learning resource for writing sessions by hand | — | — |

## Option: better-auth
Setup: `better-auth` with the database adapter that matches the database profile. One server instance in `src/lib/auth.ts`, the framework's route handler mounted at its API path, and a client in `src/lib/auth-client.ts`. Generate its tables with the Better Auth CLI, then apply them through your database profile's migration flow. Env: `BETTER_AUTH_SECRET`, `BETTER_AUTH_URL`.
Conventions:
- Enable only the sign-in methods the PRD needs. Each plugin (2FA, organizations, passkeys) is a deliberate choice recorded in an ADR.
- Read the session on the server in every protected route, server action, and API handler through one helper (`requireUser()`), never from client state.
- Email verification and password reset need the email capability.
Security checks (added to security-audit):
- Every protected route, action, and handler checks the session and then ownership of the resource. Middleware alone is not enough (§3).
- Session cookies are `HttpOnly`, `Secure`, and `SameSite`; `trustedOrigins` lists only your origins (§2, §6).
- Sign-in, sign-up, and password-reset endpoints are rate limited (§1, §13).
- `BETTER_AUTH_SECRET` and OAuth client secrets are server-only env vars (§5).
- OAuth redirect URIs are registered as exact URLs, never wildcards (§1, §15).
- Password reset and email verification tokens are single-use and expire (§1).
Accessibility checks (added to accessibility-audit):
- Auth fields use `autocomplete` (`username`, `email`, `current-password`, `new-password`, `one-time-code`), and paste is never blocked, so password managers work (§3).
- No cognitive test is required to log in (WCAG 3.3.8) (§3).
- Errors are specific enough to act on, linked to their fields, and announced (§3, §5).
Sources: https://better-auth.com/docs, https://better-auth.com/blog/authjs-joins-better-auth

## Option: clerk
Setup: the Clerk SDK for the framework (`@clerk/nextjs`, `@clerk/astro`, `@clerk/clerk-react`, or `@clerk/express`), its middleware, and the publishable and secret keys.
Conventions:
- Keep your own `users` table keyed by the Clerk user ID for app data. Sync it from Clerk's webhooks.
- Authorization (who may touch which record) stays in your code. Clerk only tells you who the user is.
Security checks (added to security-audit):
- Every protected server route checks the Clerk session and then resource ownership (§3).
- The Clerk webhook verifies its signature before writing to your database (§15).
- The secret key is server-only; only the publishable key reaches the browser (§5).
Accessibility checks (added to accessibility-audit):
- Clerk's prebuilt components are checked with axe on your pages like any other UI (§4).
Sources: https://clerk.com/docs
