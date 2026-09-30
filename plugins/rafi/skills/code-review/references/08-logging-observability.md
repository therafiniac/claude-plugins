## 8. Logging & Observability

- Log meaningful events: errors, auth failures, key business actions — not everything, and never secrets/PII.
- Use log levels appropriately (debug/info/warn/error) rather than logging everything at the same level.
- Include enough context in an error log to debug without reproducing (relevant IDs, operation name) — but never raw request bodies containing sensitive data.
- In a real production setup, note where structured logging or a monitoring/alerting tool would matter, even if not implemented in a prototype.

---

