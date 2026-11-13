---
type: llm
weight: 1
---

The working folder is an empty project; noting that docs or templates are missing is fine. A successful response asks how the spec should be written and offers both choices: (A) Claude asks questions and writes it, and (B) Claude creates the file for the user to fill in and then reviews it. The response then waits for the answer. Fail it only if it writes a spec file before the user answers, asks about code or libraries, or writes a plan or code.
