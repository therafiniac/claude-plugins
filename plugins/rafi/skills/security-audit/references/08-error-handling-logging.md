## 8. Error Handling & Logging

Maps to: OWASP ASVS V7, CWE-209 (Information Exposure Through Error
Message), CWE-532 (Insertion of Sensitive Info into Log File).

- [ ] Production error responses are generic and actionable to the
      *caller*, never a raw stack trace, internal file path, SQL error, or
      library version string — that detail goes to server-side logs only.
- [ ] Errors are mapped to the correct type/status: validation error,
      not-found, unauthorized, forbidden, conflict, rate-limited, server
      error — never everything collapsed into a generic 500.
- [ ] No secrets, passwords, full tokens, session IDs, or full card/PII
      data are ever written to logs — even at debug level. Redact/mask
      where a log needs to reference the *existence* of such data (e.g.
      log a user ID, not their email+password together).
- [ ] Logs include enough context to investigate an incident without
      reproducing it (request ID, user ID, operation name, timestamp) —
      but are structured, not raw request/response bodies dumped
      wholesale.
- [ ] Authentication failures, authorization failures, and other
      security-relevant events (password changes, role changes, account
      lockouts) are logged distinctly from routine application logs, so
      they can be monitored/alerted on.
- [ ] Logs are protected from tampering/deletion by the same users they
      might incriminate (write-once storage, centralized log shipping,
      restricted access to raw log files).
- [ ] No empty `catch` blocks, no silently swallowed exceptions — every
      caught error either handles the failure meaningfully or re-throws/
      logs it.

