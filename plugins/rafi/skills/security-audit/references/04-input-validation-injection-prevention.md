## 4. Input Validation & Injection Prevention

Maps to: OWASP Top 10 A03:2021 (Injection), CWE-89 (SQL Injection),
CWE-78 (OS Command Injection), CWE-79 (XSS), CWE-611 (XXE), CWE-502
(Insecure Deserialization), CWE-918 (SSRF).

- [ ] All database queries use parameterized statements / prepared
      statements / an ORM's parameter binding — **never** string
      concatenation or template-literal interpolation of user input into a
      query, for SQL or NoSQL (e.g. MongoDB operator injection via
      unsanitized `$where`/object-shaped input).
- [ ] Any shell command construction from user input is avoided entirely if
      possible; where unavoidable, uses an allowlist of permitted values and
      a library that passes arguments as an array (not a concatenated
      string) — never pass raw user input to `exec`/`system`/backticks.
- [ ] All input is validated server-side regardless of client-side
      validation (client-side is UX only, never the security boundary):
      type, format, length, and range checked for every field, not just
      "is it present."
- [ ] Enum-like fields (roles, statuses, categories, etc.) are checked
      against a closed allowlist, never accepted as freeform strings that
      later get trusted.
- [ ] Output is encoded/escaped for the context it's rendered into:
      HTML-encode for HTML body content, attribute-encode for HTML
      attributes, JS-string-encode for inline scripts, URL-encode for URL
      parameters. A templating engine with auto-escaping by default is
      strongly preferred over manual escaping.
- [ ] Any user-authored rich text / HTML is either (a) never rendered as
      raw HTML at all (rendered via a structured format + an explicit
      allowlisted-node renderer instead), or (b) sanitized through a
      well-maintained library (e.g. DOMPurify) with a strict allowlist of
      tags/attributes immediately before rendering — never trust a
      "sanitize on save" alone, since the render path is the actual attack
      surface.
- [ ] Link/URL fields accept only expected protocols (`http:`, `https:`,
      `mailto:`, etc.) — reject `javascript:`, `data:`, and `vbscript:`
      schemes, which are a common stored-XSS vector via seemingly-safe
      link fields.
- [ ] Media/embed URLs (images, iframes, video embeds) are restricted to an
      allowlist of origins and rebuilt from parsed parts (e.g. extract a
      video ID and construct the embed URL) at *render* time — never pass
      a stored URL straight into `<iframe src>`/`<img src>`.
- [ ] Every fallback/error path of a renderer that outputs HTML (math,
      markdown, syntax highlighting) escapes its input — a "render failed,
      show the raw source" branch that inserts unescaped text is XSS.
- [ ] XML parsing (if any) disables external entity resolution (prevents
      XXE) and disables DTD processing where not needed.
- [ ] Deserialization of untrusted data uses a safe format (JSON with schema
      validation) rather than a language-native serialization format that
      can execute code on deserialize (e.g. Python `pickle`, Java native
      serialization, PHP `unserialize` on untrusted input).
- [ ] Any server-side request that fetches a URL derived from user input
      (webhooks, "fetch this image URL," link previews, etc.) validates
      against an allowlist of hosts/protocols and blocks requests to
      internal/private IP ranges and cloud metadata endpoints
      (`169.254.169.254`, `localhost`, RFC1918 ranges) — this is SSRF
      prevention.
- [ ] File paths built from user input are validated to prevent path
      traversal (`../`) — normalize and confirm the resolved path stays
      within the intended directory; prefer generating server-side
      filenames over trusting client-supplied ones at all.
- [ ] Template engines: confirm no user input reaches a template
      *compilation* step (as opposed to template *data*) — this is Server-
      Side Template Injection (SSTI), which is often full RCE.

