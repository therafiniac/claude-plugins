## 15. Third-Party Integrations

Maps to: OWASP ASVS V9, general vendor risk management.

- [ ] Webhooks received from third parties verify a signature (HMAC or
      equivalent) before trusting the payload — never process a webhook
      body as authoritative without verifying it actually came from the
      claimed sender.
- [ ] API keys for third-party services are scoped to the minimum
      permission the integration actually needs (a read-only key where
      only reads happen), and stored/rotated per §5.
- [ ] Data sent to third-party services (analytics, error-tracking tools
      like Sentry, AI APIs) is reviewed for accidental PII/secret leakage
      — e.g. confirm error-tracking scrubs request bodies/headers before
      upload.
- [ ] SDKs/libraries for third-party services are kept current (same as
      §9) — a vulnerable SDK is as much a supply-chain risk as any other
      dependency.

