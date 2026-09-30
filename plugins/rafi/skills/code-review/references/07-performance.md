## 7. Performance

- Don't optimize before measuring — but don't ignore obvious inefficiencies either (e.g. N+1 queries, unbounded loops over large datasets).
- Paginate any endpoint or query that can return an unbounded list.
- Cache expensive or repeated operations with a clear invalidation strategy — don't cache without knowing when it goes stale.
- Avoid unnecessary re-renders, re-fetches, or re-computations on the frontend — memoize or debounce where it matters, not everywhere by default.
- Index database fields that are actually filtered/sorted/joined on frequently.
- Lazy-load what isn't needed immediately (code-splitting, deferred data fetches).

---

