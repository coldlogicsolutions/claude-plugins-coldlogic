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
exit "$status"
