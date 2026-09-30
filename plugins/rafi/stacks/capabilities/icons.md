# Capability: Icons
Kind: capability
Ask when: the project has any UI. Skip for `wordpress` unless the theme needs custom icons.
Default: all UI frameworks → lucide for interface icons. Add simple-icons only if the site shows brand logos (social links, "works with" lists).
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| lucide | adopt | Default interface icon set. Consistent stroke style, large set, per-icon imports | astro, nextjs, react-spa, react-express | free (ISC) |
| simple-icons | adopt | Brand logos: GitHub, YouTube, payment providers | any | free (CC0 data; the brands' own trademark rules apply) |
| iconify-astro-icon | trial | Astro site that mixes several icon sets or local SVG files through one `<Icon>` component | astro | free |
| heroicons | trial | You use Tailwind's own UI kits and want matching icons. Smaller set than Lucide | nextjs, react-spa, react-express | free (MIT) |
| phosphor | trial | You need several weights (thin to fill, duotone) of the same icon | nextjs, react-spa, react-express | free (MIT) |
| icon-fonts | hold | Do not use (Font Awesome webfont, icon ligature fonts). Poor accessibility and loading behavior. Use SVG | — | — |

## Option: lucide
Setup: astro → `@lucide/astro` (official package; the older third-party `lucide-astro` is deprecated). React-based → `lucide-react`.
Conventions:
- Import each icon by name, e.g. `import { Search } from '@lucide/astro'` or `from 'lucide-react'`.
Sources: https://lucide.dev/guide/installation, https://lucide.dev/guide/astro/getting-started

## Option: simple-icons
Setup: astro with iconify-astro-icon → `@iconify-json/simple-icons` and `<Icon name="simple-icons:github" />`. Otherwise → the `simple-icons` package, which exports each brand's SVG path, title, and hex color; render it in a small `BrandIcon` component.
Conventions:
- Use brand icons only to refer to that brand. Follow each brand's own logo guidelines for color and spacing.
Accessibility checks (added to accessibility-audit):
- A brand icon used as a link has an accessible name naming the destination ("GitHub profile"), not just the logo (§2).
Sources: https://simpleicons.org, https://github.com/simple-icons/simple-icons

## Option: iconify-astro-icon
Setup: `astro-icon` as an Astro integration, plus one `@iconify-json/<set>` package per icon set used (for example `@iconify-json/lucide`, `@iconify-json/simple-icons`). Local SVGs go in `src/icons/`. Release notes for 1.2 list Astro 6 and 7 support and require Node 22.12 or later; confirm for the installed versions.
Conventions:
- `import { Icon } from 'astro-icon/components'` and `<Icon name="set:icon" />`. Local icons use the file name without a prefix.
- Install only the `@iconify-json` sets you use. Do not use the full `@iconify/json` bundle.
- If `include` is configured in the integration, list only the icons in use.
Performance checks (added to performance-audit):
- Icons render as inline SVG at build time. No runtime fetches to the Iconify API.
Sources: https://github.com/natemoo-re/astro-icon, https://iconify.design/docs/icons/json.html

## Option: heroicons
Setup: `@heroicons/react`. Import from the size and style path, e.g. `import { MagnifyingGlassIcon } from '@heroicons/react/24/outline'`.
Sources: https://heroicons.com, https://github.com/tailwindlabs/heroicons

## Option: phosphor
Setup: `@phosphor-icons/react`. Pick one default `weight` for the project and set it through `IconContext`.
Conventions:
- Use only one or two weights across the project.
Sources: https://phosphoricons.com, https://github.com/phosphor-icons/react

## Shared
Conventions:
- Import each icon individually. Never import a whole set or look icons up by string at runtime.
- Size and color come from the surrounding text (`1em` or a `size` prop, `currentColor`), not hardcoded per use.
- One set for interface icons across the project. Brand logos are the only exception.
Performance checks (added to performance-audit):
- No `import * as Icons` or dynamic icon lookup that pulls a full set into a bundle.
Accessibility checks (added to accessibility-audit):
- Decorative icons next to text have `aria-hidden="true"` (§1).
- Icon-only buttons and links have an accessible name (`aria-label` or visually hidden text), and the target is at least 24×24 CSS pixels (§2, §4).
