## 10. Configuration & Infrastructure Hardening

Maps to: OWASP Top 10 A05:2021 (Security Misconfiguration), CIS Benchmarks.

- [ ] Debug mode, verbose error pages, and admin/dev tooling (e.g. a
      framework's debug console) are confirmed **off** in production —
      test this doesn't accidentally get re-enabled by an env var
      defaulting the wrong way.
- [ ] Default credentials on any component (database, admin panel,
      message queue, cache) are changed before deployment — grep infra
      config for default usernames like `admin`/`root` paired with a
      default or empty password.
- [ ] Unnecessary services/ports are disabled — the deployed surface
      exposes only what's actually needed (e.g. a database shouldn't be
      reachable from the public internet if only the app server needs it).
- [ ] Principle of least privilege applied to every service account/DB
      user/IAM role — a web app's DB user shouldn't have `DROP TABLE`
      rights if it only ever needs `SELECT`/`INSERT`/`UPDATE` on specific
      tables; a CI pipeline's cloud credentials shouldn't have
      account-wide admin access.
- [ ] Environment separation is real, not just naming — dev/staging/
      production use genuinely separate credentials, databases, and
      secrets; a staging leak shouldn't expose production data.
- [ ] Cloud storage buckets (S3 or equivalent) default to private, with
      public access explicitly opted into per-object/per-bucket only where
      truly needed, and that choice is periodically re-verified (bucket
      misconfiguration is one of the most common real-world breach causes).
- [ ] Directory listing is disabled on web servers; no `.git`, `.env`,
      backup files (`.bak`, `~`), or config files are reachable via a
      direct URL request.
- [ ] Software/OS/runtime versions are kept current with security patches
      — there's a defined process (not just "whenever someone notices"),
      even if lightweight for a small team.

