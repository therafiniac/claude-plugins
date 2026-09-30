# Accessibility Audit Standard (Generic, Portable)

A project-agnostic web accessibility checklist aligned to WCAG 2.2 Level AA, the WAI-ARIA Authoring Practices, and standard assistive-technology testing practice. Framework-agnostic by design. Framework-specific notes belong in the project's stack profile.

**Intent**: the same as the other standards. If a UI is built and *maintained* against every item here, a later audit should find little. Re-run whenever a new page pattern, form, or interactive widget ships, and periodically regardless.

## How to use this

1. Run automated checks first (axe through Playwright, or the browser extension). Automated tools find only part of the issues. Keyboard use, screen reader behavior, zoom, and content quality need a human.
2. Mark each item **Pass**, **Fail**, **N/A** (one-line reason), or **Needs manual verification**.
3. Log findings in `docs/audits/accessibility.md` with the columns `Date | Section | Finding | Severity | Status`.
4. Severity: **Critical** (a keyboard or assistive-technology user cannot complete a core task) / **High** (a WCAG Level A failure, or a Level AA failure with no workaround) / **Medium** (a Level AA failure with a workaround) / **Low** (best-practice gap).
5. Prefer native HTML over ARIA. No ARIA is better than incorrect ARIA.

---

