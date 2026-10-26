#!/usr/bin/env bash
# Prints the shared conventions into the session's context. A plugin can't
# carry CLAUDE.md, so SessionStart output is how always-on guidance arrives.
set -euo pipefail

cat "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"/conventions/*.md
