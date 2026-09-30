# SEO Audit Standard (Generic, Portable)

A comprehensive, project-agnostic SEO checklist aligned to current search
engine guidance — Google Search Central's documented ranking factors and
best practices, Core Web Vitals thresholds, schema.org structured data,
and standard technical-SEO practice. Contains no project-specific content
— copy this single file into any codebase's `docs/` folder and use it
as-is, the same way `Security_Audit_Standard.md` works.

**Intent**: the same as the security standard — if a site is built and
*maintained* against every item here, a later audit should find close to
nothing. Re-run whenever site structure changes (new content type, new
route pattern, a redesign) and periodically regardless (e.g. quarterly).

## How to use this

1. Point an audit at this file and go through every section against the
   real site — citing actual URLs/files/values, never a generic "looks
   fine."
2. Mark each item **Pass**, **Fail**, **N/A** (with a one-line reason), or
   **Needs manual verification** (things that need a live tool — Search
   Console, PageSpeed Insights, a real crawl — not just a code read).
3. Log findings in §11, same living-log convention as the security doc.
4. Severity: **Critical** (blocks indexing/ranking entirely — e.g. an
   accidental sitewide `noindex`) / **High** (meaningfully hurts
   visibility — broken structured data, missing canonical on duplicate
   content) / **Medium** (real but limited impact) / **Low**
   (best-practice polish).

---

