## 2. Metadata (Title, Description, Robots Directives)

- [ ] Every indexable page has a unique, descriptive `<title>` — no
      site-wide duplicate title, no title that's just the site name
      repeated on every page.
- [ ] Every indexable page has a unique meta description — written for
      humans (a compelling summary), not keyword-stuffed; understand it's
      a click-through-rate lever, not a ranking factor itself.
- [ ] Title length stays roughly within what search engines render
      without truncation (~50–60 characters is the safe target, engines
      don't hard-cut at an exact number); description similarly
      (~150–160 characters).
- [ ] Metadata is generated dynamically from actual content for anything
      programmatic (a list of products/articles/profiles) — never a
      single static title/description reused across every instance of
      a dynamic route.
- [ ] Open Graph (`og:title`, `og:description`, `og:image`, `og:url`,
      `og:type`) and Twitter Card tags are set on every shareable page, so
      social previews render correctly instead of falling back to
      whatever the platform guesses.
- [ ] `og:image` (and Twitter's image) point to a real, correctly-sized
      image (typically ~1200×630px) — a missing/broken share image is a
      common and easy-to-miss gap.

