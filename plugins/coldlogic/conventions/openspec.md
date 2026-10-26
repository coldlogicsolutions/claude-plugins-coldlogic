# OpenSpec

- Use OpenSpec for non-trivial features, refactors and fixes. Trivial changes (one-line fixes, typos, dependency bumps) can go straight to a commit.
- Call `/opsx:*` directly at each step. Don't hand-edit OpenSpec artifacts or work around the commands.
- Branch first, then start the change. Never implement on `main`.
- Before committing a code change that is not part of an active change, run `/opsx:verify` against the current specs. If the change alters spec-level behavior, open a new change first.
- Archive on the feature branch as the last commit before the PR merges, not in a follow-up PR.
- If a change was merged unarchived: `git fetch origin main`, archive it on a fresh `chore/archive-<id>` branch from the updated `origin/main` (never on the merged branch), and open an `Archive <id>` PR.
