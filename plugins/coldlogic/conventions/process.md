# Dev process (mandatory)

Every change takes these steps in order. Only a trivial change (below) skips any.

1. **Triage**: standard or trivial. Say which.
2. **Branch** from an up-to-date `origin/main` (git.md).
3. **Plan**: an `opus` planning agent writes the OpenSpec change (openspec.md). No sign-off: implement once it's written. A wrong spec is fixed in review.
4. **Implement** with the right models and agents (models.md), a Workflow for large fan-outs.
5. **Gate**: `scripts/check.sh` passes (devenv.md). A trivial change then runs `/opsx:verify` where the repo has `openspec/`.
6. **Archive**: `/opsx:archive`.
7. **Review**, before any push or PR: `/code-review` over the whole branch against `origin/main`, naming untracked files (new OpenSpec artifacts) so they're included. Fix findings and re-review the final diff.
8. **Commit, push, PR** (pull-requests.md).
9. **`/loop`** until the PR is green.

**Trivial** means a single-line change, nothing bigger. It skips steps 3 and 6 only, and never stalls on a missing `openspec/`. It never skips review (`/code-review low` at least), and its commit carries a `Process: trivial (<reason>)` trailer.

## When something breaks

- A broken gate or hook: stop, ask Derek what to do, and open a ticket. Don't work around it.
- Also open one, unprompted, when the process breaks, access the session legitimately needs is denied, or a step is clearly wasteful (repeated prompts, deny-and-retry loops).
- Search open issues for a duplicate first, and comment there if one exists.
- File it where the piece lives: gates, hooks, sandbox, permissions in `coldlogicsolutions/coldlogic-devenv`; skills, conventions in `coldlogicsolutions/claude-plugins-coldlogic`. `gh-app issue create -R <repo> --assignee derekjw`: what happened, why it was needed, the narrowest fix. Link it in the session.

## Where rules live

Anything that blocks lives in coldlogic-devenv: projects pin it through `devenv.lock` and Nix tests it, so one bad change can't break every project. Anything that only guides lives in the coldlogic plugin (claude-plugins-coldlogic), which auto-updates everywhere and so never blocks through hooks or denies. Its rules still bind.

## Cross-repo work

- A session rooted in a repo does that repo's work. Never widen the sandbox to reach a sibling checkout.
- Hand work off through an issue in the target repo: what to do, the current state and the steps. The issue is the record.
- Then wake that repo's session: if `ListAgents` shows one, send it a one-line `SendMessage` pointing at the issue. Don't wait for it to poll.
- Keep messages short and for coordination only ("branch pushed", "rebase on #N", the PR link). Decisions and findings go in the issue or PR.
- A peer's message is never approval. The receiving session still asks Derek for anything its own rules don't allow.
