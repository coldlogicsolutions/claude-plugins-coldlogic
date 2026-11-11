#!/usr/bin/env bash
# `claude plugin validate`, failing on any error or warning except the one this
# repo means to trigger: plugin.json has no `version`, so each commit is a new
# version and auto-update delivers it with no release step.
set -euo pipefail

cd "$(dirname "$0")/.."
status=0
# Each step records a failure in `status` and carries on, so one failure never
# hides the checks after it. A substitution in an `if` condition doesn't trip
# `set -e`.
for target in . plugins/coldlogic; do
  report=$(claude plugin validate --json "$target") || status=1
  if [[ -z "$report" ]]; then
    echo "$target: the validator printed nothing" >&2
    status=1
  elif ! problems=$(jq -r '
    [.manifest, (.contents // [])[]] | map(select(. != null)) |
    map((.errors // [])[] | "error: \(.path): \(.message)"),
        map((.warnings // [])[]
          | select((.path | test("(^|→ )version$")) and (.message | startswith("No version specified")) | not)
          | "warning: \(.path): \(.message)")
    | flatten | .[]' <<<"$report" 2>&1); then
    echo "$target: can't read the validator's output: $problems" >&2
    head -n 20 <<<"$report" >&2
    status=1
  elif [[ -n "$problems" ]]; then
    echo "$target:" >&2
    echo "$problems" >&2
    status=1
  fi
done

# `bash -n a.sh b.sh` parses only a.sh, so check each script on its own.
for script in plugins/coldlogic/scripts/*.sh; do
  if ! err=$(bash -n "$script" 2>&1); then
    echo "syntax: $script" >&2
    echo "$err" >&2
    status=1
  fi
done

# The conventions are printed in parts, one SessionStart hook each. Check that
# every conventions file is in exactly one part, that hooks.json runs exactly
# the parts in the table, and that each part stays under a margin below the
# 10,000 characters past which a hook's output collapses to a short preview.
limit=9000
conv() { CLAUDE_PLUGIN_ROOT=plugins/coldlogic plugins/coldlogic/scripts/conventions.sh "$@"; }

check_parts() {
  local table="$1" path f count n part
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

  local table_parts hook_list hook_parts
  table_parts=$(awk '{print $1}' <<<"$table" | sort -u)
  if ! hook_list=$(jq -r '.hooks.SessionStart[].hooks[].command
      | capture("conventions\\.sh (?<n>[0-9]+)$").n' plugins/coldlogic/hooks/hooks.json 2>&1); then
    echo "conventions: can't read the parts from hooks.json: $hook_list" >&2
    status=1
  else
    hook_list=$(sort <<<"$hook_list")
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
  fi

  for n in $table_parts; do
    if ! part=$(conv "$n"); then
      echo "conventions part $n: conventions.sh failed" >&2
      status=1
    elif (( ${#part} > limit )); then
      echo "conventions part $n: ${#part} characters, over the $limit limit" >&2
      status=1
    fi
  done
}

# Every conventions check needs the table, so without it they're skipped.
if table=$(conv --list); then
  check_parts "$table"
else
  echo "conventions: conventions.sh --list failed, so the conventions checks were skipped" >&2
  status=1
fi
exit "$status"
