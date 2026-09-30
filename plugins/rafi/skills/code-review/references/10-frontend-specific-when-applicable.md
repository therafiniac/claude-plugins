## 10. Frontend-Specific (when applicable)

- Design and handle all four UI states: loading, success, empty, and error — not just the happy path.
- Validate and sanitize any user input before it's rendered or sent.
- Keep accessibility in mind by default: semantic HTML, keyboard navigability, sufficient color contrast, alt text for meaningful images.
- Don't store sensitive data (tokens, PII) in `localStorage`/`sessionStorage` if it can be avoided — prefer secure, `HttpOnly` cookies for auth tokens.
- Keep state ownership deliberate: local UI state vs. shared state vs. server-derived state vs. URL state — don't default everything into one global store.

---

