## 2. Rendering Strategy (Static vs. Dynamic vs. Streaming)

Framework-agnostic framing — every modern framework has some version of
each of these; the specific API differs, the principle doesn't:

- [ ] Content that's the same for every visitor and doesn't change often
      is pre-rendered/cached at build or deploy time (static generation),
      not recomputed on every single request.
- [ ] Content that changes per-request (personalized, real-time, or
      driven by request-specific filters/query params) is rendered
      dynamically — but even then, check whether a shorter-lived cache
      (seconds-to-minutes) is viable rather than zero caching at all.
- [ ] Content that's *mostly* static but needs to update periodically
      (a blog list, a product catalog) uses an incremental/revalidation
      strategy — regenerate on a timer or on-demand, rather than forcing
      either "fully static and staleness stays forever" or "fully dynamic
      and every request pays full render cost."
- [ ] Large pages stream/progressively render rather than blocking the
      entire response on the slowest piece of data — the above-the-fold
      content shouldn't wait on a slow below-the-fold data fetch.
- [ ] Client-side JavaScript is reserved for what's genuinely interactive;
      content that never changes after load doesn't need to be
      client-rendered.

