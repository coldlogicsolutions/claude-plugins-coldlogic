# Git

- Conventional commits: `type(scope): description`. Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `style`, `perf`. Scope is the module the commit touches. A `chore` commit never changes code, even indirectly.
- Branch with a type prefix and a kebab-case name (`feat/<desc>`). Never work on `main`.
- Branch from `origin/main` right after `git fetch origin main`, never from local `main`. If the main checkout is on `main` and clean, `git pull --ff-only` it.
- After branching, run `devenv shell --quiet -- true`. If it reports stale generated settings, ask the user to enter `devenv shell` once from a terminal; meanwhile only do work that doesn't need the new settings.
- Create branches with `--no-track` or `--detach`: tracking writes `.git/config`, which the sandbox protects.
- Make worktrees only through the harness: `isolation: "worktree"` on a subagent, or `EnterWorktree` in the main session. Never `git worktree add` or `git worktree remove`: the sandbox refuses to write a new worktree's `.git` file.
- A harness worktree starts at the session's HEAD, not `origin/main`. Its first steps, each its own Bash call: `git fetch origin main`, then `git switch --no-track -c <type>/<name> origin/main`, then `devenv shell --quiet -- true`.
- For parallel work, give each change its own worktree subagent. The main checkout holds at most one branch, and the main session orchestrates.
- PR body: `## Summary` bullets and `## Test plan`. Name the OpenSpec change it implements.
- Never force-push `main`. Everything reaches `main` through PRs.
- `git commit --no-verify` is for emergencies only, and the commit message says so.
