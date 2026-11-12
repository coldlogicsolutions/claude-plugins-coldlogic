# Pull requests

- Review and fixes follow process.md's Review and Ship steps before every push, including fixes after the PR opens. Thread replies come after the push, naming the fixing commit. Never `/code-review ultra` unless the user asks.
- Open every PR ready for review, never as a draft.
- Right after opening a PR, turn on squash auto-merge: `gh-app pr merge <n> -R <owner/repo> --auto --squash`. Scripts opening PRs across repos do it too. The ruleset still requires the user's approval and CI. If a repo refuses auto-merge, ticket it (process.md).
- If a finding is wrong, say so in its thread with evidence instead of changing the code.
- Stop to ask (asking.md) only when a finding is ambiguous or architecturally significant.
- Never merge from a session: no `gh-app pr merge` without `--auto`.
