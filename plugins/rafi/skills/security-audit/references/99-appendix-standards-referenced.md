## Appendix: Standards Referenced

- **OWASP Top 10 (2021)** — the ten most critical web application risk
  categories, industry-standard starting point.
- **OWASP ASVS (Application Security Verification Standard)** — a much
  more granular, testable checklist (v4+ has ~280 requirements across 14
  categories); this doc pulls from and summarizes its most impactful items
  rather than reproducing it in full. Consult ASVS directly for a
  Level 2/3 (higher-assurance) audit.
- **OWASP API Security Top 10** — API-specific risk categories (broken
  object-level authorization, broken authentication, excessive data
  exposure, lack of rate limiting, etc.) — most already folded into §3/§6
  above.
- **CWE/SANS Top 25 Most Dangerous Software Weaknesses** — a
  vulnerability-pattern-level list (as opposed to OWASP's risk-category
  framing); CWE IDs are cited inline above so a finding can be cross-
  referenced.
- **NIST SP 800-53 / NIST SSDF (Secure Software Development Framework)** —
  broader organizational/process controls; relevant subset (secrets
  management, CI/CD, dependency management) folded into §5/§9/§14.
