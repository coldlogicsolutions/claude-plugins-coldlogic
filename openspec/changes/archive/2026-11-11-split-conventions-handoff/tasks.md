# Tasks

Edit project files with `Edit`/`Write` only (devenv.md). Run commands through `devenv shell --quiet -- <cmd>`.

## 1. Split the injection

- [x] 1.1 Rewrite `plugins/coldlogic/scripts/conventions.sh` as design.md ("A part table in conventions.sh") describes: keep `set -euo pipefail` and the `dir=` line; add the `table` array with the split from design.md; handle `--list`, `<part>` (header line `# coldlogic conventions, part <n> of <total>`, then that part's files in table order) and the usage error (stderr, exit 2). Update the header comment: each part's output stays under 9,000 characters, process.md comes first in part 1, and every new file must be added to the table. Verify with `CLAUDE_PLUGIN_ROOT=plugins/coldlogic plugins/coldlogic/scripts/conventions.sh 1 | head -3` (header, then `# Dev process (mandatory)`), `… --list` (eight lines), and `… ; echo $?` with no argument and with `3` (usage message, `2`).
- [x] 1.2 In `plugins/coldlogic/hooks/hooks.json`, replace the one conventions command in the matcher-less group with two entries, `"\"${CLAUDE_PLUGIN_ROOT}\"/scripts/conventions.sh 1"` and `… 2`. Leave the `staleness.sh` group alone. Verify with `jq . plugins/coldlogic/hooks/hooks.json`.

## 2. Validate every part

- [x] 2.1 In `scripts/validate.sh`, replace the single length check with the four steps in design.md ("validate.sh checks, in this order"), using the exact messages from the `conventions-injection` delta spec, and set `status=1` on each failure without exiting. Update the comment above it. Verify that `scripts/validate.sh` exits 0 on the tree.
- [x] 2.2 Check each failure path by hand, and revert after each one with `git checkout -- <file>` or `rm` (no commits): (a) create `plugins/coldlogic/conventions/new.md` → `new.md is in no part`; (b) duplicate `"2 git.md"` in the table → `git.md is in more than one part`; (c) add `"2 gone.md"` → `gone.md is in the table but doesn't exist`, then an abort; (d) remove the `conventions.sh 2` hook → `part 2 has no hook in hooks.json`; (e) add a `conventions.sh 3` hook → `hooks.json runs part 3, which the table doesn't define`; (f) temporarily set `limit=100` → one `conventions part <n>: … over the 100 limit` line per part. Verify that each message matches the spec and `git status` is clean afterwards.

## 3. Add the handoff convention

- [x] 3.1 Append the `## Cross-repo work` section from design.md ("The handoff text") to the end of `plugins/coldlogic/conventions/process.md`, word for word. Verify with `scripts/validate.sh` (exit 0) and `CLAUDE_PLUGIN_ROOT=plugins/coldlogic plugins/coldlogic/scripts/conventions.sh 1 | wc -c` (under 9,000).

## 4. Docs

- [x] 4.1 In `README.md`, change the conventions bullet to say the conventions are printed in parts, one SessionStart hook per part, each under 9,000 characters, and that a new `conventions/*.md` file has to be added to the part table in `scripts/conventions.sh`. Verify by reading it back.

## 5. Final checks

- [x] 5.1 Run `devenv shell --quiet -- scripts/validate.sh` and check that it exits 0 with no output. Don't pipe it.
- [x] 5.2 Run `devenv shell --quiet -- openspec validate --all --strict` and check that it passes.

## Workflow follow-up

- Gate, archive, review, commit and PR as process.md describes. The PR closes #30.
