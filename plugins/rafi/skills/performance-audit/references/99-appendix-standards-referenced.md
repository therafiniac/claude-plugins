## Appendix: Standards Referenced

- **Core Web Vitals** (Google) — LCP/INP/CLS, shared reference point with
  `SEO_Audit_Standard.md` §4; thresholds are periodically revised, verify
  current ones rather than trusting this doc indefinitely.
- **HTTP Caching (RFC 9111)** — the underlying spec behind
  `Cache-Control`/`stale-while-revalidate` semantics referenced in §3.
- General database performance practice (query planning, indexing,
  connection pooling) — largely universal across relational databases;
  exact tooling (`EXPLAIN` syntax, pooler choice) differs by engine.
