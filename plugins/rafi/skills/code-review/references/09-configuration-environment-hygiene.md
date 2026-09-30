## 9. Configuration & Environment Hygiene

- No environment-specific values (URLs, keys, ports) hardcoded in source — use environment variables or config files.
- Provide a `.env.example` listing required variables without real values.
- Fail fast and clearly at startup if a required environment variable is missing, rather than failing obscurely later.
- Keep development, staging, and production configuration cleanly separated.

---

