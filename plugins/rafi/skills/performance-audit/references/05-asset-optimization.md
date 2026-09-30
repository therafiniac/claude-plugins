## 5. Asset Optimization

- [ ] Images are served in a modern format (WebP/AVIF) at the resolution
      actually needed per breakpoint/use — see any project-specific image
      guide for concrete target sizes; the general principle is "never
      ship more pixels than will ever be displayed."
- [ ] Images below the fold are lazy-loaded; the single largest
      above-the-fold image (usually the LCP element) is *not*
      lazy-loaded — it should load with priority instead.
- [ ] Fonts are subset to the actual character set used, self-hosted or
      loaded with `preconnect`/`preload` where a third-party font host is
      unavoidable, and use `font-display: swap` (or equivalent) so text
      renders immediately in a fallback font rather than staying invisible
      while the real font loads.
- [ ] CSS/JS are minified and compressed (gzip/brotli) in production —
      confirm this is actually happening (check response headers), not
      just assumed because "the framework probably does it."
- [ ] Unused CSS/JS is not shipped — check for dead code from removed
      features, unused dependencies, or a CSS framework's full stylesheet
      when only a fraction of its classes are ever used.
- [ ] Third-party scripts (analytics, chat widgets, ads) are loaded
      deferred/async and audited periodically — each one is a real,
      often-invisible cost to load time and main-thread availability.

