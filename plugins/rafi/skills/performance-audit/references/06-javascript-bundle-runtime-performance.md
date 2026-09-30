## 6. JavaScript Bundle & Runtime Performance

- [ ] Code-splitting happens at a reasonable granularity — a route/page
      doesn't ship JavaScript for features unrelated to it (an admin-only
      rich-text editor's dependencies shouldn't load on a public content
      page, for example).
- [ ] Heavy, rarely-needed dependencies are lazy-loaded (dynamic
      `import()` or the framework's equivalent) rather than included in
      the initial bundle unconditionally.
- [ ] No unnecessary re-renders/re-computations on the frontend — check
      with the framework's own profiler (React DevTools Profiler, etc.)
      for components re-rendering without their actual inputs changing;
      memoize where profiling shows it matters, not everywhere
      preemptively (premature memoization has its own cost).
- [ ] Expensive client-side computation (parsing, transforming large
      data) is debounced/throttled where triggered by frequent events
      (scroll, resize, keystroke), or moved off the main thread (a Web
      Worker) if genuinely heavy.
- [ ] Long-lived client-side subscriptions/listeners/timers are cleaned
      up on unmount — a memory leak degrades performance over a long
      session even if each individual render is fast.

