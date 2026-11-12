# Proposal

## Why

`conventions/process.md` lists 9 steps, but a session takes about 18, and the rest are scattered across git.md, pull-requests.md and openspec.md. "Trivial" means a single line, so almost every change pays the full process cost. The rules also contradict each other: the trivial path runs `/opsx:verify` with no change to verify, openspec.md re-runs verify after archive, standard changes have no review level, and review guidance is repeated in process.md and pull-requests.md. Agents are spawned ad hoc, so each caller restates the model and the brief. Issue #49 settles this with three tiers, an 18-step checklist and five defined agents, and it supersedes the Fable allowed-roles list from #21.

## What Changes

- **New `plugins/coldlogic/agents/`**, with five agents invoked as `coldlogic:<name>`: `researcher` (fable, read-only), `planner` (opus), `planner-plus` (fable, writes only OpenSpec changes), `coder` (sonnet) and `coder-plus` (opus). Each frontmatter sets the model, so callers don't pass `model`. Each body holds that agent's brief.
- **`scripts/validate.sh` checks the agents** against a table of name, model and write access. Every agent file is listed and every listed agent exists. `name` matches the file, `model` is an alias and matches the table, and no agent sets the keys plugin agents ignore (`hooks`, `mcpServers`, `permissionMode`). A read-only agent lists its tools and none of them writes. An OpenSpec-only agent lists its tools. ~~No Fable agent may write anything.~~ (dropped, see the revision note below)
- **`conventions/process.md` rewritten** around three tiers (trivial, standard, complex) and an 18-step checklist in Setup, Plan, Build, Review and Ship groups. The "When something breaks", "Where rules live" and "Cross-repo work" sections are kept unchanged. Trivial now means "no behavior or spec change", not "a single line".
- **`conventions/models.md` rewritten** around the five agents. ~~Fable runs only in `coldlogic:researcher` and `coldlogic:planner-plus`.~~ (dropped, see below) This replaces the `Explore`/`Plan`/`claude-code-guide`/`research-` list. **BREAKING** for sessions that run those built-in types on Fable.
- **`conventions/openspec.md`**: the trivial path drops `/opsx:verify`, and verify runs once, just before archive. Re-running verify after an archive fix is dropped. Editing archived artifacts by hand after a review fix is named as the one allowed hand edit.
- **`conventions/pull-requests.md`**: drops the review and thread-handling text that repeats process.md and points to its Review and Ship steps.
- **Conventions table rebalanced**: `models.md` moves from part 1 to part 2. The longer process.md would otherwise leave part 1 at 8,351 of its 9,000 characters.
- ~~**Cross-repo follow-up, not done here**: coldlogic-devenv#49's enforcement hook must allow `coldlogic:researcher` and `coldlogic:planner-plus` on Fable. It should also confine `planner-plus`'s `Write`/`Edit` to `openspec/changes/`, which nothing in this plugin can enforce.~~ (dropped, see below)

## Capabilities

### New Capabilities
- `plugin-agents`: the plugin's defined subagents. Covers which agents exist, their models, tool access and briefs, and how validation checks their frontmatter against the agents table.

### Modified Capabilities
- `plugin-validation`: "Failures are collected" adds the agents checks to the checks that `scripts/validate.sh` runs and reports together.
- `conventions-injection`: the "Order of the output" scenario names part 1's new files (`process.md`, `openspec.md`, `pull-requests.md`) after `models.md` moves to part 2.

## Impact

- New files: `plugins/coldlogic/agents/{researcher,planner,planner-plus,coder,coder-plus}.md`.
- Edited files: `plugins/coldlogic/conventions/{process,models,openspec,pull-requests}.md`, `plugins/coldlogic/scripts/conventions.sh` (table only) and `scripts/validate.sh` (new agents check).
- `plugin.json` is unchanged. Agents load from the default `agents/` directory, and setting an `agents` key would replace that scan.
- Every project gets the agents and the new process on its next plugin auto-update.
- Revised after review (2026-11-12): the explicit Fable limits are removed (design.md). Fable runs `researcher` and `planner-plus` with no restriction beyond the defaults, and the coldlogic-devenv#49 follow-up is dropped. The main checkout now stays on `main`, with all branch work in harness worktrees (git.md).
