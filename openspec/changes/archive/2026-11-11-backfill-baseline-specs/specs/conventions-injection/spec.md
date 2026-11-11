# Spec Delta

## Purpose

A plugin can't carry a CLAUDE.md, so the coldlogic plugin delivers its always-on conventions by printing them from a SessionStart hook into every session's context.

## ADDED Requirements

### Requirement: Conventions are printed at every session start
The plugin SHALL register `scripts/conventions.sh` as a SessionStart command hook with no matcher, so it runs for every session start source (startup, resume, clear and compact), and SHALL print the contents of every `conventions/*.md` file to standard output.

Tested by: `scripts/validate.sh` runs `conventions.sh` on every CI run, so a non-zero exit fails the gate; nothing checks the hook registration or what the output contains.

#### Scenario: New session
- **WHEN** a session starts in a project with the `coldlogic` plugin enabled
- **THEN** the session's context contains the text of each file in `plugins/coldlogic/conventions/`

#### Scenario: Resumed or compacted session
- **WHEN** a session is resumed, cleared or compacted
- **THEN** the hook runs again and the conventions are printed again

### Requirement: process.md comes first
The hook SHALL print `process.md` before any other conventions file, then every other `*.md` file in the directory in glob order, each exactly once.

Tested by: `scripts/validate.sh` runs `conventions.sh` on every CI run, so a non-zero exit fails the gate; nothing checks the order.

#### Scenario: Order of the output
- **WHEN** the conventions directory holds `devenv.md`, `git.md` and `process.md`
- **THEN** the output is `process.md`, then `devenv.md`, then `git.md`

#### Scenario: A new conventions file
- **WHEN** a change adds `conventions/new.md`
- **THEN** the hook prints it with no change to the script or `hooks.json`

### Requirement: Conventions are found from the plugin root
The hook SHALL read the conventions from `$CLAUDE_PLUGIN_ROOT/conventions`, and from the `conventions` directory beside its own `scripts` directory when `CLAUDE_PLUGIN_ROOT` is unset. A missing `process.md` SHALL make the hook exit non-zero.

Tested by: `scripts/validate.sh` runs `conventions.sh` with `CLAUDE_PLUGIN_ROOT` set on every CI run, so a missing `process.md` fails the gate; the fallback has no test.

#### Scenario: Run from a checkout
- **WHEN** a developer runs `plugins/coldlogic/scripts/conventions.sh` with `CLAUDE_PLUGIN_ROOT` unset
- **THEN** it prints the checkout's conventions

#### Scenario: process.md missing
- **WHEN** `conventions/process.md` doesn't exist
- **THEN** the hook exits with a non-zero status

### Requirement: The conventions stay within a character budget
The printed conventions SHALL be at most 9,000 characters, a margin below the 10,000 characters past which Claude Code collapses SessionStart output to a short preview. `scripts/validate.sh` SHALL fail, naming the length and the limit, when they exceed it.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: Conventions over budget
- **WHEN** a change makes the hook print 9,001 characters
- **THEN** `scripts/validate.sh` prints `conventions: 9001 characters, over the 9000 limit` to stderr and exits non-zero

#### Scenario: Conventions within budget
- **WHEN** the hook prints 8,920 characters
- **THEN** the length check passes
