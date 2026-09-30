## 7. File Upload / File Handling

Maps to: CWE-434 (Unrestricted Upload of Dangerous File Type), CWE-22
(Path Traversal).

- [ ] Uploaded file type is validated by **content** (magic-byte/signature
      sniffing), not just the client-supplied MIME type or file extension
      — both are trivially spoofable.
- [ ] File size is capped, enforced server-side.
- [ ] Uploaded files are stored with a server-generated name (random UUID
      or hash), never the client-supplied original filename — prevents
      path traversal and overwrite attacks via crafted filenames.
- [ ] Uploaded files are stored outside the web root, or in a location/
      configuration that prevents them from being executed as code (e.g.
      a script uploaded as an "image" should never be servable/executable
      by the web server).
- [ ] SVG uploads are either rejected or rebuilt from an allowlist of
      shapes/attributes (SVG can carry `<script>`, event handlers and
      external references) — "sanitize by stripping known-bad tags" is
      not enough.
- [ ] Image processing strips metadata (EXIF GPS location, camera serials)
      before publishing uploaded photos.
- [ ] Delete/replace operations on stored files only accept keys matching
      the shape this app itself generates, so a crafted URL can't delete
      unrelated objects in the same bucket.
- [ ] If uploads are served back to users, they're served with a
      `Content-Disposition` that prevents inline execution where
      appropriate, and with `X-Content-Type-Options: nosniff` so a
      mislabeled file isn't sniffed into an executable content type by
      the browser.
- [ ] Images/documents that get processed server-side (resizing, thumbnail
      generation, metadata extraction) use a current, patched library —
      image/document parsers are a common source of memory-corruption
      CVEs.
- [ ] Every file-handling endpoint independently checks authorization (see
      §3) — an upload/download endpoint is a common place for an access
      control check to be forgotten.

