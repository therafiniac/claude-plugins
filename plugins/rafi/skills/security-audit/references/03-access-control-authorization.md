## 3. Access Control / Authorization

Maps to: OWASP Top 10 A01:2021 (Broken Access Control), OWASP ASVS V4,
CWE-862 (Missing Authorization), CWE-863 (Incorrect Authorization),
CWE-639 (IDOR).

- [ ] **Every** data-access/mutation entry point independently verifies the
      caller is authorized for *that specific action on that specific
      resource* — never assume "the UI hid the button" or "the page-level
      guard already checked" is sufficient. This is the single most common
      real-world access-control failure: a server action/API endpoint/RPC
      handler is reachable directly (its address/name is often visible in
      client bundles or network logs) even when no UI links to it.
- [ ] Object-level authorization (IDOR check): when a request includes an
      ID (order ID, user ID, document ID, etc.), the server confirms the
      *authenticated caller* owns or is permitted to act on *that specific
      ID* — not just that the ID exists. Test by substituting another
      valid ID belonging to a different account.
- [ ] Role/permission checks happen server-side, on every request, not
      cached client-side or trusted from a client-supplied claim (e.g.
      never trust a `role: "admin"` field sent in a request body).
- [ ] Authorization logic is centralized (a shared function/middleware/
      policy engine) rather than reimplemented ad hoc per route — ad hoc
      duplication is where checks get silently forgotten as the codebase
      grows. If it isn't centralized, that itself is a finding.
- [ ] Privilege escalation paths are tested: can a low-privilege user
      change their own role, or another user's role, via a
      profile-update endpoint that wasn't meant to allow it (mass-
      assignment vulnerability, CWE-915)?
- [ ] Default-deny posture: new routes/fields/actions require explicit
      authorization to be added, rather than being open by default until
      someone remembers to lock them down.
- [ ] Admin/back-office interfaces are not reachable without authentication
      even if "nobody would guess the URL" — no security through obscurity
      as the sole control.
- [ ] Multi-tenant systems: verify tenant isolation at the data-access
      layer itself (e.g. every query scoped by `tenant_id` derived from the
      authenticated session, never from a client-supplied parameter).

