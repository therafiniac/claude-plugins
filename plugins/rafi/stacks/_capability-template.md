# Capability: <Concern>
Kind: capability
Ask when: <the condition under which bootstrap or brainstorm raises this concern, e.g. "the project has any UI">
Default: <per framework profile name → option, e.g. "astro → lucide; nextjs, react-spa, react-express → lucide; wordpress → skip">
Verified: <month year>. Re-verify the chosen option in its official docs before scaffolding.

Notes for whoever fills this in:
- One file per concern. 2 to 5 options. Curate; do not list every package that exists.
- Status: `adopt` (safe default), `trial` (good when its "Pick when" fits; verify more carefully), `hold` (do not start new projects with it; keep only to explain why).
- "Works with" uses profile names from `stacks/frameworks/` and `stacks/databases/`, or `any`.
- Everything above the first `## Option:` heading is the summary that bootstrap and brainstorm read. Keep it short.
- Each option section is copied into the project's `docs/stack-profile.md` when chosen, together with the file's `## Shared` section if there is one. So an option must never say "same as <other option>". Put rules common to all options in `## Shared`, after the last option.
- "Works with" holds only profile names, `any`, and short qualifiers such as "(on-demand routes)" or "(React islands)". Package names go in Setup.
- Every rule must be specific and checkable. Point audit checks at the standard's section number.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| <name> | adopt | <one line> | <profiles> | <free / hosted plan / self-host> |

## Option: <name>
Setup: <packages with the reason for each, config files, scripts>.
Conventions:
- <rules Claude follows when writing code with this option>
Security checks (added to security-audit):
- <check> (§n)
Performance checks (added to performance-audit):
- <check>
Accessibility checks (added to accessibility-audit):
- <check>
SEO checks (added to seo-audit, if relevant):
- <check>
Sources: <official documentation URLs>

## Shared
<Optional. Conventions and audit checks that apply whichever option is chosen. Copied into the project with the chosen option.>
