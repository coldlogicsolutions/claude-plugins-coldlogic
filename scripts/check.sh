#!/usr/bin/env bash
# The gate (conventions/devenv.md): must pass before committing, and CI runs
# it. Runs every check even when an earlier one fails, and fails if any did.
set -euo pipefail

cd "$(dirname "$0")/.."
status=0
scripts/validate.sh || status=1
openspec validate --all --strict || status=1
exit "$status"
