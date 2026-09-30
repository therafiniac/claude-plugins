#!/usr/bin/env bash
# Formats the file Claude just edited. Works for any stack:
#   1. If the project has .claude/format-cmd, run its first line with the file path appended.
#   2. Else, in a pnpm project, run Prettier.
#   3. Else do nothing.
# Never blocks Claude: failures are ignored.
set -uo pipefail
file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] && [ -f "$file" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

if [ -f .claude/format-cmd ]; then
  cmd=$(head -n 1 .claude/format-cmd)
  # The file path is appended as the last argument. Normal shell quoting in the command works.
  bash -c "$cmd \"\$1\"" _ "$file" >/dev/null 2>&1 || true
  exit 0
fi

if [ -f package.json ] && command -v pnpm >/dev/null 2>&1; then
  pnpm exec prettier --write --ignore-unknown "$file" >/dev/null 2>&1 || true
fi
exit 0
