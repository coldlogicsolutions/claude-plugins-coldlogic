# Design

## Context

coldlogic-devenv's `coldlogic:setup-freshness` task (its `devenv.nix`) runs at shell entry. It reads `${DEVENV_STATE:-$DEVENV_ROOT/.devenv/state}/coldlogic-freshness`, trusts an entry only when it says the lock is current and is under an hour old, and otherwise runs `git ls-remote` and rewrites the entry. The hook runs outside the shell, so `DEVENV_STATE` and `DEVENV_ROOT` are unset; its root is `$CLAUDE_PROJECT_DIR` or the working directory.

## Goals / Non-Goals

**Goals:** the same cache, format and trust rule as the module, so either one warms it for the other.

**Non-Goals:** sharing code with the module. The plugin and module ship separately, and the hook can't depend on the shell.

## Decisions

- **Same file, at `$root/.devenv/state/coldlogic-freshness`.** That's where the module's task writes when `DEVENV_STATE` has its default. Alternative: a plugin-owned cache under `~/.cache`; rejected, since it would make two lookups an hour, not one, and the "keep in step" comment would stay false.
- **Trust only an entry that says the lock is current.** It's the module's rule. A cached newer `HEAD` would keep reporting "behind" right after `devenv update`, until the entry expired. Re-fetching whenever the lock is behind costs one lookup per session only while there's something to report.
- **Write failures are silent** (`mkdir -p` and the write each `2>/dev/null || true`), as the hook must never fail the session.

## Risks / Trade-offs

- [The module changes the cache's path or format, and the two drift apart] → The hook's comment names the task and the shared file. A change in either breaks only the sharing, not correctness: each falls back to `ls-remote`.
- [A project overrides `DEVENV_STATE`] → The hook then misses the shell's entries and keeps its own at the default path. That's still correct, just two caches.
