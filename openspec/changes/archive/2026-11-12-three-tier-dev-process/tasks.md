# Tasks

The exact text of every new or rewritten file is in design.md, "Appendix: target text". Copy it exactly with Write or Edit. Run each command through `devenv shell --quiet -- <cmd>`, in its own Bash call and unpiped.

## 1. Agents

- [x] 1.1 Create `plugins/coldlogic/agents/researcher.md`, `planner.md`, `planner-plus.md` and `coder.md` from the appendix. Verify that each file's frontmatter starts on line 1 with `---`.
- [x] 1.2 Create `plugins/coldlogic/agents/coder-plus.md` from `coder.md`, with the three frontmatter changes and the extra sentence the appendix gives. Verify that it differs from `coder.md` only in `name`, `model`, `description` and that sentence.
- [x] 1.3 Leave `plugins/coldlogic/.claude-plugin/plugin.json` unchanged (no `agents` key). Run `claude plugin validate --json plugins/coldlogic` and verify that the only warning is the missing `version` and that `contents` lists no agent errors or warnings.

## 2. Agents check

- [x] 2.1 In `scripts/validate.sh`, insert the agents check from the appendix after the `bash -n` loop and before the conventions comment. Verify that `bash -n scripts/validate.sh` passes and `scripts/validate.sh` exits 0.
- [x] 2.2 Exercise the failure paths in a scratch copy, never in the repo. Copy `scripts/`, `plugins/` and `.claude-plugin/` into a new directory under `$TMPDIR`. There, set `name: research`, `model: claude-opus-5-5` and `tools: Read, Edit` in `researcher.md`, delete `coder.md`, and add `extra.md`. Run that copy's `scripts/validate.sh`. Verify that it prints the `plugin-agents` spec's messages for each case and exits non-zero. Then delete the scratch copy.

## 3. Conventions

- [x] 3.1 Replace everything in `plugins/coldlogic/conventions/process.md` above `## When something breaks` with the appendix text. Verify with `git diff` that the "When something breaks", "Where rules live" and "Cross-repo work" sections are unchanged.
- [x] 3.2 Replace `plugins/coldlogic/conventions/models.md`, `openspec.md` and `pull-requests.md` with the appendix text. Verify that `git diff` shows only those files changing in this step.
- [x] 3.3 In `plugins/coldlogic/scripts/conventions.sh`, change the table to `"1 process.md" "1 openspec.md" "1 pull-requests.md"` and `"2 devenv.md" "2 git.md" "2 github-identity.md" "2 tasks.md" "2 models.md"`. Leave the rest of the script alone. Verify that `plugins/coldlogic/scripts/conventions.sh 1` starts with `# coldlogic conventions, part 1 of 2` followed by process.md, and that `scripts/validate.sh` reports no part over 9,000 characters (expect about 6,700 and 6,100).
- [x] 3.4 Search the conventions for leftover references: `grep -rnE 'research-|claude-code-guide|single-line|re-run' plugins/coldlogic/conventions`. Verify that it finds nothing.

## 4. Gate

- [x] 4.1 Run `scripts/check.sh` through devenv, unpiped. Verify that it exits 0 and that `openspec validate --all --strict` passes for this change.
- [x] 4.2 Run `claude plugin validate .` and `claude plugin validate plugins/coldlogic`. Verify that both pass, with the missing-version warning as the only warning.

## Workflow follow-up

> **Revised after review (2026-11-12):** the first two bullets are dropped. The explicit Fable limits are gone (design.md), so coldlogic-devenv#49 was closed without the hook, and #21 closes with this change's PR.

- ~~Cross-repo, done by the orchestrating session, not the coder: comment on coldlogicsolutions/coldlogic-devenv#49. Its hook should allow `coldlogic:researcher` and `coldlogic:planner-plus` on Fable and no other subagent type. It should not treat a missing `model` as Fable. If it can, it should deny `Write`/`Edit` outside `openspec/changes/` for `agent_type` `coldlogic:planner-plus`, and all `Write`/`Edit`/`NotebookEdit` for `coldlogic:researcher` (design.md, decisions 1 and 2).~~
- ~~Close #21 once coldlogic-devenv#49 ships, since this change replaces its policy text.~~
- `/opsx:verify`, then `/opsx:archive`, before the final `/code-review high` (this is a complex change).
