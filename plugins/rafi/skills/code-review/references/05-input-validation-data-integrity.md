## 5. Input Validation & Data Integrity

- Validate type, format, length, and range for every input — not just presence.
- Validate on the server/backend regardless of what the frontend already validates — frontend validation is UX, backend validation is the actual gate.
- Sanitize file uploads: check type, size, and content — never trust the file extension or client-reported MIME type alone.
- Define and enforce data shape at the boundary (schema validation library, type system, or explicit checks) rather than trusting incoming JSON shape.

---

