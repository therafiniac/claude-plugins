#!/usr/bin/env bash
# Runs a fast static check when Claude finishes a turn. Works for any stack:
#   1. If the project has .claude/typecheck-cmd, run its first line (e.g. "mypy ." or "go vet ./...").
#   2. Else, if package.json defines a typecheck script, run `pnpm --silent typecheck`.
#   3. Else skip.
# Skips the check when the working tree is unchanged since the last passing run
# (fingerprint of HEAD, status, diff, and untracked files, cached in .git/).
# On failure it exits 2, which sends the error back to Claude so it fixes it before stopping.
set -uo pipefail
input=$(cat)

# If Claude is already retrying after a failed check, let it stop (prevents loops).
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

if [ -f .claude/typecheck-cmd ]; then
  cmd=$(head -n 1 .claude/typecheck-cmd)
elif [ -f package.json ] && jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then
  cmd="pnpm --silent typecheck"
else
  exit 0
fi

# Fingerprint the working tree. Outside git, always run.
stamp=""
if git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null); then
  stamp_file="$git_dir/rafi-typecheck-ok"
  fingerprint=$({
    printf '%s\n' "$cmd"
    git rev-parse -q --verify HEAD 2>/dev/null
    git status --porcelain=v1 --untracked-files=all 2>/dev/null
    git diff HEAD --binary 2>/dev/null || git diff --binary 2>/dev/null
    git ls-files -o --exclude-standard 2>/dev/null | git hash-object --stdin-paths 2>/dev/null
  } | git hash-object --stdin)
  if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$fingerprint" ]; then
    exit 0
  fi
  stamp=$fingerprint
fi

if ! out=$(bash -c "$cmd" 2>&1); then
  printf 'Check failed (%s). Fix before finishing:\n%s\n' "$cmd" "$out" | head -n 40 >&2
  exit 2
fi

[ -n "$stamp" ] && printf '%s' "$stamp" > "$stamp_file"
exit 0
