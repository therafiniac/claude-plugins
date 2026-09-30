## 1. Think Before You Code — The Core Loop

Before writing any function, endpoint, or component, work through this silently (or briefly state it for non-trivial features):

1. **Feature** — What is being built, in one sentence?
2. **Actor** — Who or what calls this?
3. **Goal** — What does success look like for the caller?
4. **Checks** — What must be true before this runs (validation, auth, business rules)?
5. **Change** — What state/data actually changes?
6. **Result** — What is returned on success, and on every failure path?

Scale this to the task: a trivial utility function needs steps 4 and 6 thought through; a new endpoint or feature needs all six explicitly.

**Universal flow for anything that receives input and acts on it:**
Receive input → Validate → Authenticate (if applicable) → Authorize (if applicable) → Apply business rules → Read/write state → Handle errors → Return result.

---

