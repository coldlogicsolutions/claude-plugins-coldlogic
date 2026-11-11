# OpenSpec

- Every change except a trivial one (process.md) gets an OpenSpec change, in every repo. A repo without `openspec/` is a setup gap, not an exemption: ticket it in that repo, ask Derek, and carry on with other work while you wait.
- Call `/opsx:*` directly at each step. Don't hand-edit artifacts or work around the commands.
- A trivial change has no OpenSpec change but still runs `/opsx:verify` where the repo has `openspec/`. If it alters spec-level behavior, it isn't trivial.
- Archive on the feature branch after the gate and before the final `/code-review`, so the review covers the archive.
- If a review fix, before or after the PR opens, changes the archived tasks, design or specs, update them on the same branch and re-run `/opsx:verify`.
- If a change merged unarchived: `git fetch origin main`, archive it on a fresh `chore/archive-<id>` branch from `origin/main` (never the merged branch), and open an `Archive <id>` PR.
