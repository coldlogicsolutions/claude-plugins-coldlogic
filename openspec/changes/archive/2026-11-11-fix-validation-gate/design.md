# Design

## Context

`scripts/validate.sh` runs under `set -euo pipefail` and accumulates a `status`. Two steps escape that: `problems=$(jq …)` aborts when the validator prints non-JSON, and `part=$(conv "$n")` aborts when `conventions.sh` fails. `bash -n a.sh b.sh` parses only `a.sh`. CI installs Claude Code from npm and runs the script directly; it has no OpenSpec.

## Goals / Non-Goals

**Goals:** one gate command that matches what the conventions call the gate; no check can hide a later one.

**Non-Goals:** testing `validate.sh`'s failure paths in CI (they stay hand-checked); moving CI onto devenv.

## Decisions

- **`check.sh` is a thin wrapper.** It runs the two commands and combines their statuses. `validate.sh` keeps its name, because the spec, README and contributors already use it. Alternative: fold OpenSpec into `validate.sh`; rejected, since `validate.sh` is about the plugin and the gate is about the repo.
- **Guard each risky substitution with `if ! x=$(…); then …`.** Command substitution inside an `if` condition doesn't trigger `set -e`, so the step records the failure and continues. Keep `set -euo pipefail` for genuinely unexpected errors. Alternative: drop `set -e`; rejected, it would hide typos.
- **Pin OpenSpec in CI to 1.14.3** via `npm install -g @fission-ai/openspec@1.14.3`, the version devenv provides, so strict validation means the same locally and in CI. A Renovate bump of one and not the other is a risk accepted below.
- **`table=$(conv --list)` also gets a guard**: if it fails, report it, skip the conventions checks (every one needs the table) and fail. The `hooks.json` read and an empty validator report get guards too.

## Risks / Trade-offs

- [The CI OpenSpec pin drifts from devenv's] → Name the devenv source in a comment beside the pin so whoever bumps one sees the other.
- [Failure paths remain untested] → Exercise each by hand before the PR and record it in the test plan.
