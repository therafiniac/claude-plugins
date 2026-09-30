## 6. API & Server-Side Security

Maps to: OWASP API Security Top 10, CWE-352 (CSRF), CWE-770 (Missing
Resource Limits).

- [ ] State-changing requests (POST/PUT/PATCH/DELETE, or any equivalent
      mutation) that rely on cookies for auth are protected against CSRF —
      via a framework's built-in same-origin/anti-CSRF-token mechanism, or
      an explicit CSRF token validated server-side. (Note: pure
      Authorization-header/bearer-token auth without cookies is inherently
      less CSRF-exposed, but confirm that's actually the auth model in use
      before relying on it as the mitigation.)
- [ ] CORS policy is an explicit allowlist of trusted origins — never
      `Access-Control-Allow-Origin: *` combined with
      `Access-Control-Allow-Credentials: true` (that combination leaks
      authenticated data to any origin).
- [ ] Rate limiting exists on all expensive or sensitive endpoints:
      authentication, password reset, search, anything calling a paid
      third-party API, and any endpoint that sends email/SMS (abuse/spam
      vector otherwise).
- [ ] The client identity used as a rate-limit key can't be forged: behind
      a proxy/CDN, read the header that proxy sets and overwrites (e.g.
      `CF-Connecting-IP`), or the right-most `X-Forwarded-For` entry added
      by a trusted hop — never the left-most entry, which the client
      controls. Confirm the origin isn't reachable around the proxy.
- [ ] Framework/server fingerprinting headers (`X-Powered-By`, `Server`
      version strings) are removed.
- [ ] Every endpoint that returns a list enforces pagination with a
      maximum page size — no endpoint can be asked to return an unbounded
      result set (DoS via resource exhaustion, and often an accidental
      mass-data-exposure vector).
- [ ] Request body size limits are enforced (prevents memory-exhaustion
      DoS from oversized payloads).
- [ ] API responses never include more data than the client needs —
      check for accidental over-fetching (returning a full internal user
      object including password hash/internal flags when only
      name+avatar were needed).
- [ ] HTTP methods are restricted to what each endpoint actually needs
      (no `TRACE`/`TRACK` enabled if unused; `OPTIONS` doesn't leak more
      than intended).
- [ ] Security headers are set: `Content-Security-Policy` (restricts
      script/style/resource origins — the strongest single XSS mitigation
      at the platform level), `X-Content-Type-Options: nosniff`,
      `X-Frame-Options: DENY` or `frame-ancestors 'none'` in CSP
      (clickjacking prevention), `Strict-Transport-Security` (HSTS, forces
      HTTPS on future visits), `Referrer-Policy` (avoid leaking sensitive
      URLs to third parties).
- [ ] GraphQL (if used): query depth/complexity limiting is in place
      (prevents a single deeply-nested query from causing a DoS), and
      introspection is disabled in production unless deliberately public.

