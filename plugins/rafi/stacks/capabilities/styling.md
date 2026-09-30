# Capability: Styling
Kind: capability
Ask when: the project has any UI. WordPress themes style through `theme.json`; skip this concern for `wordpress`.
Default: astro, nextjs, react-spa, react-express → tailwind. Add typography when the site renders Markdown or CMS HTML.
Verified: September 2026 (Tailwind CSS 4.3). Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| tailwind | adopt | Default for any UI. Utility classes plus design tokens in CSS | astro, nextjs, react-spa, react-express | free |
| tailwind-typography | adopt | Add-on to tailwind when rendering Markdown, MDX, or CMS rich text | same as tailwind | free |
| native-css | adopt | You want zero styling dependencies: Astro scoped `<style>`, or CSS Modules in Next.js and Vite | astro, nextjs, react-spa, react-express | free |
| runtime-css-in-js | hold | Do not start new projects with it (styled-components, Emotion). Runtime cost and friction with React Server Components | — | — |

## Option: tailwind
Setup:
- Vite-based projects (astro, react-spa, `apps/web` in react-express): `tailwindcss` and `@tailwindcss/vite`, registered as a Vite plugin (for Astro, under `vite.plugins` in `astro.config.mjs`).
- nextjs: `tailwindcss`, `@tailwindcss/postcss`, `postcss`, and `postcss.config.mjs` with `plugins: { "@tailwindcss/postcss": {} }`.
- One global stylesheet starting with `@import "tailwindcss";`. Design tokens (colors, fonts, spacing, radii) live in an `@theme { ... }` block in that file. There is no `tailwind.config.js` unless a plugin requires one.
- `prettier-plugin-tailwindcss` for consistent class order.
Conventions:
- Colors and fonts come from `@theme` tokens only. No raw hex values or arbitrary values such as `bg-[#e11d48]` in markup.
- Name tokens by role (`--color-accent`, `--color-surface`), not by hue, so the theme can change in one place.
- Dark mode, if any, uses one strategy for the whole site (media query or a class on `<html>`).
- Extract a component when the same long class list appears three times. Do not use `@apply` to rebuild a component library.
Security checks (added to security-audit):
- No class names are built from user input (§4).
Performance checks (added to performance-audit):
- One CSS entry point. No second CSS framework loaded next to Tailwind.
- Class names are complete strings in source. Dynamic string building (`bg-${color}-500`) is not detected by Tailwind and gets dropped from the output.
Accessibility checks (added to accessibility-audit):
- Every foreground and background token pair used for text meets WCAG 2.2 AA contrast (4.5:1 body, 3:1 large text and UI parts) (§1).
- `outline-none` or `focus:outline-none` is always paired with a visible `focus-visible:` replacement (§2).
- Motion utilities (`animate-*`, transitions over 200ms) are wrapped in `motion-safe:` or have a `motion-reduce:` fallback (§6).
Sources: https://tailwindcss.com/docs/installation, https://tailwindcss.com/docs/installation/framework-guides/nextjs, https://tailwindcss.com/docs/theme

## Option: tailwind-typography
Setup: `@tailwindcss/typography` as a dev dependency. Enable it in the global stylesheet right after the import: `@plugin "@tailwindcss/typography";`.
Conventions:
- Wrap rendered Markdown or CMS HTML in `prose` (plus `dark:prose-invert` if the site has dark mode). Never use `prose` on app UI.
- Use `not-prose` for embedded components inside long-form content.
- Customize prose colors through the theme tokens, not per-page overrides.
Accessibility checks (added to accessibility-audit):
- Prose link color meets contrast against the prose background, and links are distinguishable by more than color (§1).
Sources: https://github.com/tailwindlabs/tailwindcss-typography

## Option: native-css
Setup: no packages. Astro: scoped `<style>` in components plus one global `src/styles/global.css`. nextjs, react-spa, react-express: `*.module.css` next to each component plus one global stylesheet.
Conventions:
- Design tokens are CSS custom properties on `:root` in the global stylesheet. Components use `var(--token)`, never raw values.
- One class naming style per project. No global element selectors outside the global stylesheet.
Performance checks (added to performance-audit):
- No unused global CSS files. Critical styles are not loaded through JavaScript.
Accessibility checks (added to accessibility-audit):
- Same contrast, focus-visible, and reduced-motion checks as the tailwind option (§1, §2, §6).
Sources: https://docs.astro.build/en/guides/styling/, https://nextjs.org/docs/app/getting-started/css
