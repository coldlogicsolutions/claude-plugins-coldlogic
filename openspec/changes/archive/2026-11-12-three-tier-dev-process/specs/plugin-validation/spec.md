# Spec Delta

## MODIFIED Requirements

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
