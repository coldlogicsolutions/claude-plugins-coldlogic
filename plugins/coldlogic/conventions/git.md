# Git

- Conventional commits: `type(scope): description`. Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `style`, `perf`. Scope is the module the commit touches.
- A `chore` commit never changes code, even indirectly.
- Branch before you start, with a type prefix and a kebab-case name: `feat/<desc>`, `fix/<desc>`, `explore/<desc>`. Never work on `main`.
- PR body: a `## Summary` section of bullets and a `## Test plan` section. Name the OpenSpec change a PR implements.
- Never force-push `main`. All changes reach `main` through pull requests. Never merge a PR from a session.
- `git commit --no-verify` is for emergencies only. Say so in the commit message when you use it.
