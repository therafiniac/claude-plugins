## 4. Code Quality & Maintainability

- Names are intention-revealing — a function or variable name should make its purpose obvious without needing a comment.
- No duplicated logic — extract shared logic once it appears more than twice, not before (avoid premature abstraction too).
- Functions do one thing. If a function needs "and" to describe what it does, consider splitting it.
- Comments explain **why**, not what — the code itself should show what it does; comments cover non-obvious reasoning, tradeoffs, or gotchas.
- Consistent formatting/style with the rest of the codebase — match existing conventions rather than introducing a new style per file.
- Prefer explicit over clever. If a one-liner requires a comment to explain what it does, write it as multiple clear lines instead.
- Follow the order: **make it work → make it correct → make it clean → make it fast.** Don't optimize before it's correct; don't skip cleanup because it "works."

---

