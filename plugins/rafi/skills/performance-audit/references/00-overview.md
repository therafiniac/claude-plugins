# Performance Audit Standard (Generic, Portable)

A comprehensive, project-agnostic web performance checklist — Core Web
Vitals (Google), standard caching/asset-optimization practice, and
database/query performance principles. Framework-agnostic by design; copy
this single file into any codebase's `docs/` folder and use it as-is, same
pattern as `Security_Audit_Standard.md`/`SEO_Audit_Standard.md`. Framework-
specific implementation notes (e.g. Next.js's ISR, Server Components,
`next/image`) belong in a project-specific findings doc when this checklist
is actually run against a real codebase, not in this template.

**Intent**: the same as the other two standards — build and *maintain*
against every item here, and a later audit should find little. Re-run
whenever a new feature adds real data volume, a new third-party
dependency, or a new page pattern; periodically regardless.

## How to use this

1. Run each section against the real site — measure, don't guess. Several
   items require actual tooling (Lighthouse, WebPageTest, a real database
   `EXPLAIN`, browser DevTools' Performance/Network tabs), not a code read
   alone; mark those **Needs measurement** rather than assuming.
2. Mark each item **Pass**, **Fail**, **N/A** (one-line reason), or
   **Needs measurement**.
3. Log findings in §9, same living-log convention as the other standards.
4. Severity: **Critical** (site-breaking slowness, timeout, or a query
   that scales badly enough to eventually crash) / **High** (clearly
   outside target thresholds, real user impact) / **Medium** (measurable
   but limited impact) / **Low** (headroom/best-practice).
5. **Measure before optimizing, always.** Don't "fix" something that
   isn't shown to be slow — that's wasted effort and sometimes makes code
   worse for no real gain. Every fix in this checklist should trace back
   to an actual measurement.

---

