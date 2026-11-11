#!/usr/bin/env bash
# Prints the shared conventions into the session's context. A plugin can't
# carry CLAUDE.md, so SessionStart output is how always-on guidance arrives.
# Claude Code collapses a hook's output past 10,000 characters, so the
# conventions are split into parts, one hook per part (hooks/hooks.json), and
# each part's output stays under 9,000 characters (scripts/validate.sh checks).
# process.md opens part 1. The hooks run in parallel, so the parts can reach
# the context in any order: files cite each other by name, never by position.
# Every new conventions file must be added to the table below.
#   conventions.sh <part>   print that part
#   conventions.sh --list   print the table
set -euo pipefail

dir="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/conventions"

# "<part> <file>", in print order.
table=(
  "1 process.md" "1 openspec.md" "1 models.md" "1 pull-requests.md"
  "2 devenv.md" "2 git.md" "2 github-identity.md" "2 tasks.md"
)

usage() {
  echo "usage: conventions.sh <part>|--list" >&2
  exit 2
}

(( $# == 1 )) || usage

if [[ $1 == --list ]]; then
  printf '%s\n' "${table[@]}"
  exit 0
fi

total=0
files=()
for entry in "${table[@]}"; do
  n=${entry%% *}
  (( n > total )) && total=$n
  if [[ $n == "$1" ]]; then files+=("${entry#* }"); fi
done
(( ${#files[@]} > 0 )) || usage

echo "# coldlogic conventions, part $1 of $total"
for f in "${files[@]}"; do
  cat "$dir/$f"
done
