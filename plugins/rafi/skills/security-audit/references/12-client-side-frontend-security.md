## 12. Client-Side / Frontend Security

Maps to: OWASP ASVS V5, CWE-79 (XSS variants), CWE-1004.

- [ ] No sensitive data (auth tokens, PII) is stored in `localStorage` or
      `sessionStorage` if avoidable — these are readable by any script on
      the page (i.e. any XSS becomes full token theft). Prefer `HttpOnly`
      cookies for auth tokens specifically.
- [ ] A Content-Security-Policy is set restrictively enough to meaningfully
      reduce XSS impact (avoid `unsafe-inline`/`unsafe-eval` where
      possible; if genuinely needed, scope with nonces/hashes instead of a
      blanket allowance).
- [ ] Third-party scripts (analytics, chat widgets, ad tags) are loaded
      with Subresource Integrity (`integrity` attribute) where served from
      a CDN, so a compromised CDN can't silently inject malicious code.
- [ ] Client-side routing/state doesn't trust URL/query parameters as an
      authorization signal (e.g. `?role=admin` in the URL should never
      change what the UI *can* do, only at most what it optimistically
      *shows* pending a real server check).
- [ ] Autocomplete is disabled on sensitive fields where appropriate
      (`autocomplete="off"` on things like a one-time payment CVV), and
      password fields use `type="password"`.
- [ ] postMessage handlers (if used for cross-frame/cross-window
      communication) validate `event.origin` before trusting the message
      content.

