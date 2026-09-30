## 3. Structured Data (Schema.org / JSON-LD)

- [ ] Structured data uses JSON-LD (Google's recommended format over
      microdata/RDFa) and validates against schema.org's spec — test with
      Google's Rich Results Test or Schema Markup Validator, not just "it
      parses as JSON."
- [ ] The schema type actually matches the content (`Article`, `Product`,
      `Recipe`, `Person`, `Organization`, `BreadcrumbList`, `FAQPage`,
      etc.) — using a mismatched or overly generic type forfeits eligible
      rich-result features.
- [ ] Required properties for each schema type are present (e.g.
      `Article` needs `headline`, `image`, `datePublished`, `author`) —
      missing required fields disqualifies rich results even if the type
      itself is correct.
- [ ] Structured data values match what's actually visible on the page —
      Google's guidelines explicitly prohibit marking up content that
      isn't shown to users; mismatches can trigger a manual action.
- [ ] `BreadcrumbList` schema mirrors the site's real, visible breadcrumb
      trail if one exists.
- [ ] `Organization`/`WebSite` schema (sitewide identity, logo, search
      action) is present at the site root where applicable.

