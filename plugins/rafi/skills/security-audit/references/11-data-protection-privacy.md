## 11. Data Protection & Privacy

Maps to: GDPR/CCPA-style principles (apply proportionally to actual data
sensitivity and jurisdiction — not every app needs every control here),
OWASP ASVS V8.

- [ ] Personal data collected is limited to what's actually needed
      (data minimization) — don't collect/store a field "just in case."
- [ ] Sensitive PII (SSNs, full payment card numbers, health data) is
      never stored unless there's a genuine business need — for payment
      cards specifically, prefer a PCI-compliant processor/tokenization so
      raw card data never touches your own servers at all.
- [ ] There's a defined data retention policy, and a way to actually
      delete a user's data on request (not just soft-delete/hide it from
      the UI while it persists in the database indefinitely).
- [ ] Data exports/backups are encrypted and access-controlled the same as
      production data — a backup is not a lesser security boundary.
- [ ] Third-party analytics/tracking scripts don't receive PII
      inadvertently (e.g. an email address leaking into a URL that gets
      logged by an analytics provider).
- [ ] If the app serves users under applicable privacy regulations
      (GDPR, CCPA, etc.), confirm the legal/consent requirements
      (cookie consent, right-to-access, right-to-erasure) are actually
      implemented, not just described in a privacy policy.

