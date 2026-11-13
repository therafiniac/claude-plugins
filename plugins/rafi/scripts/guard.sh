#!/usr/bin/env bash
# PreToolUse guard. Blocks actions that must never happen, whatever CLAUDE.md or
# settings.json say (permission patterns are easy to sidestep, e.g. `rm -fr`).
#   Bash:              rm with recursive + force flags, skipping git hooks (--no-verify, HUSKY=0),
#                      reading .env files, and the git workflow rules:
#                      no direct commits, fast-forward merges, non-ff pulls, or rebases on main/dev;
#                      pushing main/dev only when the tip is a merge commit (or the root commit);
#                      no force push except --force-with-lease on work branches;
#                      no attribution lines in commit, merge, or tag messages
#   Read/Edit/Write:   .env files (except .env.example) and secrets/
#   Edit/Write:        lockfiles (change them through the package manager)
# Exit 2 blocks the tool call and shows the reason to Claude.
# Escape hatch for the human: start Claude Code with RAFI_GUARD=off in the environment.
set -uo pipefail
[ "${RAFI_GUARD:-on}" = "off" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

block() {
  printf 'Blocked by rafi guard: %s\n' "$1" >&2
  exit 2
}

is_env_file() {
  local base
  base=$(basename -- "$1")
  [[ "$base" =~ ^\.env(\..+)?$ ]] && [ "$base" != ".env.example" ]
}

case "$tool" in
  Read|Edit|Write|MultiEdit|NotebookEdit)
    path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
    [ -n "$path" ] || exit 0
    is_env_file "$path" && block "$path holds secrets. Use .env.example for variable names; ask the human for values."
    [[ "$path" =~ (^|/)secrets/ ]] && block "$path is under secrets/."
    if [ "$tool" != "Read" ]; then
      case "$(basename -- "$path")" in
        pnpm-lock.yaml|package-lock.json|yarn.lock|bun.lockb|bun.lock)
          block "lockfiles change only through the package manager (e.g. pnpm add, pnpm install)." ;;
      esac
    fi
    ;;

  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    [ -n "$cmd" ] || exit 0
    # Split into simple commands so each rule judges one invocation.
    segments=$(printf '%s\n' "$cmd" | sed -E 's/(\|\||&&|;|\||&|\$\(|`)/\n/g')

    # Branch state, updated as the command line switches branches.
    proj="${CLAUDE_PROJECT_DIR:-.}"
    cur_branch=$(cd "$proj" 2>/dev/null && git symbolic-ref --short -q HEAD 2>/dev/null || true)
    has_head=0; (cd "$proj" 2>/dev/null && git rev-parse -q --verify HEAD >/dev/null 2>&1) && has_head=1
    merging=0; mh=$(cd "$proj" 2>/dev/null && git rev-parse --git-path MERGE_HEAD 2>/dev/null) && [ -f "$proj/$mh" -o -f "$mh" ] && merging=1

    while IFS= read -r seg; do
      [[ "$seg" =~ (^|[[:space:]])HUSKY=0([[:space:]]|$) ]] && block "disabling git hooks (HUSKY=0)."
      # Drop wrappers and leading VAR=value assignments, then git's -C/-c options.
      seg=$(printf '%s' "$seg" | sed -E \
        -e 's/^[[:space:]]*//' \
        -e 's/^((sudo|command|env|exec|nohup|time)[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*//' \
        -e 's/^git[[:space:]]+((-C|-c)[[:space:]]+[^[:space:]]+[[:space:]]+)*/git /')
      [ -n "$seg" ] || continue
      read -r -a toks <<< "$seg"

      # rm with both recursive and force, in any flag order or spelling.
      if [ "${toks[0]}" = "rm" ]; then
        rec=0; force=0
        for tok in "${toks[@]:1}"; do
          case "$tok" in
            --recursive) rec=1 ;;
            --force) force=1 ;;
            --*) ;;
            -*) [[ "$tok" == *[rR]* ]] && rec=1; [[ "$tok" == *f* ]] && force=1 ;;
          esac
        done
        [ $rec -eq 1 ] && [ $force -eq 1 ] && block "recursive force delete. Delete specific paths without -f, or ask the human to run it."
      fi

      if [ "${toks[0]}" = "git" ]; then
        sub=${toks[1]:-}
        on_protected=0
        case "$cur_branch" in main|master|dev) on_protected=1 ;; esac

        # Follow branch switches inside one command line (git switch dev && git merge ...).
        if [ "$sub" = "switch" ] || [ "$sub" = "checkout" ]; then
          last=""
          for tok in "${toks[@]:2}"; do case "$tok" in -*) ;; *) last=$tok ;; esac; done
          # "git switch -c new base": the new branch is the first non-flag argument.
          for tok in "${toks[@]:2}"; do case "$tok" in -c|-C|-b|-B|--create) newb=1 ;; esac; done
          if [ "${newb:-0}" = 1 ]; then
            for i in "${!toks[@]}"; do case "${toks[$i]}" in -c|-C|-b|-B|--create) last=${toks[$((i+1))]:-$last} ;; esac; done
          fi
          newb=0
          [ -n "$last" ] && [ "$last" != "--" ] && cur_branch=$last
        fi

        if [ "$sub" = "commit" ] || [ "$sub" = "push" ] || [ "$sub" = "merge" ] || [ "$sub" = "rebase" ]; then
          for tok in "${toks[@]:2}"; do
            [ "$tok" = "--no-verify" ] && block "skipping git hooks (--no-verify). Fix what the hook reports instead."
            [ "$sub" = "commit" ] && [[ "$tok" =~ ^-[a-zA-Z]*n[a-zA-Z]*$ ]] && block "skipping git hooks (git commit -n). Fix what the hook reports instead."
          done
        fi

        if [ "$sub" = "commit" ] && [ $on_protected -eq 1 ] && [ $has_head -eq 1 ] && [ $merging -eq 0 ]; then
          block "direct commit on $cur_branch. $cur_branch changes only through --no-ff merges: create a branch from dev (git switch -c feat/<name> dev)."
        fi

        if [ "$sub" = "merge" ] && [ $on_protected -eq 1 ]; then
          ok=0
          for tok in "${toks[@]:2}"; do
            case "$tok" in --no-ff|--abort|--continue|--quit) ok=1 ;; --ff-only) ok=2 ;; esac
          done
          if [ $ok -eq 2 ]; then
            # Fast-forward is allowed only to sync with the same branch on the remote.
            synced=0
            for tok in "${toks[@]:2}"; do [ "$tok" = "origin/$cur_branch" ] && synced=1; done
            [ $synced -eq 1 ] || block "fast-forward merge into $cur_branch. Use git merge --no-ff <branch>."
          elif [ $ok -eq 0 ]; then
            block "merge into $cur_branch without --no-ff. Use git merge --no-ff <branch>."
          fi
        fi

        if [ "$sub" = "pull" ] && [ $on_protected -eq 1 ]; then
          ff=0; for tok in "${toks[@]:2}"; do [ "$tok" = "--ff-only" ] && ff=1; done
          [ $ff -eq 1 ] || block "git pull on $cur_branch without --ff-only. Use git pull --ff-only."
        fi

        if [ "$sub" = "rebase" ] && [ $on_protected -eq 1 ]; then
          for tok in "${toks[@]:2}"; do case "$tok" in --abort|--continue|--skip|--quit) continue 2 ;; esac; done
          block "rebasing $cur_branch rewrites shared history."
        fi

        if [ "$sub" = "push" ]; then
          args=()
          for tok in "${toks[@]:2}"; do
            case "$tok" in
              --force|-f) block "force push. Use --force-with-lease on your own work branch, never on main or dev." ;;
              --force-with-lease*) lease=1 ;;
              -*) ;;
              *) args+=("$tok") ;;
            esac
          done
          # args[0] is the remote; the rest are refspecs. With none, git pushes the current branch.
          refs=("${args[@]:1}")
          [ "${#refs[@]}" -eq 0 ] && refs=("$cur_branch")
          for ref in "${refs[@]}"; do
            [[ "$ref" == +* ]] && block "force push (+refspec). Use --force-with-lease on your own work branch."
            src=${ref%%:*}; dst=${ref##*:}
            [ -n "$src" ] || src=$dst
            [ "$src" = "HEAD" ] && src=$cur_branch
            [ "$dst" = "HEAD" ] && dst=$cur_branch
            dst=${dst#refs/heads/}
            case "$dst" in
              main|master|dev)
                [ "${lease:-0}" = 1 ] && block "force push to $dst."
                # Only a root commit (first push) or a merge commit may be the new tip.
                parents=$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && git rev-list --parents -n 1 "$src" -- 2>/dev/null | wc -w | tr -d ' ')
                if [ -n "$parents" ] && [ "$parents" -eq 2 ]; then
                  block "pushing $dst whose tip is not a merge commit. $dst changes only through --no-ff merges."
                fi
                ;;
            esac
          done
          lease=0
        fi

        # No attribution in commit, merge, or tag messages.
        if [ "$sub" = "commit" ] || [ "$sub" = "merge" ] || [ "$sub" = "tag" ]; then
          if printf '%s' "$cmd" | grep -Eiq 'co-authored-by|generated-by:|claude\.ai|anthropic\.com|generated (with|by) |🤖'; then
            block "attribution in the message (Co-authored-by, tool or AI names, generated-with notes). Remove it."
          fi
        fi
      fi

      # Reading a .env file or secrets/ through the shell.
      case "${toks[0]}" in
        cat|less|more|head|tail|bat|strings|xxd|od|grep|egrep|rg|awk|sed|source|.|cut|sort|diff|base64|nl)
          for tok in "${toks[@]:1}"; do
            tok=${tok//\"/}; tok=${tok//\'/}
            is_env_file "$tok" && block "$tok holds secrets. Read .env.example for variable names instead."
            [[ "$tok" =~ (^|/)secrets/ ]] && block "$tok is under secrets/."
          done
          ;;
      esac
    done <<< "$segments"
    ;;
esac
exit 0
