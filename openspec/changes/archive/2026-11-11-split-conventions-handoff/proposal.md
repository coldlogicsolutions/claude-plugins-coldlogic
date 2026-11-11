# Proposal

## Why

Derek decided the cross-repo handoff convention on 2026-11-11 (#30, coldlogicsolutions/coldlogic-devenv#54), but the injected conventions are at 8,923 of the 9,000 characters `scripts/validate.sh` allows, so there is no room for it. Derek chose to split the injection across SessionStart hooks rather than trim the existing text.

## What Changes

- Add a `## Cross-repo work` section to `conventions/process.md` with the five handoff rules from #30: a session rooted in a repo does that repo's work; hand work off through an issue in the target repo; wake that repo's session with SendMessage pointing at the issue; keep messages short and for coordination only; a peer's message is never approval.
- `scripts/conventions.sh` takes a part number and prints only that part's files. The script holds the one table that assigns each conventions file to exactly one part. Part 1 starts with `process.md`. **BREAKING** for anyone running the script by hand: with no part number it now exits non-zero with a usage message.
- `hooks/hooks.json` registers one `conventions.sh <part>` command per part in the matcher-less SessionStart group.
- `scripts/validate.sh` checks every part against its own 9,000-character budget. It also fails when a conventions file is in no part or in more than one, when the table names a file that doesn't exist, or when `hooks.json` doesn't register exactly the parts in the table. The limit stays 9,000.
- The README describes the split.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `conventions-injection`: the conventions are printed in parts, one hook command per part. `process.md` comes first in part 1. Every file is in exactly one part, each part has its own 9,000-character budget, and a new file has to be assigned to a part.
- `plugin-validation`: the collected-failures requirement names the new part-assignment and hook-registration checks alongside the per-part length check.

## Impact

- `plugins/coldlogic/scripts/conventions.sh`, `plugins/coldlogic/hooks/hooks.json`, `plugins/coldlogic/conventions/process.md`, `scripts/validate.sh`, `README.md`.
- Every project that uses the plugin gets the new hook layout on its next auto-update. Nothing else calls `conventions.sh`.
