# Spec Delta

## MODIFIED Requirements

### Requirement: Failures are collected unless a check aborts the script
The script SHALL keep running after a manifest validation, syntax, conventions-length, part-assignment or part-hook check (see `conventions-injection`) fails, and SHALL exit non-zero if any failed and zero only when all pass. Under `set -euo pipefail`, validator output that isn't JSON SHALL abort it at the `jq` step, skipping the later checks, and a failing `conventions.sh` SHALL abort it with no message of its own (#37).

Tested by: none.

#### Scenario: Two failures that don't abort
- **WHEN** a manifest has a validation error and one conventions part is over budget
- **THEN** the script reports both and exits non-zero

#### Scenario: Several conventions failures
- **WHEN** one conventions file is in no part and another part is over budget
- **THEN** the script reports both and exits non-zero

#### Scenario: Validator output that isn't JSON
- **WHEN** `claude plugin validate --json` prints something `jq` can't parse
- **THEN** the script exits non-zero at that target without running the later checks

#### Scenario: conventions.sh fails
- **WHEN** `conventions/process.md` is missing
- **THEN** the script prints `conventions: process.md is in the table but doesn't exist` to stderr, then aborts with a non-zero status when `conventions.sh 1` fails, without a length message

#### Scenario: All clear
- **WHEN** every check passes
- **THEN** the script prints nothing and exits 0
