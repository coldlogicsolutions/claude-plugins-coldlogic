# Spec Delta

## MODIFIED Requirements

### Requirement: process.md comes first
The script SHALL assign every `conventions/*.md` file to exactly one part in a single table, `process.md` first in part 1. `conventions.sh <part>` SHALL print the line `# coldlogic conventions, part <part> of <total>`, then that part's files once each in table order. `conventions.sh --list` SHALL print one `<part> <file>` line per entry.

Tested by: `scripts/validate.sh` checks every file is in exactly one part; nothing checks the order within a part.

#### Scenario: Order of the output
- **WHEN** the table's part 1 is `process.md`, `openspec.md`, `pull-requests.md` and there are two parts
- **THEN** `conventions.sh 1` prints `# coldlogic conventions, part 1 of 2`, then those three files in that order

#### Scenario: A new conventions file
- **WHEN** a change adds `conventions/new.md`
- **THEN** the change also adds `new.md` to one part in the table, and needs no change to `hooks.json` unless it adds a part

#### Scenario: Listing the table
- **WHEN** a developer runs `conventions.sh --list`
- **THEN** it prints one `<part> <file>` line for every file in the table and exits 0
