# Design

## Context

The conventions reach every session through `scripts/conventions.sh`, which prints them in two parts, each at most 9,000 characters (`scripts/validate.sh`, `limit=9000`). tasks.md is in part 2, which prints 6,085 characters today; part 1 prints 7,218. The issue body cites "manual-follow-ups.md"; the real file is `conventions/tasks.md`, titled `# Manual follow-ups`.

## Decisions

- **Keep tasks.md, retitle it.** Renaming the file would touch the `table` in `scripts/conventions.sh` and every cross-reference. The title carries the meaning; files cite each other by name, so references to `tasks.md` keep working. *Revised after review (2026-11-12): renamed to `asking.md` after all, since "(tasks.md)" also reads as an OpenSpec change's tasks.md. The table and every reference are updated.*
- **Manual steps stay issues.** A secret, a setting or a terminal command (including entering `devenv shell` for stale settings) still goes in a `gh-app` issue assigned to `derekjw`, because the user does it outside the session and the issue is the record. The session then asks through `AskUserQuestion` whether it's done. Decisions move off the issue list: they're asked, not filed. *Revised after review (2026-11-12): a one-off step the session is waiting on now, like entering `devenv shell` for stale settings, is asked directly with the exact command and no issue. Otherwise every branch with stale settings would file one.*
- **Subagents report, the main session asks.** Subagents run in the background and can't hold the user's attention; the main session relays their questions through `AskUserQuestion`. Each agent brief carries this, so it holds even when a brief is read without the conventions.
- **"the user", not a name.** The plugin is shared guidance; the briefs and conventions describe a role. The `derekjw` login stays where it's functional: in commands and in github-identity.md's account lines.
- **Spec delta on plugin-agents only.** The `plugin-agents` requirement "Each agent's body is its brief" describes what each brief says. The new reporting rule was first planned as a MODIFIED version of it, but that made it too long for `openspec validate --strict` (over 500 characters), so at archive it became its own ADDED requirement, "Agents report open questions for the main session to ask". No main spec covers the conventions' content or names the user (`grep -rn Derek openspec/specs` finds nothing), so no other capability changes.

## Risks

- Part sizes: the new tasks.md adds about 600 characters to part 2, leaving about 2,300 spare; part 1 changes by under 100. The gate's validate step checks both.
