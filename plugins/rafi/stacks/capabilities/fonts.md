# Capability: Fonts
Kind: capability
Ask when: the project has any UI. Choose system-stack if the design does not need a specific typeface.
Default: astro → astro-fonts. nextjs → next-font. react-spa, react-express → fontsource. Every option here self-hosts the font files.
Verified: September 2026 (Astro Fonts API top-level since Astro 6; astro-fonts with Fontsource, Latin-ext plus Devanagari, and Tailwind 4.3 built and checked in a test project). Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| astro-fonts | adopt | Astro. Built-in Fonts API downloads, self-hosts, and preloads fonts from Fontsource, Google, or local files | astro | free |
| next-font | adopt | Next.js. `next/font` self-hosts Google or local fonts at build time | nextjs | free |
| fontsource | adopt | Vite apps. Fonts as npm packages, imported per weight and subset | react-spa, react-express, astro | free |
| system-stack | adopt | No custom typeface needed. Zero downloads | any | free |
| google-fonts-cdn | hold | Do not link fonts from Google's CDN. It adds a third-party request on every page and a privacy question. All options above self-host | — | — |

## Option: astro-fonts
Setup: in `astro.config.mjs`, a top-level `fonts` array (Astro 6 and later), with `fontProviders` imported from `astro/config`:
```js
fonts: [{
  provider: fontProviders.fontsource(),
  name: "Noto Serif",
  cssVariable: "--font-noto-serif",
  weights: [400, 700],
  subsets: ["latin", "latin-ext"],
  fallbacks: ["serif"],
}]
```
In the base layout head: `import { Font } from "astro:assets"` and `<Font cssVariable="--font-noto-serif" preload />`. Local files use `fontProviders.local()` with `options.variants`.
Sources: https://docs.astro.build/en/guides/fonts/

## Option: next-font
Setup: `next/font/google` or `next/font/local` in the root layout, with `subsets`, `weight` (or a variable font), `display: 'swap'`, and `variable` named after the family (for example `'--font-inter'`). Apply the variable class on `<html>`.
Sources: https://nextjs.org/docs/app/getting-started/fonts

## Option: fontsource
Setup: `@fontsource-variable/<family>` (preferred) or `@fontsource/<family>`. Import only the weights and subsets you use in the app entry.
Sources: https://fontsource.org/docs/getting-started/install

## Option: system-stack
Setup: none. Set `--font-sans` to a system font stack in the styling tokens.
Sources: https://developer.mozilla.org/en-US/docs/Web/CSS/font-family

## Shared
Conventions (for system-stack, only the token and `lang` rules apply):
- At most two families. Prefer variable fonts.
- Two layers of names: the font loader's variable is named after the family (`--font-noto-serif`), and the styling token is named by role and points at it (`--font-serif: var(--font-noto-serif), serif`). With Tailwind, declare these role tokens in `@theme inline { ... }`. Never give both the same name: `--font-serif: var(--font-serif)` is a circular variable, and the browser silently falls back to the default font.
- Components use the role token (`font-serif`), never a family name.
- Several scripts (for example Latin with IAST diacritics plus Devanagari): pick families that contain every glyph you need. Include `latin-ext` for diacritics such as ā ī ū ṛ ṅ ñ ṭ ḍ ṇ ś ṣ ṃ ḥ, add the script's own subset (`devanagari`), and test real text in both.
- Mark text in another language with `lang` (for example `lang="sa"` or `lang="hi"`), so browsers and screen readers pick the right font and pronunciation.
Performance checks (added to performance-audit):
- `woff2` only. Preload only the font used above the fold, in its main weight.
- `font-display: swap`, with the metric-adjusted fallback that the Astro Fonts API and `next/font` generate, to keep CLS low.
- Subsets limit the download to the scripts actually used.
- In the built CSS, no font variable refers to itself (search the output for `--font-x: var(--font-x)`).
Accessibility checks (added to accessibility-audit):
- Body text is at least 16px equivalent, and text resizes to 200% without loss (§1).
- No text is rendered as an image (§1).
- `lang` is set on passages in another language (§3).
