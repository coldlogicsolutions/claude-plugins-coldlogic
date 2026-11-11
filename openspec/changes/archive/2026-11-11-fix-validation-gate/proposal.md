# Proposal

## Why

The conventions name `scripts/check.sh` as every repo's gate, but this repo has none (#33). The README and CI describe `scripts/validate.sh` as running `--strict` when it filters warnings itself (#35). And `validate.sh` syntax-checks only the first hook script and aborts on some failures, skipping the checks after them (#37).

## What Changes

- Add `scripts/check.sh`, the gate: it runs `scripts/validate.sh` and `openspec validate --all --strict`, runs both even when the first fails, and exits non-zero if either fails.
- CI's `validate` workflow installs OpenSpec 1.14.3 from npm, the version devenv provides, and runs `scripts/check.sh`. The README's Developing section points at `scripts/check.sh`.
- Reword the README and the workflow comment: `validate.sh` fails on any validation error or warning except the deliberately missing `version`, rather than "runs `--strict`".
- `validate.sh` syntax-checks every hook script, one `bash -n` per file.
- `validate.sh` no longer aborts part-way: validator output that isn't JSON and a failing `conventions.sh` each print a message and count as a failure, and the remaining checks still run.

## Capabilities

### New Capabilities

### Modified Capabilities
- `plugin-validation`: the syntax check covers every hook script; failures no longer abort the script; a new `check.sh` gate runs validation and OpenSpec validation; CI runs the gate.

## Impact

- `scripts/check.sh` (new), `scripts/validate.sh`, `.github/workflows/validate.yaml`, `README.md`.
- CI gains an npm install of `@fission-ai/openspec@1.14.3`.
