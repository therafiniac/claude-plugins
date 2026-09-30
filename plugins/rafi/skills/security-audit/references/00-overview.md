# Security Audit Standard (Generic, Portable)

A comprehensive, project-agnostic security checklist aligned to industry
standards — OWASP Top 10 (2021), OWASP ASVS (Application Security
Verification Standard), OWASP API Security Top 10, CWE/SANS Top 25 Most
Dangerous Software Weaknesses, and NIST SP 800-53 / NIST Secure Software
Development Framework (SSDF) control families. It contains no
project-specific content — copy this single file into any codebase's
`docs/` folder and use it as-is.

**Intent**: if a codebase is built and *maintained* against every item here,
a later audit against this same checklist should find close to nothing.
This is a maintenance standard, not a one-time cleanup list — re-run it
whenever the codebase changes shape (new auth mechanism, new integration,
new data type handled) and periodically regardless (e.g. quarterly, or
before any major release).

## How to use this

1. Point an audit (yourself, a teammate, or an AI coding agent) at this file
   and ask it to run through every section against the actual codebase,
   citing real file paths/line numbers for each finding — never a generic
   "looks fine."
2. For each checklist item: mark it **Pass**, **Fail**, **N/A** (with a
   one-line reason it doesn't apply), or **Needs manual verification**
   (things a static read of the code can't fully confirm — e.g. "is TLS
   actually enforced at the load balancer").
3. Log every Fail/Needs-verification item in §16 (Findings Log) with a
   date, severity, and status. Don't delete resolved findings — mark them
   Fixed with a date so the log doubles as a history.
4. Severity scale used throughout: **Critical** (remote, unauthenticated,
   full compromise or data breach) / **High** (auth bypass, privilege
   escalation, significant data exposure) / **Medium** (requires
   preconditions, limited blast radius) / **Low** (defense-in-depth,
   hardening, best-practice gaps).

This checklist assumes a typical web application (frontend + backend +
database, possibly with third-party integrations). Skip sections that
genuinely don't apply (e.g. §11 File Uploads for an app with none) and mark
them N/A rather than deleting them — a future audit should see the section
was considered, not omitted.

---

