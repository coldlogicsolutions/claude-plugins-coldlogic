# GitHub identity

- Every GitHub action (PRs, comments, reviews, issues, API calls) goes out as `coldlogic-ai[bot]` through `gh-app`, from the devenv shell. Never plain `gh`.
- Commits are made locally as derekjw with the Co-Authored-By trailer, and pushed with the user's SSH key.
- Every PR requests review from derekjw (`--reviewer derekjw`). The user approves; auto-merge merges.
- Never export, print or store the App token, or copy or commit the App's private key.
- If `gh-app` reports the key missing, the fix is in Nix/1Password provisioning, not the repo: a manual step for the user (asking.md).
