## 6. Testing Expectations

For any non-trivial function or endpoint, consider (and write tests for, where a test setup exists in the project) these cases:

- Happy path — the intended valid use case
- Invalid input — malformed, missing, wrong type
- Unauthorized access — wrong role, wrong ownership
- Not-found — resource doesn't exist
- Boundary values — empty input, single item, maximum size
- Concurrency — what happens if this runs twice at once, where relevant

If no test framework exists in the project, at minimum reason through these cases explicitly before considering the code done.

---

