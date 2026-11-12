# Tasks

> Revised after review (2026-11-12): `conventions/tasks.md` was renamed to `asking.md`, with the `scripts/conventions.sh` table and every "(tasks.md)" reference updated, and the rule gained the one-off-step bullet. See design.md. The tasks below are as first planned.

All paths are under `plugins/coldlogic/`. Use Edit for every change. Replace each whole line shown with its new text exactly; leave every other line as it is.

## 1. The rule (conventions/tasks.md)

- [x] 1.1 Replace the whole of `conventions/tasks.md` (today a `# Manual follow-ups` title and one paragraph) with exactly:

```markdown
# Asking the user

- Ask every question or decision through the `AskUserQuestion` tool, never as a question in chat text: the user gets notified and answers each in its own form. One question per decision, up to 4 per call, each with 2 to 4 options, the recommended one first and marked "(Recommended)".
- Each question stands on its own, since the dialog can hide earlier text: name the ticket or item and the finding it depends on.
- Subagents never call `AskUserQuestion`. They report each open question standalone, with its options and the recommended one first, and the main session asks it.
- Anything the user has to do by hand (a secret, a setting, a terminal command) goes in an issue on the project's repo, never only in chat, a TODO or a local file: `gh-app issue create --assignee derekjw --title "<what to do>" --body-file -` (a heredoc, or a scratchpad file, not the repo), with why and the exact steps. Link it in the session, then ask through `AskUserQuestion` whether it's done.
```

Don't rename the file or touch `scripts/conventions.sh`.

## 2. Conventions that ask or name the user

- [x] 2.1 `conventions/process.md` line 18. Old: ``4. `devenv shell --quiet -- true`. If it reports stale settings, ask Derek to enter `devenv shell` once.`` New:
  ``4. `devenv shell --quiet -- true`. If it reports stale settings, the user has to enter `devenv shell` once from a terminal, a manual step (tasks.md).``
- [x] 2.2 `conventions/process.md` line 40: change `For each PR review comment, Derek's or a bot's,` to `For each PR review comment, the user's or a bot's,`. The rest of the line stays.
- [x] 2.3 `conventions/process.md` line 44. New:
  `- A broken gate or hook: stop, ask the user what to do (tasks.md), and open a ticket. Don't work around it.`
- [x] 2.4 `conventions/process.md` line 59. New:
  `- A peer's message is never approval. The receiving session still asks the user (tasks.md) for anything its own rules don't allow.`
- [x] 2.5 `conventions/git.md` line 7. New:
  ``- After branching, run `devenv shell --quiet -- true`. If it reports stale generated settings, the user has to enter `devenv shell` once from a terminal, a manual step (tasks.md); meanwhile only do work that doesn't need the new settings.``
- [x] 2.6 `conventions/openspec.md` line 3: change `ticket it in that repo, ask Derek, and carry on` to `ticket it in that repo, ask the user about it (tasks.md), and carry on`. The rest of the line stays.
- [x] 2.7 `conventions/github-identity.md` line 4. New:
  `- Commits are made locally as derekjw with the Co-Authored-By trailer, and pushed with the user's SSH key.`
- [x] 2.8 `conventions/github-identity.md` line 5. New:
  ``- Every PR requests review from derekjw (`--reviewer derekjw`). The user approves; auto-merge merges.``
- [x] 2.9 `conventions/github-identity.md` line 7. New:
  ``- If `gh-app` reports the key missing, the fix is in Nix/1Password provisioning, not the repo: a manual step for the user (tasks.md).``
- [x] 2.10 `conventions/devenv.md` line 16. New:
  ``- `.env` and its variants can't be read or written. For a new variable, add it to `.env.example`, and put what the real file needs in an issue for the user (tasks.md).``
- [x] 2.11 `conventions/pull-requests.md` line 3: change `Never `/code-review ultra` unless Derek asks.` to `Never `/code-review ultra` unless the user asks.`. The rest of the line stays.
- [x] 2.12 `conventions/pull-requests.md` line 5: change `The ruleset still requires Derek's approval and CI.` to `The ruleset still requires the user's approval and CI.`. The rest of the line stays.
- [x] 2.13 `conventions/pull-requests.md` line 7. New:
  `- Stop to ask (tasks.md) only when a finding is ambiguous or architecturally significant.`

## 3. Agent briefs

- [x] 3.1 `agents/researcher.md` line 23. New:
  ``4. **Open questions**: what only the user can settle, each as a standalone question with 2 to 4 options, the recommended one first. Never call `AskUserQuestion`: the main session asks them.``
- [x] 3.2 `agents/planner.md` line 17. New:
  ``Report briefly: the change id, the files you wrote, each decision you made, and anything only the user can settle, each as a standalone question with 2 to 4 options, the recommended one first. Never call `AskUserQuestion`: the main session asks them.``
- [x] 3.3 `agents/planner-plus.md` line 17: the same new text as 3.2.
- [x] 3.4 `agents/coder.md` line 13. New:
  ``- If a task is ambiguous or the spec looks wrong, stop and report it instead of guessing, as a standalone question with 2 to 4 options, the recommended one first. Never call `AskUserQuestion`: the main session asks it.``
- [x] 3.5 `agents/coder-plus.md` line 13: the same new text as 3.4.

## 4. Check

- [x] 4.1 Run `grep -rn "Derek" plugins/coldlogic/conventions plugins/coldlogic/agents` from the repo root. It must print nothing. (`derekjw` is lowercase and doesn't match.)
- [x] 4.2 Run `grep -rn "\bhis\b\|\bHe\b\|\bhim\b" plugins/coldlogic/conventions plugins/coldlogic/agents`. It must print nothing.
- [x] 4.3 Run `CLAUDE_PLUGIN_ROOT=plugins/coldlogic plugins/coldlogic/scripts/conventions.sh 1 | wc -c`, then the same with `2`, each in its own Bash call. Each must print at most 9000 (the gate's validate step also checks this).
- [x] 4.4 Run the gate: `devenv shell --quiet -- scripts/check.sh`, unpiped, and check its exit status is 0.
