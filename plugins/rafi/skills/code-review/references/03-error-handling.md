## 3. Error Handling

- Anticipate failure at every I/O boundary: network calls, database queries, file access, external APIs, third-party SDKs.
- Every error path returns a **meaningful, actionable** message to the caller — never a raw stack trace or internal exception to the client.
- Distinguish error types explicitly and map each to the correct response: validation error, not-found, unauthorized, conflict, rate-limited, server error. Don't collapse everything into a generic 500 or a generic `catch(e)`.
- Only retry operations that are safe to retry (idempotent). Never blindly retry a write or payment operation.
- Fail loudly and with detail in development; fail safely and vaguely (to the client) in production, while still logging full detail server-side.
- No empty `catch` blocks, no swallowed errors, no silent failures.

---

