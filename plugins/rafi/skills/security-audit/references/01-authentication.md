## 1. Authentication

Maps to: OWASP ASVS V2, OWASP Top 10 A07:2021 (Identification &
Authentication Failures), CWE-287, CWE-798, CWE-521.

- [ ] Passwords are hashed with a modern, slow, salted algorithm — bcrypt,
      scrypt, or Argon2id. Never MD5/SHA1/SHA256 alone (too fast, brute-
      forceable), never reversible encryption, never plaintext.
- [ ] Password comparison uses a timing-safe/constant-time compare, not `==`
      or `===` on the hash output.
- [ ] Minimum password strength policy enforced server-side (length is the
      most effective single control — NIST 800-63B recommends ≥8 chars
      minimum, no forced complexity rules, no forced periodic rotation).
- [ ] No hardcoded credentials, API keys, or default passwords anywhere in
      source — grep for common patterns (`password =`, `apiKey =`,
      `secret =` followed by a literal string) and CI-gate this if possible
      (e.g. `git-secrets`, `trufflehog`, `gitleaks`).
- [ ] Every login failure returns a generic error — never reveal whether
      the *username* or the *password* was wrong (prevents account
      enumeration).
- [ ] Login is rate-limited / throttled per account and per IP, with
      exponential backoff or a temporary lockout after N failed attempts.
      Lockout itself shouldn't be usable as a DoS vector against a known
      username (consider CAPTCHA or increasing delay instead of hard
      lockout for public-facing auth).
- [ ] Multi-factor authentication (MFA/2FA) is available, and required for
      any admin/privileged account at minimum.
- [ ] Password reset flow: reset tokens are single-use, time-limited (e.g.
      ≤1 hour), cryptographically random (not predictable/sequential), and
      invalidated after use or after a new password is set. The "check your
      email" response is identical whether or not the email exists in the
      system.
- [ ] "Remember me" / persistent login tokens are not the same as the
      session token itself — a separate, revocable, hashed-at-rest token.
- [ ] Service-to-service and API authentication uses proper credentials
      (API keys, mTLS, OAuth client credentials) — never a shared static
      secret hardcoded in client-side code.
- [ ] SSO/OAuth/OIDC integrations validate the `state` parameter (CSRF
      protection for the auth flow) and validate the token signature/issuer/
      audience — never trust an unsigned or unverified token claim.

