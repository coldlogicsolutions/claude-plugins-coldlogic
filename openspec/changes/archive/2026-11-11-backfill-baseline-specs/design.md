# Design

## Context

coldlogic-devenv generates OpenSpec's Claude Code skills and commands wherever `openspec/config.yaml` exists and git ignores them. This repository had neither, so the task never ran here and the `/opsx:*` commands aren't available yet. The change was written with the `openspec` CLI from the devenv shell instead.

The repository is small: two manifests, two hook scripts, the conventions, one validation script and two workflows. Almost nothing here has tests. `scripts/validate.sh` checks manifest schemas, script syntax and the conventions' length, and is the only check CI runs.

## Goals / Non-Goals

**Goals:**
- Give the repository the same OpenSpec layout every consuming project gets.
- Record current behaviour, one capability per part that changes for its own reasons, with each requirement naming its test or saying it has none.

**Non-Goals:**
- Changing behaviour or adding tests. Gaps between code and docs that the specs expose are follow-ups.
- Specifying the conventions' content. They're guidance for sessions, not code behaviour, and change with every process decision; the specs cover the mechanism that delivers them.
- Specifying Renovate. `renovate.json` only extends `config:recommended` and configures nothing specific to this repository.

## Decisions

- **Baseline through a change, archived later, not hand-written main specs.** The specs reach `openspec/specs/` through `openspec archive`, which keeps a record of the backfill. This follows coldlogic-devenv's own backfill (coldlogicsolutions/coldlogic-devenv#55).
- **`openspec init --tools none`, and the skills from the shell.** The tracked tree gets only `openspec/`; the generated skills and commands stay ignored, as in every project.
- **Specs follow the code where it and the docs disagree.** A baseline that matched the README instead would describe behaviour nothing implements. Each disagreement is reported for a ticket instead.
- **The conventions budget lives in `conventions-injection`.** It's enforced by `validate.sh`, but it exists because of how SessionStart output is shown, so it belongs with the hook it protects. `plugin-validation` covers the script as a whole and refers to it.
- **The update workflow is specified as it is here, though it's a copy.** Its comment says each project gets a copy of the module's workflow; this repository's copy is still the code that runs here, so it gets a spec. A change to the module's copy is mirrored by a change here.

## Risks / Trade-offs

- [Specs drift from the code because nothing enforces them] → The mandatory process requires an OpenSpec change for non-trivial work. Requirements marked "Tested by: none" show where tests would help most.
- [A requirement misstates current behaviour] → Each was written from the code. Review corrects it, and a later change fixes the spec, not the code, when the code is right.
- [The conventions are close to their budget (8,920 of 9,000 characters)] → Out of scope here; `validate.sh` already fails a change that crosses it.
