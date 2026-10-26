# GitHub identity

- Commits and pull requests are authored by derekjw (the `gh` keyring login), with the Co-Authored-By trailer. CodeRabbit bills per user and skips bot-authored PRs.
- Comments and issues created by a session go out as `coldlogic-ai[bot]` through `gh-app`, which the devenv shell provides: `gh-app issue create …`, `gh-app pr comment …`.
- Never export the App token, print it, or put it in a file. Never copy or commit the App's private key.
- If `gh-app` reports the key is missing, the fix is in the Nix/1Password provisioning, not the repo. Fall back to asking Derek.
