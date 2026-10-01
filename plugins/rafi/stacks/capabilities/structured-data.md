# Capability: Structured data
Kind: capability
Ask when: the site represents a person or organization, or publishes articles, books, or academic papers that should be found and attributed by search engines or Google Scholar.
Default: astro → hand-written-jsonld. Academic sites (papers, books, CV) also apply the `citation_*` rules in `## Shared`.
Verified: October 2026 (schema-dts 2.0.0, astro-seo-schema 7.0.0, Google Scholar inclusion guidelines, Google Search structured data docs). Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| hand-written-jsonld | adopt | Default. A small typed helper module and one `<JsonLd>` component. Full control over escaping and the `@graph` | astro | free |
| astro-seo-schema | trial | You prefer a ready-made `<Schema>` component. Its peer range (`schema-dts ^1.1.0`) lags schema-dts 2.x, so check the peer range before installing | astro | free |
| astrolib-seo | hold | Do not use. `@astrolib/seo` was last published in October 2024 and its peer range stops at Astro 5 | — | — |

## Option: hand-written-jsonld
Setup: `schema-dts` as a dev dependency (types only, no runtime code; it type-checks the JSON-LD objects). Files:
- `src/lib/structured-data.ts`: one builder per type (`personNode`, `websiteNode`, `profilePageNode`, `blogPostingNode`, `scholarlyArticleNode`, `bookNode`, `breadcrumbNode`), each returning a `schema-dts` type. Also `serializeJsonLd(data)`, which runs `JSON.stringify` and then replaces `<` with `<`.
- `src/components/JsonLd.astro`: `<script type="application/ld+json" set:html={serializeJsonLd(data)} />`, rendered in the layout `<head>`.
- `src/components/CitationMeta.astro`: renders the `citation_*` meta tags for one publication.
Conventions:
- Every builder takes validated content-collection entries (Zod schema), never raw frontmatter.
- One JSON-LD block per page, using `@graph`. The site-wide `Person` and `WebSite` nodes have stable `@id`s (`${site}/#person`, `${site}/#website`). Page nodes reference them by `@id` and do not repeat them.
- All URLs in JSON-LD are absolute, built from `Astro.site`. Never hard-code the domain.
- `JsonLd.astro` is the only place that uses `set:html` with structured data, and it always goes through `serializeJsonLd`.
Security checks (added to security-audit):
- JSON-LD output escapes `<` (so no `</script>` breakout), and `set:html` is used only through `serializeJsonLd` (§12, §4).
- Content-collection schemas validate URL fields (`doi`, `url`, `sameAs`, `pdf`) as URLs or DOI patterns before they reach markup (§4).
Performance checks (added to performance-audit):
- Structured data ships no client JavaScript. JSON-LD is inline in the static HTML (§6).
Sources: https://github.com/google/schema-dts, https://docs.astro.build/en/reference/directives-reference/#sethtml, https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data

## Option: astro-seo-schema
Setup: `astro-seo-schema` (the `<Schema>` component) and `schema-dts` (its peer dependency for types). Check that the installed `schema-dts` major version satisfies the package's peer range. Render `<Schema item={...} />` in the layout `<head>`.
Conventions:
- Every `item` is built from validated content-collection entries, never raw frontmatter.
- The site-wide `Person` and `WebSite` nodes have stable `@id`s (`${site}/#person`, `${site}/#website`). Page items reference them by `@id`.
- All URLs are absolute, built from `Astro.site`.
- `citation_*` meta tags come from a separate `CitationMeta.astro` component; this package does not render them.
Security checks (added to security-audit):
- Built output for a test entry whose title contains `</script>` shows the sequence escaped inside the JSON-LD block (§12, §4).
- The package and its `schema-dts` peer dependency are pinned and audited (§9).
Performance checks (added to performance-audit):
- The component adds no client JavaScript (§6).
Sources: https://github.com/codiume/orbit/tree/main/packages/astro-seo-schema, https://github.com/google/schema-dts

## Shared
Which type goes on which page:
- Every page: `WebSite` and `Person` (`name`, `jobTitle`, `affiliation` as an `Organization` or `CollegeOrUniversity`, `image`, `url`, `sameAs`, `knowsAbout`, `knowsLanguage`).
- About page: `ProfilePage` with `mainEntity` pointing to the `Person` `@id`.
- Blog post: `BlogPosting` (`headline`, `image`, `datePublished`, `dateModified`, `author` → Person `@id`, `inLanguage`).
- Paper: `ScholarlyArticle` (`headline`, `author`, `datePublished`, `isPartOf` periodical or book, `identifier` and `sameAs` → `https://doi.org/<doi>`, `inLanguage`, `abstract`, `encoding` for a hosted PDF).
- Book: `Book` (`name`, `author`, `isbn`, `publisher`, `datePublished`, `inLanguage`, `image`, `sameAs` publisher or library page). No `offers`. Google's Book rich results are partner-only, so this is for entity understanding, not rich snippets.
- Talks: `Event` only if date, location, and name are visible on the page. Otherwise no markup.
- Pages with visible breadcrumbs: `BreadcrumbList` matching the trail.
Google Scholar (`citation_*` meta tags on each publication detail page):
- Required: `citation_title`, one `citation_author` per author (name only, no degrees or affiliations), and `citation_publication_date` as `YYYY/MM/DD`, or the year alone.
- When known: `citation_journal_title` or `citation_conference_title`, `citation_volume`, `citation_issue`, `citation_firstpage`, `citation_lastpage`, `citation_issn`, `citation_isbn`, `citation_doi`, `citation_language`.
- `citation_pdf_url` is absolute and points to a PDF in the same directory as the HTML page (for example `/publications/<slug>/` and `/publications/<slug>/<slug>.pdf`).
- One publication per page. The full text or the full author-written abstract is visible without clicks, sign-in, or popups.
- Hosted PDFs contain searchable text (scans are OCR'd), are at most 5 MB, and are uploaded only when the author has the right to share that version.
Conventions:
- Mark up only what is visible on the page. `sameAs` lists only profiles that exist and are linked visibly on the site.
- Papers published elsewhere link to their DOI or publisher page as the canonical source. Do not re-host a publisher's version without permission.
- Title, description, canonical, and Open Graph tags belong to the layout's head, not this concern.
SEO checks (added to seo-audit):
- JSON-LD on Home, About, one post, one paper, and one book validates in the Schema Markup Validator and the Rich Results Test (§3).
- Types match content. `ProfilePage` is used only on the About page. Required properties are present (§3).
- Structured data values match visible text: name, titles, dates, and authors (§3, §8).
- Every publication page has `citation_title`, `citation_author`, and `citation_publication_date`. Every `citation_pdf_url` resolves with 200 and sits in the page's directory (§3).
- `inLanguage` and `citation_language` match the item's `lang` field (§9).
Accessibility checks (added to accessibility-audit):
- PDF and DOI links say what they open, for example "Download PDF (1.2 MB)" or "View on publisher site (DOI)", not "click here" (2.4.4).
Testing:
- One E2E test per page type parses every `script[type="application/ld+json"]` block, asserts the expected `@type`s, and asserts the required `citation_*` tags on a publication page.
Sources: https://scholar.google.com/intl/en/scholar/inclusion.html, https://developers.google.com/search/docs/appearance/structured-data/profile-page, https://developers.google.com/search/docs/appearance/structured-data/article, https://developers.google.com/search/docs/appearance/structured-data/book, https://validator.schema.org, https://search.google.com/test/rich-results
