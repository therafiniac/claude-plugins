## 4. Robust

- [ ] Native elements are used for native behavior: `button` for actions, `a` for navigation, `input`/`select`/`textarea` for fields. No clickable `div` or `span` without role, name, keyboard support, and state. (4.1.2)
- [ ] Custom widgets expose the correct name, role, and state (`aria-expanded`, `aria-selected`, `aria-checked`, `aria-current`) and follow the WAI-ARIA Authoring Practices keyboard pattern.
- [ ] ARIA attributes are valid, relevant to the role, and not redundant. `aria-hidden` is never set on a focusable element. Element IDs are unique.
- [ ] Status messages (form results, cart updates, toasts, loading complete) are announced through `role="status"`, `role="alert"`, or `aria-live` without moving focus. (4.1.3)
- [ ] Automated axe checks pass with the tags `wcag2a`, `wcag2aa`, `wcag21aa`, `wcag22aa`.

