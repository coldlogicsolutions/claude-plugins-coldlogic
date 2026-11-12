# OpenSpec

- Every non-trivial change (process.md) gets an OpenSpec change, in every repo. A repo without `openspec/` is a setup gap, not an exemption: ticket it in that repo, ask Derek, and carry on with other work while you wait.
- A trivial change has no behavior or spec change, so it has no OpenSpec change, verify or archive. If it turns out to alter spec-level behavior, it isn't trivial.
- Call `/opsx:*` directly at each step. Don't hand-edit artifacts or work around the commands.
- A complex change has a design.md that covers the alternatives and the risks.
- After the gate, `/opsx:verify` and then `/opsx:archive`, on the feature branch and before the final `/code-review`, so the review covers the archive.
- If a review fix, before or after the PR opens, changes the archived tasks, design or specs, edit them on the same branch: the archived change's files and `openspec/specs/`. No command edits an archive, so this is the one hand edit; the gate's `openspec validate` checks it.
- If a change merged unarchived: `git fetch origin main`, archive it on a fresh `chore/archive-<id>` branch from `origin/main` (never the merged branch), and open an `Archive <id>` PR.
