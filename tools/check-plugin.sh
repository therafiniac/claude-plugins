#!/usr/bin/env bash
# Structural checks for the rafi and brain plugins. Run from the repo root: tools/check-plugin.sh
# Optional: BASE_REF=origin/main also checks that a change to plugins/rafi raised the version.
set -uo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
plugin="$root/plugins/rafi"
fail=0
err() { printf 'FAIL: %s\n' "$1"; fail=1; }

# 1. JSON files parse.
for f in "$root/.claude-plugin/marketplace.json" "$plugin/.claude-plugin/plugin.json" "$plugin/hooks/hooks.json"; do
  jq empty "$f" 2>/dev/null || err "invalid JSON: ${f#$root/}"
done

# 2. Versions match.
v_plugin=$(jq -r '.version' "$plugin/.claude-plugin/plugin.json")
v_market=$(jq -r '.plugins[] | select(.name=="rafi") | .version' "$root/.claude-plugin/marketplace.json")
[ "$v_plugin" = "$v_market" ] || err "version mismatch: plugin.json $v_plugin, marketplace.json $v_market"

# 3. Version raised when the plugin changed (CI only).
if [ -n "${BASE_REF:-}" ] && git -C "$root" rev-parse -q --verify "$BASE_REF" >/dev/null; then
  if ! git -C "$root" diff --quiet "$BASE_REF"...HEAD -- plugins/rafi; then
    v_base=$(git -C "$root" show "$BASE_REF:plugins/rafi/.claude-plugin/plugin.json" | jq -r '.version')
    [ "$v_base" != "$v_plugin" ] || err "plugins/rafi changed but version is still $v_plugin (raise it in both manifests)"
  fi
fi

# 4. Skills: frontmatter with a matching name and a description.
for f in "$plugin"/skills/*/SKILL.md "$root"/plugins/brain/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  head -n 1 "$f" | grep -qx -- '---' || { err "skills/$dir: no frontmatter"; continue; }
  fm=$(sed -n '2,/^---$/p' "$f")
  name=$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')
  [ "$name" = "$dir" ] || err "skills/$dir: name is '$name'"
  printf '%s\n' "$fm" | grep -q '^description: ..' || err "skills/$dir: missing description"
done

# 4b. brain plugin: manifest parses, versions match, raised when changed, referenced files exist.
brain="$root/plugins/brain"
jq empty "$brain/.claude-plugin/plugin.json" 2>/dev/null || err "invalid JSON: plugins/brain/.claude-plugin/plugin.json"
v_brain=$(jq -r '.version' "$brain/.claude-plugin/plugin.json")
v_brain_m=$(jq -r '.plugins[] | select(.name=="brain") | .version' "$root/.claude-plugin/marketplace.json")
[ "$v_brain" = "$v_brain_m" ] || err "brain version mismatch: plugin.json $v_brain, marketplace.json $v_brain_m"
if [ -n "${BASE_REF:-}" ] && git -C "$root" rev-parse -q --verify "$BASE_REF:plugins/brain/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  if ! git -C "$root" diff --quiet "$BASE_REF"...HEAD -- plugins/brain; then
    v_base=$(git -C "$root" show "$BASE_REF:plugins/brain/.claude-plugin/plugin.json" | jq -r '.version')
    [ "$v_base" != "$v_brain" ] || err "plugins/brain changed but version is still $v_brain (raise it in both manifests)"
  fi
fi
grep -oh '\${CLAUDE_PLUGIN_ROOT}/[A-Za-z0-9_./-]*\.md' "$brain"/skills/*/SKILL.md | sort -u | while read -r ref; do
  [ -f "$brain/${ref#\$\{CLAUDE_PLUGIN_ROOT\}/}" ] || { echo "FAIL: brain references missing ${ref}"; exit 1; }
done || fail=1

# 5. Agents: frontmatter with name and description.
for f in "$plugin"/agents/*.md; do
  n=$(basename "$f" .md)
  sed -n '2,/^---$/p' "$f" | grep -q "^name: $n$" || err "agents/$n: name mismatch"
  sed -n '2,/^---$/p' "$f" | grep -q '^description: ..' || err "agents/$n: missing description"
done

# 6. Capability files: header lines, Options table, and one section per option.
for f in "$plugin"/stacks/capabilities/*.md; do
  c=$(basename "$f" .md)
  head -n 1 "$f" | grep -q '^# Capability: ' || err "capability $c: first line must be '# Capability: <Concern>'"
  for key in 'Kind: capability' 'Ask when: ' 'Default: ' 'Verified: '; do
    grep -q "^$key" "$f" || err "capability $c: missing '$key'"
  done
  grep -qx '## Options' "$f" || { err "capability $c: missing '## Options'"; continue; }
  rows=$(awk '/^## Options$/{t=1;next} t&&/^\|/{print} t&&/^$/{if(n++)exit}' "$f" | tail -n +3)
  # Every adopt or trial option has a section; hold options live in the table only.
  table_opts=$(printf '%s\n' "$rows" | awk -F'|' 'NF>3{gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$3); if($3!="hold") print $2}' | sort)
  all_opts=$(printf '%s\n' "$rows" | awk -F'|' 'NF>2{gsub(/^ +| +$/,"",$2); print $2}' | sort)
  statuses=$(printf '%s\n' "$rows" | awk -F'|' 'NF>3{gsub(/^ +| +$/,"",$3); print $3}')
  section_opts=$(sed -n 's/^## Option: //p' "$f" | sort)
  missing=$(comm -23 <(printf '%s\n' "$table_opts") <(printf '%s\n' "$section_opts"))
  extra=$(comm -23 <(printf '%s\n' "$section_opts") <(printf '%s\n' "$all_opts"))
  [ -z "$missing" ] || err "capability $c: no '## Option:' section for $(echo $missing)"
  [ -z "$extra" ] || err "capability $c: section without a table row: $(echo $extra)"
  for s in $statuses; do
    case "$s" in adopt|trial|hold) ;; *) err "capability $c: bad status '$s'" ;; esac
  done
  last_opt=$(grep -n '^## Option: ' "$f" | tail -n 1 | cut -d: -f1)
  shared=$(grep -n '^## Shared$' "$f" | cut -d: -f1)
  [ -z "$shared" ] || [ "$shared" -gt "$last_opt" ] || err "capability $c: '## Shared' must come after the last option"
done

# 7. Profiles start with the right heading.
for f in "$plugin"/stacks/frameworks/*.md; do head -n 1 "$f" | grep -q '^# Framework profile: ' || err "${f#$plugin/}: bad heading"; done
for f in "$plugin"/stacks/databases/*.md; do head -n 1 "$f" | grep -q '^# Database profile: ' || err "${f#$plugin/}: bad heading"; done

# 8. Hook scripts: executable and parse.
for f in "$plugin"/scripts/*.sh; do
  [ -x "$f" ] || err "${f#$plugin/}: not executable"
  bash -n "$f" || err "${f#$plugin/}: syntax error"
done
grep -o 'scripts/[a-z-]*\.sh' "$plugin/hooks/hooks.json" | while read -r s; do
  [ -f "$plugin/$s" ] || { echo "FAIL: hooks.json points at missing $s"; exit 1; }
done || fail=1

[ $fail -eq 0 ] && echo "All plugin checks passed."
exit $fail
