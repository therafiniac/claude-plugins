## How to Apply This

- For small fixes or single functions: apply Sections 1–5 as a baseline mental pass, even if not all are written out.
- For new features or endpoints: apply all sections explicitly. State briefly which checks/security measures you applied if the change is non-trivial, so I can verify.
- If you notice a risk or gap outside what I asked for (a missing auth check, an unhandled error path, a hardcoded secret), flag it — don't silently fix or silently ignore it, tell me what you found and what you did about it.
- When in doubt between a faster/simpler approach and a more correct/secure one, default to the correct/secure one and mention that a simpler alternative exists, rather than silently picking the shortcut.
