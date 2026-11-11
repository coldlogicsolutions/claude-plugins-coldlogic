# Tasks

## 1. validate.sh

- [x] 1.1 Run `bash -n` per hook script, naming the failing file; verify by breaking `staleness.sh` in a scratch copy and seeing the script fail
- [x] 1.2 Guard the `jq` step and each `conv "$n"` so they print a message, set `status=1` and continue, and make a failing `conv --list` report before stopping (every check after it needs the table); verify with a fake non-JSON `claude` on `PATH` and with `process.md` renamed, each reporting and still running the later checks
- [x] 1.3 Update the `plugin-validation` Purpose in `openspec/specs/plugin-validation/spec.md` to drop "the first hook script's syntax"; verify `openspec validate --all --strict` passes

## 2. Gate and CI

- [x] 2.1 Add executable `scripts/check.sh` running `validate.sh` and `openspec validate --all --strict`, combining statuses; verify it passes, and fails with an invalid spec while still running both
- [x] 2.2 Make `.github/workflows/validate.yaml` install `@fission-ai/openspec@1.14.3` and run `scripts/check.sh`, rewording its comment (#35); verify `scripts/check.sh` passes locally (the CI job is in the PR's test plan)
- [x] 2.3 Point the README's Developing section at `scripts/check.sh` and reword the `validate.sh` description (#35); verify by reading it

## Workflow follow-up

- Archive the change on the branch before the PR merges.
