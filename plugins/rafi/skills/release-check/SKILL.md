---
name: release-check
description: Pre-release gate. Full checks and all four audits.
disable-model-invocation: true
---
1. Run `pnpm check` and `pnpm build`. Run `pnpm test:e2e` and `pnpm lighthouse` if those scripts exist.
2. Invoke the `rafi:security-audit`, `rafi:performance-audit`, and `rafi:accessibility-audit` skills with `full`. Also invoke `rafi:seo-audit` with `full` unless the site has no public pages.
3. Report Critical and High findings only, and confirm each log in `docs/audits/` is updated. End with a verdict: ship or hold, with blockers listed.
4. Remind me of the manual checks: Search Console, Lighthouse field data, keyboard and screen-reader pass on core flows, env vars set in hosting, rollback plan.
5. Last line: `Next:` on ship, do the manual checks above, then merge and deploy. On hold, `/rafi:fix-issue <first blocker>`, then run `/rafi:release-check` again. It is only a suggestion. Never run it.
