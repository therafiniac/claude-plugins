## 2. Security — Non-Negotiable, In Priority Order

Apply these by default. Do not skip them for speed unless I explicitly say so.

1. **Authorization on every resource access** — never assume "logged in" is enough. Confirm the actor owns or is permitted to act on *this specific resource* before any read, update, or delete.
2. **Validate all input at every boundary** — API requests, form submissions, URL params, environment variables, file uploads. Never trust client-side validation alone.
3. **Never hardcode secrets** — API keys, DB credentials, tokens. Use environment variables or a secrets manager. Never commit `.env` files; always provide `.env.example` instead.
4. **Hash passwords properly** (bcrypt/argon2/scrypt) — never store plaintext or use reversible encryption for passwords.
5. **Prevent injection** — parameterized queries only, never string-concatenated SQL/NoSQL queries or shell commands built from user input.
6. **Escape/encode output** to prevent XSS — anywhere user input is rendered back into HTML, sanitize it.
7. **Use HTTPS and secure cookie flags** (`HttpOnly`, `Secure`, `SameSite`) wherever sessions or tokens are involved.
8. **CSRF protection** on any state-changing request that relies on cookies for auth.
9. **Least privilege** — a service, function, or DB user should only have the access it strictly needs, nothing broader "for convenience."
10. **Rate limit** sensitive or expensive endpoints (auth, search, anything calling paid external APIs).
11. **Never log secrets, passwords, tokens, or full card/PII data** — even in debug logs.
12. **Keep dependencies current** — flag known-vulnerable or deprecated packages if you notice them; don't silently pull in unmaintained libraries for a trivial task.

---

