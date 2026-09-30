## 1. Crawlability & Indexability

- [ ] `robots.txt` exists, is reachable at `/robots.txt`, and doesn't
      accidentally block content that should be indexed (a common
      mistake: a staging-environment `Disallow: /` left in place after
      launch).
- [ ] `sitemap.xml` exists, is referenced in `robots.txt`, is submitted to
      Search Console/Bing Webmaster Tools, and is kept current
      automatically (generated from the actual content source, not
      hand-maintained and prone to going stale).
- [ ] No page that should be indexable has an accidental `noindex` meta
      tag or `X-Robots-Tag` header — check both the rendered HTML and
      response headers, not just source code, since some frameworks set
      this dynamically.
- [ ] Every canonical URL (`<link rel="canonical">`) points to the one
      true version of that content — critical for any content reachable
      through more than one URL path (filtered/sorted list views, a
      tracking-parameter'd link, http vs https, www vs non-www,
      trailing-slash variants).
- [ ] No orphan pages — every real page is reachable via internal links
      from somewhere a crawler would find it, not only via direct URL or
      a client-side-only navigation crawlers can't follow.
- [ ] Pagination (if any) uses real, crawlable links (`<a href>`), not
      only JS-driven "load more" with no URL state — or if infinite
      scroll is used, a crawlable paginated fallback exists.
- [ ] HTTP status codes are correct: real content returns 200, missing
      content returns a real 404 (not a 200 with "not found" text — a
      "soft 404"), permanent moves use 301 not 302, and no redirect chains
      longer than one hop.

