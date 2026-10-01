#!/usr/bin/env bash
# Runs a fast static check when Claude finishes a turn. Works for any stack:
#   1. If the project has .claude/typecheck-cmd, run its first line (e.g. "mypy ." or "go vet ./...").
#   2. Else, if package.json defines a typecheck script, run `pnpm --silent typecheck`.
#   3. Else skip.
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

if ! out=$(bash -c "$cmd" 2>&1); then
  printf 'Check failed (%s). Fix before finishing:\n%s\n' "$cmd" "$out" | head -n 40 >&2
  exit 2
fi
