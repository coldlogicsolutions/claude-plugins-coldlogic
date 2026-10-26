# GitHub identity

- Every GitHub action a session takes goes out as `coldlogic-ai[bot]` through `gh-app`, which the devenv shell provides: opening PRs, comments, reviews, issues and API calls. `gh-app pr create …`, `gh-app pr comment …`, `gh-app issue create …`, `gh-app api …`. Never use plain `gh` for these.
- Commits are made locally as derekjw with the Co-Authored-By trailer, and pushed with his SSH key.
- Request review from derekjw on every PR (`--reviewer derekjw`). He approves and merges.
- Never export the App token, print it, or put it in a file. Never copy or commit the App's private key.
- If `gh-app` reports the key is missing, the fix is in the Nix/1Password provisioning, not the repo. Ask Derek.
