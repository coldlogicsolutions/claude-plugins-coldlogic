# Spec Delta

## Purpose

`scripts/validate.sh` is the repository's one check: it validates the marketplace and plugin manifests, the first hook script's syntax and the conventions' length, and CI runs it on every pull request and push to main.

## ADDED Requirements

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

### Requirement: Only the first hook script is syntax-checked
The script SHALL run `bash -n plugins/coldlogic/scripts/*.sh`, which parses only the first script in glob order (`conventions.sh`) and passes the rest to it as arguments, and SHALL fail when that script has a syntax error. A syntax error in any later script, such as `staleness.sh`, SHALL NOT fail the script (#37).

Tested by: none.

#### Scenario: Syntax error in conventions.sh
- **WHEN** `conventions.sh` has an unclosed `if`
- **THEN** the script exits non-zero

#### Scenario: Syntax error in staleness.sh
- **WHEN** `staleness.sh` has an unclosed `if` and `conventions.sh` is valid
- **THEN** the syntax check passes

### Requirement: Failures are collected unless a check aborts the script
The script SHALL keep running after a manifest validation, syntax or conventions-length check (see `conventions-injection`) fails, and SHALL exit non-zero if any failed and zero only when all pass. Under `set -euo pipefail`, validator output that isn't JSON SHALL abort it at the `jq` step, skipping the later checks, and a failing `conventions.sh` SHALL abort it with no message of its own (#37).

Tested by: none.

#### Scenario: Two failures that don't abort
- **WHEN** a manifest has a validation error and the conventions are over budget
- **THEN** the script reports both and exits non-zero

#### Scenario: Validator output that isn't JSON
- **WHEN** `claude plugin validate --json` prints something `jq` can't parse
- **THEN** the script exits non-zero at that target without running the later checks

#### Scenario: conventions.sh fails
- **WHEN** `conventions/process.md` is missing
- **THEN** the script exits non-zero without printing a conventions message

#### Scenario: All clear
- **WHEN** every check passes
- **THEN** the script prints nothing and exits 0

### Requirement: CI runs the validation
The `validate` workflow SHALL run `scripts/validate.sh` on Ubuntu with Node 26 and the latest `@anthropic-ai/claude-code` from npm, on every pull request and every push to `main`.

Tested by: none (the workflow itself).

#### Scenario: Pull request
- **WHEN** a pull request is opened or updated
- **THEN** the `validate` job runs the script and fails when it does
