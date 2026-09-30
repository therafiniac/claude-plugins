## 5. Forms & Components

- [ ] Every input has a programmatically associated visible `<label>`. Placeholder text is not the label. (3.3.2, 1.3.1)
- [ ] Related controls are grouped with `fieldset` and `legend` (radio groups, address blocks).
- [ ] Required fields and format hints are stated in text, not only by color or an asterisk. Inputs that collect personal data use the correct `autocomplete` values. (1.3.5)
- [ ] Errors are identified in text, associated with their field (`aria-describedby`), and announced. A summary at the top links to the fields with problems. Error text suggests how to fix the input. (3.3.1, 3.3.3)
- [ ] Legal, financial, or destructive submissions can be reviewed, corrected, or reversed before final confirmation. (3.3.4)
- [ ] Modals and dialogs move focus in on open, trap focus while open, close on Escape, return focus to the trigger, and make the background inert.
- [ ] Menus, tabs, accordions, comboboxes, and carousels follow their WAI-ARIA Authoring Practices pattern, including arrow-key navigation where the pattern requires it.
- [ ] Data tables have `th` cells with a `scope`, and a caption or accessible name. Layout is never built with tables.
- [ ] Toasts and inline notifications persist long enough to read and can be dismissed by keyboard.
- [ ] Icon fonts and SVG icons are hidden from assistive technology when decorative, and named when meaningful.

