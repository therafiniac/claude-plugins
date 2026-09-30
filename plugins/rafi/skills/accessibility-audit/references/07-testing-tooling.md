## 7. Testing & Tooling

- [ ] axe runs in CI through Playwright (`@axe-core/playwright`) on every public and core-flow route.
- [ ] Keyboard-only pass on each core flow: tab order, visible focus, dialogs, menus, and forms all work without a mouse.
- [ ] Screen reader spot check on each core flow with NVDA on Windows or VoiceOver on macOS or iOS. Headings, landmarks, form errors, and dynamic updates are announced correctly.
- [ ] Zoom to 200% and 400%, and a 320 px viewport, on each core page.
- [ ] Contrast is checked with a tool for the full design token set, in every theme.
- [ ] `prefers-reduced-motion` and forced-colors (high contrast) modes are checked.
- [ ] Accessibility findings are tracked in `docs/audits/accessibility.md`, and a regression test is added for each Fixed item.

---

