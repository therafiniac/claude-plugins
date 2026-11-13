#!/usr/bin/env bash
# Deterministic tests for plugins/rafi/scripts/guard.sh. Run: tools/test-guard.sh
set -uo pipefail
guard="$(cd "$(dirname "$0")/.." && pwd)/plugins/rafi/scripts/guard.sh"
repo=$(mktemp -d); trap 'rm -rf "$repo"' EXIT
g() { git -C "$repo" -c user.name=t -c user.email=t@t -c commit.gpgsign=false "$@" >/dev/null 2>&1; }
g init -b main
fails=0
run() { # expect(A=allow|B=block) json
  local out rc got
  out=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$repo" bash "$guard" 2>&1); rc=$?
  got=$([ $rc -eq 2 ] && echo B || echo A)
  if [ "$got" != "$1" ]; then echo "FAIL (want $1, got $got): $2 $out"; fails=$((fails+1)); fi
}
b() { run "$1" "$(jq -nc --arg c "$2" '{tool_name:"Bash",tool_input:{command:$c}}')"; }
f() { run "$1" "$(jq -nc --arg t "$2" --arg p "$3" '{tool_name:$t,tool_input:{file_path:$p}}')"; }

# Deletes, hooks, secrets, lockfiles
b B 'rm -rf node_modules';           b B 'rm -fr x';          b B 'rm -r -f x'
b B 'sudo rm --recursive --force /'; b B 'ls && rm -Rf dist'; b A 'rm -r dist'; b A 'rm file.txt'
b B 'git commit --no-verify -m "feat(a): b"'; b B 'git commit -nm "feat(a): b"'; b B 'HUSKY=0 git commit -m x'
b B 'cat .env'; b B 'grep KEY .env.local'; b B 'cat secrets/key.pem'; b A 'cat .env.example'; b A 'cp .env.example .env'
f B Read /p/.env; f B Read /p/.env.production; f A Read /p/.env.example
f B Edit /p/pnpm-lock.yaml; f A Read /p/pnpm-lock.yaml; f A Write /p/src/env.ts; f B Write /p/secrets/a

# Empty repo on main: the first (scaffold) commit is allowed
b A 'git commit -m "chore(scaffold): initial project"'
g commit --allow-empty -m "chore(scaffold): initial project"
b A 'git push -u origin main'                 # tip is the root commit
g switch -c dev
b A 'git push -u origin dev'                  # same root commit

# Direct commits, ff merges, pulls, rebases on protected branches
b B 'git commit -m "feat(a): b"'              # on dev
b B 'git merge feat/x';  b B 'git merge --ff-only feat/x'
b A 'git merge --no-ff feat/x';  b A 'git merge --ff-only origin/dev';  b A 'git merge --abort'
b B 'git pull';  b A 'git pull --ff-only';  b A 'git pull --ff-only origin dev'
b B 'git rebase feat/x';  b A 'git rebase --abort'

# Work branch: commits allowed; switching inside one command is tracked
g switch -c feat/x; g commit --allow-empty -m "feat(x): one"
b A 'git commit -m "feat(x): two"'
b B 'git switch dev && git commit -m "feat(x): two"'
b B 'git switch dev && git merge feat/x'
b A 'git switch dev && git merge --no-ff feat/x'
b A 'git rebase origin/dev'
b A 'git push -u origin feat/x';  b A 'git push';  b A 'git push --force-with-lease origin feat/x'
b B 'git push --force origin feat/x';  b B 'git push origin +feat/x'
b B 'git switch -c feat/y dev && git switch dev && git commit -m "x(y): z"'

# Pushing dev/main: allowed only when the tip is a merge commit
g switch dev; g merge --ff-only feat/x               # simulate a bad fast-forward that already happened
b B 'git push origin dev';  b B 'git push';  b B 'git push origin HEAD';  b B 'git push origin feat/x:dev'
g reset --hard HEAD~1; g merge --no-ff -m "Merge branch 'feat/x' into dev" feat/x
b A 'git push origin dev';  b A 'git push'
b B 'git push --force-with-lease origin dev'
b A 'git push origin v1.2.0'

# Attribution
g switch feat/x
b B $'git commit -m "feat(x): y" -m "Co-authored-by: Bot <b@x.com>"'
b B 'git commit -m "feat(x): y 🤖 Generated with Claude Code"'
b B 'git tag -a v1.0.0 -m "v1.0.0 https://claude.ai/code"'
b A 'git commit -m "feat(x): add the claude integration page"'

RAFI_GUARD=off b A 'rm -rf x'

[ $fails -eq 0 ] && echo "All guard tests passed." || echo "$fails guard test(s) failed."
exit $((fails > 0))
