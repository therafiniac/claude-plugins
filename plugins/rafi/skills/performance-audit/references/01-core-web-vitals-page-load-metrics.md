## 1. Core Web Vitals & Page-Load Metrics

Same thresholds as `SEO_Audit_Standard.md` §4 (performance is a shared
concern between the two docs — don't duplicate that checklist here, just
cross-reference it):

- [ ] LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 — measured via real-user field data
      (Search Console's Core Web Vitals report, or an equivalent RUM tool),
      not lab data alone. Lab tools (Lighthouse) are useful for
      *debugging* a slow page, but field data is what actually reflects
      real visitors on real networks/devices.
- [ ] Time to First Byte (TTFB) is reasonable (~<600ms) — a slow TTFB
      usually points at server/database work happening before any HTML
      can start streaming, not a frontend problem.
- [ ] Total JS shipped to the client is proportionate to the page — check
      bundle size in DevTools' Network tab or a bundle analyzer; a simple
      content page shouldn't ship as much JS as a complex interactive one.

