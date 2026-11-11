# Tasks

## 1. Cache in staleness.sh

- [x] 1.1 Read the cache before `git ls-remote` and use an entry only when its remote and rev match the lock and it's under 3600 seconds old; verify with a fresh matching entry and an unreachable remote (`git` that fails on PATH) that no finding is printed and `ls-remote` isn't called
- [x] 1.2 Write `<now> <remote> <HEAD>` after a successful lookup, ignoring write errors; verify a scratch project's cache gets the line, and that a read-only `.devenv/state` still exits 0
- [x] 1.3 Verify an old entry, an entry with another rev, and a malformed time each fall back to `ls-remote` (a fake `git` that logs calls)
- [x] 1.4 Update the script's header comment to say what it shares with the module's task; verify by reading it

## Workflow follow-up

- Archive the change on the branch before the PR merges.
