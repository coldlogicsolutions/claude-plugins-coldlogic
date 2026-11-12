# Proposal

## Why

Sessions ask the user questions and decisions as text in chat. Those don't notify the user and are hard to answer one by one (issue #52). The `AskUserQuestion` tool notifies them and gives each question its own form. The conventions and agent briefs also name the user ("Derek") where the role, not the person, is meant.

## What Changes

- `plugins/coldlogic/conventions/tasks.md` is retitled `# Asking the user` and holds the rule: questions and decisions go through `AskUserQuestion`, one question per decision, up to 4 per call, 2 to 4 options each, the recommended one first and marked "(Recommended)"; each question stands on its own; subagents never call the tool but report standalone questions for the main session to ask; manual steps (a secret, a setting, a terminal command) still go in a `gh-app` issue assigned to `derekjw`, and the session then asks through the tool whether they're done. "a decision" leaves the manual-steps list. The file name and its part-2 entry in `scripts/conventions.sh` stay.
- The five agent briefs (`researcher`, `planner`, `planner-plus`, `coder`, `coder-plus`) say, where they report open questions or "stop and report", to report each as a standalone question with options, the recommended one first, and never to call `AskUserQuestion`.
- Every "Derek" and "Derek's" in `plugins/coldlogic/conventions/*.md` and `plugins/coldlogic/agents/*.md` becomes "the user" and "the user's", and the pronouns for him in github-identity.md follow. The `derekjw` login stays wherever it's functional.
- The existing "ask Derek / ask the user / tell the user" lines in process.md, git.md, openspec.md, github-identity.md, devenv.md and pull-requests.md point to tasks.md.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `plugin-agents`: a new requirement, "Agents report open questions for the main session to ask": every brief reports open questions as standalone questions with options, never calls `AskUserQuestion`, and doesn't name the user.

## Impact

- Files: `plugins/coldlogic/conventions/{tasks,process,git,openspec,github-identity,devenv,pull-requests}.md`, `plugins/coldlogic/agents/{researcher,planner,planner-plus,coder,coder-plus}.md`.
- Revised after review (2026-11-12): `conventions/tasks.md` is renamed to `asking.md`, so the `scripts/conventions.sh` table changes too (see design.md). `scripts/validate.sh` is untouched; both conventions parts must stay at most 9,000 characters (part 1 is 7,218 and part 2 is 6,085 today).
