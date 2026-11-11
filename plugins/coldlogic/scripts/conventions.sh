#!/usr/bin/env bash
# Prints the shared conventions into the session's context. A plugin can't
# carry CLAUDE.md, so SessionStart output is how always-on guidance arrives.
# process.md goes first: the rest refer back to it. Keep the total well under
# 10,000 characters, past which the hook output collapses to a short preview.
set -euo pipefail

dir="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/conventions"
cat "$dir/process.md"
for f in "$dir"/*.md; do
  if [[ $f != */process.md ]]; then cat "$f"; fi
done
