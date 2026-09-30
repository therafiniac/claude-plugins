## 8. Perceived Performance (UX-Level)

- [ ] Loading states exist for anything that takes noticeable time —
      a skeleton/spinner beats a blank screen or a frozen-looking page.
- [ ] Optimistic UI updates are used where safe (the action almost always
      succeeds and failure can be rolled back cleanly) — the interface
      feels instant even when the actual server round-trip hasn't
      finished.
- [ ] Perceived load order is deliberate — the most important content
      (what the user came for) renders before secondary chrome
      (navigation, footer, unrelated widgets), not in arbitrary DOM order.
- [ ] Interactions provide immediate feedback (a button shows a pressed/
      loading state) even if the underlying operation takes a moment —
      users perceive unresponsive UI as broken, not just slow.

