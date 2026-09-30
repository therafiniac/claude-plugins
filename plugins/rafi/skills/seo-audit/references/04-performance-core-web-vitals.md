## 4. Performance & Core Web Vitals

Google uses these as a direct (if modest-weight) ranking signal, and they
correlate strongly with user experience regardless.

- [ ] **LCP (Largest Contentful Paint)** — target ≤2.5s. Usually the
      hero image or largest text block; optimize by preloading/priority-
      loading the LCP element, using a properly-sized (not oversized)
      image, and avoiding render-blocking resources above it.
- [ ] **INP (Interaction to Next Paint)** — target ≤200ms (replaced FID as
      the responsiveness metric). Avoid long JS tasks blocking the main
      thread on user interaction; break up heavy work, defer non-critical
      JS.
- [ ] **CLS (Cumulative Layout Shift)** — target ≤0.1. Every image/video/
      embed reserves its layout space (explicit width/height or aspect-
      ratio) before it loads, so nothing jumps once content arrives; same
      for web fonts (use `font-display: swap` deliberately, and size
      fallback fonts close to the real font to minimize the swap-in
      shift) and any dynamically-injected content (ads, banners) above
      existing content.
- [ ] Measure with real tooling, not guesswork: PageSpeed Insights /
      Lighthouse for lab data, Search Console's Core Web Vitals report for
      real-user field data (the one that actually affects ranking) — the
      two can disagree, field data is authoritative.
- [ ] Images use a modern format (WebP/AVIF) and are served at the
      resolution actually needed per breakpoint, not one oversized master
      file — see any project-specific image guide for the concrete
      target sizes.
- [ ] Above-the-fold content doesn't wait on unnecessary JS — prefer
      server-rendered/static HTML for anything that should be visible and
      indexable immediately.
- [ ] Fonts are subset to the scripts/characters actually used, and
      critical fonts are preloaded.

