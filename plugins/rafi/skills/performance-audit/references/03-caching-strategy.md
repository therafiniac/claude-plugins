## 3. Caching Strategy

- [ ] Every cache (HTTP cache headers, CDN edge cache, application-level
      cache, database query cache) has an explicit invalidation strategy —
      "cache it and hope it goes stale gracefully" is not a strategy.
      Know exactly what triggers a cache bust for each layer.
- [ ] Static assets (JS/CSS/images/fonts) are served with long
      `Cache-Control` (immutable, far-future expiry) plus content-hashed
      filenames, so a deploy safely busts the cache without needing a
      manual purge.
- [ ] HTML/API responses that are cacheable at all use appropriate
      `Cache-Control`/`stale-while-revalidate` semantics rather than
      either no caching or overly aggressive caching that serves stale
      data past when it matters.
- [ ] A CDN sits in front of static assets (and cacheable HTML, where
      applicable) — don't serve everything from a single origin server if
      a CDN is available and unused.
- [ ] Expensive, repeated computations (not just raw data fetches) are
      cached with a known invalidation trigger, not recomputed identically
      on every request.

