# Capability: UI components
Kind: capability
Ask when: the UI needs interactive widgets: dialogs, menus, tabs, comboboxes, date pickers, toasts, data tables. Content sites that only need links, prose, and a search box choose none.
Default: nextjs, react-spa, react-express → shadcn. astro → none, or shadcn inside React islands when the site has app-like pages.
Verified: September 2026 (shadcn CLI v4, Base UI default since July 2026). Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| none | adopt | Content sites. Build the few widgets you need by hand with native elements (`<details>`, `<dialog>`) | any | free |
| shadcn | adopt | React UI. Components are copied into your repo on top of Base UI (the default) or Radix, styled with Tailwind. Needs the tailwind styling option | nextjs, react-spa, react-express, astro (React islands) | free |
| react-aria-components | trial | Complex widgets or strict accessibility and internationalization needs (date pickers, comboboxes, drag and drop). Unstyled | nextjs, react-spa, react-express, astro (React islands) | free |
| daisyui | trial | Component classes on Tailwind with no JavaScript; you wire up interactive behavior yourself. Needs the tailwind styling option | any | free |
| runtime-css-in-js-kits | hold | Do not start new projects on kits built on runtime CSS-in-JS (for example MUI with Emotion). Runtime cost and friction with React Server Components | — | — |

## Option: none
Conventions:
- Prefer native elements: `<dialog>` for modals, `<details>` for disclosure, `<select>` for simple choices.
- Anything more complex than that triggers this capability again through `/rafi:add-capability ui-components`.
Accessibility checks (added to accessibility-audit):
- `<dialog>` is opened with `showModal()` so it is modal and closes on Escape (§2).
Sources: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog

## Option: shadcn
Setup: `pnpm dlx shadcn@latest init` (Base UI by default; `-b radix` for Radix), then `pnpm dlx shadcn@latest add <component>` per component. Components land in `src/components/ui/`.
Conventions:
- The components are your code. Edit them freely, but keep their keyboard and ARIA behavior.
- Use one primitive library (Base UI or Radix) for the whole project.
- Add components only when a feature needs them, not the whole catalog up front.
Sources: https://ui.shadcn.com/docs/installation, https://ui.shadcn.com/docs/changelog/2026-07-base-ui-default

## Option: react-aria-components
Setup: `react-aria-components`. Style with Tailwind classes through the render-props state (`isFocusVisible`, `isSelected`).
Conventions:
- One wrapper per widget in `src/components/ui/` applies the project's styles, so pages never style raw primitives.
Sources: https://react-spectrum.adobe.com/react-aria/

## Option: daisyui
Setup: `daisyui`, enabled in the global stylesheet with `@plugin "daisyui";`. Themes map to the styling tokens.
Conventions:
- Use daisyUI classes for looks only. Interactive behavior uses native elements (`<dialog>`, `<details>`) or small scripts you own.
Accessibility checks (added to accessibility-audit):
- Class-only components are checked for keyboard support and ARIA state, since the library adds no behavior (§2, §4).
Sources: https://daisyui.com/docs/install/

## Shared
Conventions:
- Theme through the styling tokens, not per-component color overrides.
Performance checks (added to performance-audit):
- Heavy components (data table, date picker, rich editor) load lazily on the pages that use them.
Accessibility checks (added to accessibility-audit):
- Dialogs trap focus, close on Escape, and return focus to their trigger; menus and tabs support arrow keys (§2).
- Every custom widget follows its WAI-ARIA Authoring Practices pattern, and `e2e/a11y.spec.ts` covers a page that uses it (§4).
- Component colors meet contrast in every state (default, hover, focus, disabled text excepted) (§1).
