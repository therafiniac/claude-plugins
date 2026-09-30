## 13. Business Logic & Abuse Prevention

Maps to: OWASP Top 10 A04:2021 (Insecure Design).

- [ ] Multi-step workflows (checkout, signup, approval flows) can't be
      abused by skipping steps directly via a later-step API call (e.g.
      calling the "complete order" endpoint without having gone through
      payment validation).
- [ ] Numeric/quantity fields (price, quantity, discount %) are re-validated
      and re-derived server-side at the point of the actual transaction —
      never trust a client-submitted price or discount value.
- [ ] Race conditions in state-changing operations (e.g. redeeming a
      one-time coupon, withdrawing funds) are prevented via proper
      locking/transactions/idempotency keys — test what happens if the
      same request fires twice concurrently.
- [ ] Only idempotent operations are safely retryable; write/payment
      operations use an idempotency key so a network-retry can't
      double-charge or double-create.
- [ ] Automated abuse (scraping, credential stuffing, bulk account
      creation) is mitigated at the points that matter — rate limiting,
      CAPTCHA on high-value actions, anomaly detection on login patterns.

