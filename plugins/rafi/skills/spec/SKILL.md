---
name: spec
description: Write a feature spec (PRD) in docs/prd/ before planning. Either Claude asks you questions and writes it, or it sets up the file for you to fill and then reviews it.
argument-hint: <feature name>
disable-model-invocation: true
---
Feature: $ARGUMENTS

The spec describes **what** the feature does from the user's point of view, never **how** it is coded. Write no code and no plan.

1. Read `docs/prd/_template.md`, `docs/brainstorm.md` and `docs/architecture.md` if present, and the existing files in `docs/prd/`. The target file is `docs/prd/<feature-name-in-kebab-case>.md`. If it already exists, show its path and ask whether to edit it or start over.
2. Ask me exactly this and wait:
   **How do you want to write this spec?**
   **A) Ask me questions and write it for me**
   **B) Create the file and I'll fill it in myself, then you review it**

## A) Claude asks
3. Ask at most four questions per message, in plain language, over as many rounds as needed:
   - the problem, and why it matters now
   - who uses the feature
   - what it includes (scope), and what it deliberately leaves out (non-goals)
   - what the user sees and does, step by step, and what happens when something goes wrong
   Do not ask about code, files, or libraries.
4. Draft the acceptance criteria as `Given <situation>, when <action>, then <result>`, from my answers. Cover: the normal case, invalid or empty input, something that does not exist (not found), someone without permission (only if the project has logins), and limits (very long, zero, many). Mark any criterion I did not state myself as **(proposed)**. Show the list and wait until I confirm, change, or remove each proposed one. Never keep a requirement I did not agree to.
5. Fill the remaining sections from my answers: data and permissions notes only where they follow from what I said, risks and open questions, and the audit checkboxes using the Audit triggers table in `CLAUDE.md`.
6. Write the file from the template and show it.

## B) I fill it
3. Copy `docs/prd/_template.md` to the target file with the title filled in. Tell me its path, plus one plain-language hint per section and one finished example criterion: `Given a lesson tagged "grammar", when I open /tags/grammar, then I see that lesson.` Then wait until I say I am done.
4. Read the file and review it:
   - each acceptance criterion has a clear, checkable **then**; flag vague ones ("works well", "is fast")
   - missing failure cases: invalid input, not found, no permission, limits
   - conflicts between scope and non-goals, and anything mentioned in scope that no criterion covers
5. List the problems with a suggested rewrite for each. Edit the file only for the suggestions I accept.

## Finish
Tell me the next step: `/clear`, then `/rafi:plan-feature <feature>`.
