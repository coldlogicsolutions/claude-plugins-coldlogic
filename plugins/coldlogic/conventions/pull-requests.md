# Pull requests

- Review runs locally with the built-in `/code-review` before every push, including fixes after the PR opens (process.md). Never `/code-review ultra` unless Derek asks.
- Open every PR ready for review, never as a draft.
- Right after opening a PR, turn on squash auto-merge: `gh-app pr merge <n> -R <owner/repo> --auto --squash`. Scripts opening PRs across repos do it too. The ruleset still requires Derek's approval and CI. If a repo refuses auto-merge, ticket it (process.md).
- Fix each finding, push, then reply to its thread naming the fixing commit and resolve it. If a finding is wrong, say so with evidence.
- Stop to ask only when a finding is ambiguous or architecturally significant.
- Never merge from a session: no `gh-app pr merge` without `--auto`.
