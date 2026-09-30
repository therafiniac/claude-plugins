## 5. Cryptography & Secrets Management

Maps to: OWASP ASVS V6, OWASP Top 10 A02:2021 (Cryptographic Failures),
CWE-321 (Hardcoded Crypto Key), CWE-326 (Inadequate Encryption Strength).

- [ ] All data in transit uses TLS 1.2+ (prefer 1.3), with weak ciphers/
      protocols (SSLv3, TLS 1.0/1.1, RC4, export ciphers) disabled at the
      server/load-balancer level.
- [ ] Sensitive data at rest (PII, financial data, health data, credentials)
      is encrypted using a current, vetted algorithm (AES-256-GCM or
      equivalent) — never a custom/home-rolled cipher.
- [ ] Secrets (API keys, DB credentials, signing keys, encryption keys) are
      never committed to version control. Confirm `.gitignore` covers
      `.env*` and any credentials file, and that `git log`/history doesn't
      already contain a leaked secret from before the ignore rule existed
      (a rotated key is required if one is found — removing it from a
      future commit doesn't remove it from history).
- [ ] Secrets are sourced from environment variables or a secrets manager
      (Vault, AWS/GCP/Azure secret managers, etc.), never hardcoded as a
      literal default (`SECRET = process.env.SECRET ?? "dev-secret"` is a
      finding — that fallback can silently ship to production).
- [ ] The app fails fast and loudly at startup if a required secret/env var
      is missing, rather than running with a weakened or undefined
      security posture.
- [ ] Cryptographic randomness (tokens, session IDs, password reset tokens,
      API keys) uses a CSPRNG (`crypto.randomBytes`,
      `crypto.getRandomValues`, `secrets` module, etc.) — never `Math.random()`
      or a language's default non-cryptographic PRNG for anything
      security-relevant.
- [ ] Signing keys (JWT, HMAC, cookie-signing) are of adequate length/
      algorithm strength, rotated periodically, and — for asymmetric JWTs
      — the verify step confirms the algorithm explicitly (never accept
      `alg: none`, and never let the client dictate which algorithm/key the
      server should verify with — the classic JWT `alg` confusion attack).
- [ ] Key management: encryption keys are stored separately from the data
      they protect, with restricted access, and there's a documented
      rotation plan.

