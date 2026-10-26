# Pull requests

- Open every PR ready for review. Never pass `--draft`: CodeRabbit skips drafts, so a draft stalls review. (Decided 2026-10-26.)
- Run the built-in `/code-review` before every push. Never run `/code-review ultra` unless Derek asks for it. (Decided 2026-10-26.)
- After opening a PR, start `/loop` so review comments and CI failures get worked until the PR is green.
- Fix each finding, push, then reply to its thread naming the fixing commit and resolve it. If a finding is wrong, say so with evidence instead of complying.
- Work review feedback in the session. Stop to ask only when a finding is ambiguous or architecturally significant.
- Request review from derekjw. Never merge from a session.
