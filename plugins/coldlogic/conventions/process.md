# Dev process (mandatory)

Every change takes the checklist below in order. Its tier decides which steps run, which agents do them and how hard review looks.

## Tiers

- **Trivial**: no behavior or spec change, such as typos, comments or version bumps. In conventions, agent briefs and specs, only a wording fix that changes no rule is trivial. It skips the Plan steps and the archive, never stalls on a missing `openspec/`, reviews at `low`, and its commit carries a `Process: trivial (<reason>)` trailer. If it turns out to change behavior, it's non-trivial: go to step 5, give the researcher the diff as the starting point, drop the trivial trailer, and review at the new tier's level.
- **Standard**: the researcher judges it so. Planned by `coldlogic:planner`, reviewed at `medium`.
- **Complex**: the researcher judges it so. Planned by `coldlogic:planner-plus` with a design.md covering alternatives and risks, reviewed at `high`. Triggers: security-sensitive work (auth, crypto, sandbox, guard, permissions), a cross-cutting refactor, cross-repo work, more than one spec capability, or an unclear approach.
- A tier only moves up. Re-reviews use the tier's level. The agents are in models.md.

## Checklist

**Setup**
1. **Triage**: trivial or non-trivial. Say which, and why.
2. `git fetch origin main`, and `git pull --ff-only` in the main checkout, which stays on `main`.
3. Take a harness worktree, even for a trivial change, and branch in it from `origin/main` with `--no-track`, named `<type>/<kebab-name>` (git.md).
4. `devenv shell --quiet -- true`. If it reports stale settings, ask Derek to enter `devenv shell` once.

**Plan** (non-trivial only)
5. **Research**: `coldlogic:researcher` reads the code and specs and returns its findings and a tier, standard or complex, with the reason.
6. **Plan**: `coldlogic:planner` (standard) or `coldlogic:planner-plus` (complex) gets the findings and writes the OpenSpec change with `/opsx:*` (openspec.md). No sign-off: implement once it's written. A wrong spec is fixed in review.

**Build**
7. **Implement**: a trivial change directly; otherwise `/opsx:apply` through `coldlogic:coder`, or `coldlogic:coder-plus` for hard or security-sensitive code. A Workflow for a large fan-out.
8. **Gate**: `scripts/check.sh` through devenv, unpiped, checking its exit status (devenv.md).
9. **Archive** (non-trivial only, by the main session): `/opsx:verify` (a gap goes back to step 7), then `/opsx:archive`, then the gate again.

**Review**
10. `/code-review <tier level>` over the whole branch against `origin/main`, naming untracked files (new OpenSpec artifacts) so they're included.
11. Fix the findings, rerun the gate, and re-review the final diff at the same level until it's clean.
12. If a fix changes the archived tasks, design or specs, update them on the branch (openspec.md).

**Ship**
13. Commit: a conventional message, the Co-Authored-By trailer, and the trivial trailer for a trivial change (git.md, github-identity.md, Tiers).
14. Push over SSH. Retry once after a network error, never after a denial.
15. `gh-app pr create --reviewer derekjw`, ready for review, with a Summary, a Test plan and the OpenSpec change's name (pull-requests.md).
16. `gh-app pr merge <n> -R <owner/repo> --auto --squash`.
17. `/loop` until CI is green.
18. For each PR review comment, Derek's or a bot's, repeat steps 11 to 14, then reply in its thread naming the fixing commit and resolve it. If the comment is wrong, reply with the evidence instead and change nothing.

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
