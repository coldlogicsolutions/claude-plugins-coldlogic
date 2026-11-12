# plugin-validation Specification

## Purpose
`scripts/validate.sh` validates the marketplace and plugin manifests, every hook script's syntax and the conventions' parts, and `scripts/check.sh`, the gate CI runs on every pull request and push to main, runs it with OpenSpec validation.

## Requirements

### Requirement: Both manifests are validated
The script SHALL run `claude plugin validate --json` on the repository root (the marketplace) and on `plugins/coldlogic` (the plugin), from the repository root wherever it is invoked. It SHALL fail when either run exits non-zero, and SHALL print each error as `error: <path>: <message>` on stderr, under a header naming the target's path: `.:` for the marketplace, `plugins/coldlogic:` for the plugin.

Tested by: none (CI runs the script; nothing exercises its failure paths).

#### Scenario: Invalid plugin manifest
- **WHEN** `plugin.json` has a schema error
- **THEN** the script prints `plugins/coldlogic:` and the error to stderr and exits non-zero

#### Scenario: Invalid marketplace manifest
- **WHEN** `marketplace.json` has a schema error
- **THEN** the script prints `.:` and the error to stderr and exits non-zero

#### Scenario: Run from another directory
- **WHEN** a developer runs `../claude-plugins-coldlogic/scripts/validate.sh` from a sibling directory
- **THEN** it validates this repository's manifests

### Requirement: Warnings fail except the missing version
The script SHALL treat every validation warning as a failure, printing `warning: <path>: <message>`, except a warning on a `version` path whose message starts with `No version specified`, which the plugin triggers on purpose.

Tested by: none.

#### Scenario: Only the missing-version warning
- **WHEN** the only warning is that `plugin.json` has no version
- **THEN** the manifest checks pass

#### Scenario: Any other warning
- **WHEN** validation warns about anything else, such as an unknown field
- **THEN** the script prints the warning and exits non-zero

### Requirement: CI runs the validation
The `validate` workflow SHALL run `scripts/check.sh` on Ubuntu with Node 26, the latest `@anthropic-ai/claude-code` and `@fission-ai/openspec` 1.14.3 (the version devenv provides) from npm, on every pull request and every push to `main`.

Tested by: none (the workflow itself).

#### Scenario: Pull request
- **WHEN** a pull request is opened or updated
- **THEN** the `validate` job runs `scripts/check.sh` and fails when it does

### Requirement: Every hook script is syntax-checked
`scripts/validate.sh` SHALL run `bash -n` on each `plugins/coldlogic/scripts/*.sh` file separately, and SHALL fail, naming the file on stderr, when any of them has a syntax error.

Tested by: none (exercised by hand when this change was made).

#### Scenario: Syntax error in a later script
- **WHEN** `staleness.sh` has an unclosed `if` and `conventions.sh` is valid
- **THEN** the script prints `syntax: plugins/coldlogic/scripts/staleness.sh` and bash's error to stderr and exits non-zero

#### Scenario: All scripts valid
- **WHEN** every hook script parses
- **THEN** the syntax check passes

### Requirement: Failures are collected
`scripts/validate.sh` SHALL run every check even after one fails: the manifest validations, the syntax check, the agents checks (see `plugin-agents`), and the conventions checks (see `conventions-injection`), except that the conventions checks, which all need `conventions.sh --list`, are skipped when it fails. It SHALL print a message for each failure and exit non-zero if any failed, zero only when all pass.

Tested by: none (exercised by hand when this change was made).

#### Scenario: Two failures
- **WHEN** a manifest has a validation error and one conventions part is over budget
- **THEN** the script reports both and exits non-zero

#### Scenario: An agent failure and a conventions failure
- **WHEN** `researcher.md` lists `Edit` and one conventions part is over budget
- **THEN** the script reports both and exits non-zero

#### Scenario: Validator output that isn't JSON
- **WHEN** `claude plugin validate --json` on a target prints something `jq` can't parse
- **THEN** the script prints `<target>: can't read the validator's output:` with jq's error, then the start of the output, to stderr, still validates the other target and runs the later checks, and exits non-zero

#### Scenario: Validator prints nothing
- **WHEN** `claude plugin validate --json` on a target prints nothing
- **THEN** the script prints `<target>: the validator printed nothing` to stderr and exits non-zero

#### Scenario: The table can't be listed
- **WHEN** `conventions.sh --list` fails
- **THEN** the script prints `conventions: conventions.sh --list failed, so the conventions checks were skipped` to stderr and exits non-zero

#### Scenario: conventions.sh fails
- **WHEN** `conventions/process.md` is missing
- **THEN** the script prints `conventions: process.md is in the table but doesn't exist` and `conventions part 1: conventions.sh failed` to stderr, still checks the other parts, and exits non-zero

#### Scenario: All clear
- **WHEN** every check passes
- **THEN** the script prints nothing and exits 0

### Requirement: check.sh is the gate
`scripts/check.sh` SHALL run `scripts/validate.sh` and then `openspec validate --all --strict` from the repository root, wherever it is invoked. It SHALL run both even when the first fails, and SHALL exit non-zero if either fails.

Tested by: CI runs it on every pull request and push to `main`.

#### Scenario: OpenSpec validation fails
- **WHEN** `validate.sh` passes and a spec fails strict validation
- **THEN** `check.sh` prints OpenSpec's report and exits non-zero

#### Scenario: Both fail
- **WHEN** `validate.sh` fails
- **THEN** `check.sh` still runs OpenSpec validation and exits non-zero

#### Scenario: Both pass
- **WHEN** both pass
- **THEN** `check.sh` exits 0
