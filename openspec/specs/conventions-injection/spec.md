# conventions-injection Specification

## Purpose
A plugin can't carry a CLAUDE.md, so the coldlogic plugin delivers its always-on conventions by printing them from a SessionStart hook into every session's context.

## Requirements

### Requirement: Conventions are printed at every session start
The plugin SHALL register `scripts/conventions.sh <part>` as a SessionStart command hook with no matcher once per part in the script's table, so every part runs on every session start (startup, resume, clear and compact). Together the parts SHALL print every `conventions/*.md` file.

Tested by: `scripts/validate.sh` runs every part on each CI run and checks that `hooks.json` registers exactly the table's parts; nothing checks the output's content.

#### Scenario: New session
- **WHEN** a session starts in a project with the `coldlogic` plugin enabled
- **THEN** the session's context contains the text of each file in `plugins/coldlogic/conventions/`, spread across one hook output per part

#### Scenario: Resumed or compacted session
- **WHEN** a session is resumed, cleared or compacted
- **THEN** every part's hook runs again and the conventions are printed again

### Requirement: process.md comes first
The script SHALL assign every `conventions/*.md` file to exactly one part in a single table, `process.md` first in part 1. `conventions.sh <part>` SHALL print the line `# coldlogic conventions, part <part> of <total>`, then that part's files once each in table order. `conventions.sh --list` SHALL print one `<part> <file>` line per entry.

Tested by: `scripts/validate.sh` checks every file is in exactly one part; nothing checks the order within a part.

#### Scenario: Order of the output
- **WHEN** the table's part 1 is `process.md`, `openspec.md`, `models.md`, `pull-requests.md` and there are two parts
- **THEN** `conventions.sh 1` prints `# coldlogic conventions, part 1 of 2`, then those four files in that order

#### Scenario: A new conventions file
- **WHEN** a change adds `conventions/new.md`
- **THEN** the change also adds `new.md` to one part in the table, and needs no change to `hooks.json` unless it adds a part

#### Scenario: Listing the table
- **WHEN** a developer runs `conventions.sh --list`
- **THEN** it prints one `<part> <file>` line for every file in the table and exits 0

### Requirement: Conventions are found from the plugin root
The hook SHALL read the conventions from `$CLAUDE_PLUGIN_ROOT/conventions`, or from the `conventions` directory beside its `scripts` directory when that is unset. A missing file in the requested part, a missing part argument, or an unknown part SHALL make it exit non-zero.

Tested by: `scripts/validate.sh` runs every part with `CLAUDE_PLUGIN_ROOT` set and checks every table file exists; the fallback and the argument errors are untested.

#### Scenario: Run from a checkout
- **WHEN** a developer runs `plugins/coldlogic/scripts/conventions.sh 1` with `CLAUDE_PLUGIN_ROOT` unset
- **THEN** it prints part 1 of the checkout's conventions

#### Scenario: process.md missing
- **WHEN** `conventions/process.md` doesn't exist
- **THEN** `conventions.sh 1` exits with a non-zero status

#### Scenario: No part or an unknown part
- **WHEN** `conventions.sh` runs with no argument, or with a part the table doesn't define
- **THEN** it prints a usage message to stderr and exits non-zero

### Requirement: The conventions stay within a character budget
Each part's printed output SHALL be at most 9,000 characters, a margin below the 10,000 characters past which Claude Code collapses a hook's output to a short preview. `scripts/validate.sh` SHALL fail, naming the part, its length and the limit, when any part exceeds it.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: Conventions over budget
- **WHEN** a change makes `conventions.sh 2` print 9,001 characters
- **THEN** `scripts/validate.sh` prints `conventions part 2: 9001 characters, over the 9000 limit` to stderr and exits non-zero

#### Scenario: Conventions within budget
- **WHEN** every part prints at most 9,000 characters, though together they print more
- **THEN** the length check passes

### Requirement: Validation checks every file is in exactly one part
`scripts/validate.sh` SHALL fail when a `conventions/*.md` file is in no part, when a file is in more than one part or twice in one, or when the table names a file that doesn't exist, printing one line per problem to stderr.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: A file in no part
- **WHEN** `conventions/new.md` exists and the table doesn't name it
- **THEN** `scripts/validate.sh` prints `conventions: new.md is in no part` to stderr and exits non-zero

#### Scenario: A file in two parts
- **WHEN** the table puts `git.md` in parts 1 and 2
- **THEN** `scripts/validate.sh` prints `conventions: git.md is in more than one part` to stderr and exits non-zero

#### Scenario: A listed file that doesn't exist
- **WHEN** the table names `gone.md` and `conventions/gone.md` doesn't exist
- **THEN** `scripts/validate.sh` prints `conventions: gone.md is in the table but doesn't exist` to stderr and exits non-zero

### Requirement: Validation checks every part has a hook
`scripts/validate.sh` SHALL fail when the parts that `hooks/hooks.json` passes to `conventions.sh` differ from the parts in the table, or run a part more than once, printing each missing, extra or repeated part to stderr.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: A part with no hook
- **WHEN** the table defines parts 1 to 3 and `hooks.json` runs only parts 1 and 2
- **THEN** `scripts/validate.sh` prints `conventions: part 3 has no hook in hooks.json` to stderr and exits non-zero

#### Scenario: A hook for a part that doesn't exist
- **WHEN** `hooks.json` runs `conventions.sh 3` and the table defines parts 1 and 2
- **THEN** `scripts/validate.sh` prints `conventions: hooks.json runs part 3, which the table doesn't define` to stderr and exits non-zero

#### Scenario: A part run twice
- **WHEN** `hooks.json` runs `conventions.sh 2` in two entries
- **THEN** `scripts/validate.sh` prints `conventions: hooks.json runs part 2 more than once` to stderr and exits non-zero
