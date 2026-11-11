# Proposal

## Why

`staleness.sh` says its coldlogic-devenv check "mirrors the module's `coldlogic:setup-freshness` task" (#34). But the module remembers the remote's `HEAD` for an hour, and the hook runs `git ls-remote` at every session start, which can take up to 3 seconds.

## What Changes

- The hook's coldlogic-devenv check uses the module's cache: the file `.devenv/state/coldlogic-freshness` in the project, one line `<epoch seconds> <remote> <rev>`.
- A cached entry is trusted only when its remote is the lock's, its revision equals the locked revision (so it says the lock is current), and it is under an hour old. Otherwise the hook runs `git ls-remote` as now, and on success writes the entry.
- A cache that can't be read or written is ignored: the check falls back to `git ls-remote`, and the hook still never fails.
- The shell's task and the hook now share one lookup an hour, so "keep the two in step" becomes true.

## Capabilities

### New Capabilities

### Modified Capabilities
- `setup-staleness`: the coldlogic-devenv pin check reuses a fresh cached remote `HEAD` and records each lookup.

## Impact

- `plugins/coldlogic/scripts/staleness.sh`.
- The hook now writes `.devenv/state/coldlogic-freshness` in the project, a file the shell already writes. `.devenv*` is gitignored by the module's projects.
