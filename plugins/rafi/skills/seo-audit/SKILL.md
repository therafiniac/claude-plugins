---
name: seo-audit
description: Run the SEO audit standard against this site. Use only when asked to SEO-audit, or to check metadata, indexing, structured data, or crawlability.
argument-hint: "[diff | full | path or feature]"
context: fork
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git status)
---
Scope: $ARGUMENTS. Blank or `diff` = current branch vs main. `full` = whole site. Anything else = a path or route.

Reference files live in `${CLAUDE_PLUGIN_ROOT}/skills/seo-audit/references/`, named by section number.

## Pick sections
Read `00-overview.md` there. Then read only the files for matching sections:

| Change | Sections |
|---|---|
| New public page or route | 1, 2, 3, 6 |
| New content type, list, or pagination | 1, 2, 3, 6, 7 |
| Images, fonts, layout | 4, 5 |
| Redesign or URL changes | all (check redirects in 6) |
| Multiple languages | 9 |
| `full`, pre-launch, quarterly | all |

If `docs/stack-profile.md` exists, also apply its SEO checks.

## Method
- Judge every in-scope item: Pass, Fail, N/A (one-line reason), or Needs manual verification.
- Check rendered HTML and response headers, not only source. Use the running app or a local build if available.
- Items needing Search Console, PageSpeed Insights, or a live crawl are Needs manual verification. Do not guess them.
- Cite `file:line` or URL for every Fail. Report only. Do not edit code.

## Output
1. Create or update `docs/audits/seo.md` with one row per Fail or Needs-verification item: `Date | Section | Finding | Severity | Status`. Never delete rows. Mark resolved rows Fixed with the date.
2. Reply with only Fail and Needs-verification items, grouped by severity, one line each. Maximum 30 lines.
3. Last line: `Next:` plus one step. A Critical or High finding: `/rafi:fix-issue <that finding>`. Only Needs-verification items: do those checks by hand. Nothing found: continue what I was doing. If another command called this audit, that command gives the final next step instead. It is only a suggestion. Never run it.
