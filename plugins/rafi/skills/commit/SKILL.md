---
name: commit
description: Commit the current work as type(scope) subject after checks pass, with no attribution, on a work branch, and push it. Other commands follow this file to commit.
argument-hint: "[what the change is, optional]"
disable-model-invocation: true
---
Hint: $ARGUMENTS

Rules: `.claude/rules/git.md` if the project has it, otherwise the same rules with base `dev` if it exists, else `main`. Other commands follow steps 1 to 7 of this file when they commit.

1. **Branch.** If the current branch is `main` or `dev`, never commit there: create a work branch from `dev` named after the change (`git switch -c <type>/<name>`; uncommitted work moves with it) and say so.
2. **Scope the change.** Read `git status --short` and `git diff`. Stage only the files of this one logical change, by path (`git add <paths>`), never `git add -A` blindly. Never stage `.env*` (except `.env.example`), `secrets/`, build output, or files the change did not touch. If the work holds several unrelated changes, split them into separate commits and say so.
3. **Checks.** Run `pnpm check` (skip only for a change that touches no code, such as docs only). Do not commit on failure; fix or report.
4. **Message.**
   - Header `type(scope): subject`: type from `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`; scope required, lowercase kebab-case, naming the area (`auth`, `tags`, `db`, `deps`); subject imperative, lowercase start, no period; header at most 72 characters.
   - Body only when the why is not obvious, wrapped at 72.
   - Footer `BREAKING CHANGE: <what and what to do>` for a breaking change; `Refs: #<n>` if there is an issue.
   - **No attribution of any kind**: no `Co-authored-by`, no names of tools or AI, no links, no "generated with" lines. It must read as written by the repository owner.
5. **Commit** with `git commit -F <message file>` or `git commit -m <header> [-m <body>]`. Never `--no-verify`. If a hook rejects it, fix the cause (message, lint, secret) and commit again; never bypass.
6. **Identity.** Before the first commit in a session, check that `git config user.name` and `user.email` are the repository owner's, not a tool's. If they look like a bot or tool, stop and ask me which identity to use.
7. **Push** the work branch: `git push -u origin <branch>` (first push) or `git push`. Never push `main` or `dev` from here.
8. Report: the commit hash and header, the files in it, and the push result, in four lines or fewer.
9. Last line: `Next:` plus one step: more slices → `/clear`, then `/rafi:slice <next>`; work on the branch is done → `/rafi:merge`. It is only a suggestion. Never run it.
