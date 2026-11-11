#!/usr/bin/env bash
# `claude plugin validate --strict`, minus the one warning this repo means to
# trigger: plugin.json has no `version`, so each commit is a new version and
# auto-update delivers it with no release step. Any other warning fails.
set -euo pipefail

cd "$(dirname "$0")/.."
status=0
for target in . plugins/coldlogic; do
  report=$(claude plugin validate --json "$target") || status=1
  problems=$(jq -r '
    [.manifest, (.contents // [])[]] | map(select(. != null)) |
    map((.errors // [])[] | "error: \(.path): \(.message)"),
        map((.warnings // [])[]
          | select((.path | test("(^|→ )version$")) and (.message | startswith("No version specified")) | not)
          | "warning: \(.path): \(.message)")
    | flatten | .[]' <<<"$report")
  if [[ -n "$problems" ]]; then
    echo "$target:" >&2
    echo "$problems" >&2
    status=1
  fi
done
bash -n plugins/coldlogic/scripts/*.sh || status=1

# The conventions are printed in parts, one SessionStart hook each. Check that
# every conventions file is in exactly one part, that hooks.json runs exactly
# the parts in the table, and that each part stays under a margin below the
# 10,000 characters past which a hook's output collapses to a short preview.
limit=9000
conv() { CLAUDE_PLUGIN_ROOT=plugins/coldlogic plugins/coldlogic/scripts/conventions.sh "$@"; }
table=$(conv --list)

for path in plugins/coldlogic/conventions/*.md; do
  f=${path##*/}
  count=$(awk -v f="$f" '$2 == f' <<<"$table" | wc -l)
  if (( count == 0 )); then
    echo "conventions: $f is in no part" >&2
    status=1
  elif (( count > 1 )); then
    echo "conventions: $f is in more than one part" >&2
    status=1
  fi
done
while read -r _ f; do
  if [[ ! -f plugins/coldlogic/conventions/$f ]]; then
    echo "conventions: $f is in the table but doesn't exist" >&2
    status=1
  fi
done <<<"$table"

table_parts=$(awk '{print $1}' <<<"$table" | sort -u)
hook_list=$(jq -r '.hooks.SessionStart[].hooks[].command
  | capture("conventions\\.sh (?<n>[0-9]+)$").n' plugins/coldlogic/hooks/hooks.json | sort)
hook_parts=$(uniq <<<"$hook_list")
for n in $(uniq -d <<<"$hook_list"); do
  echo "conventions: hooks.json runs part $n more than once" >&2
  status=1
done
for n in $(comm -23 <(echo "$table_parts") <(echo "$hook_parts")); do
  echo "conventions: part $n has no hook in hooks.json" >&2
  status=1
done
for n in $(comm -13 <(echo "$table_parts") <(echo "$hook_parts")); do
  echo "conventions: hooks.json runs part $n, which the table doesn't define" >&2
  status=1
done

for n in $table_parts; do
  part=$(conv "$n")
  if (( ${#part} > limit )); then
    echo "conventions part $n: ${#part} characters, over the $limit limit" >&2
    status=1
  fi
done
exit "$status"
