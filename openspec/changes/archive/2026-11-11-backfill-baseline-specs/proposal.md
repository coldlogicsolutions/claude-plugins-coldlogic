# Proposal

## Why

The conventions this plugin ships make OpenSpec mandatory in every repository (openspec.md, process.md), but this repository had no `openspec/` directory, so no change to it had specs to write deltas against. This change records what the marketplace and plugin do today, as the baseline later changes modify. It doesn't change any behaviour.

## What Changes

- Initialise OpenSpec in this repository (`openspec/config.yaml`, schema `spec-driven`).
- Ignore OpenSpec's generated Claude Code skills and commands in `.gitignore`, so coldlogic-devenv's `coldlogic:openspec-files` task generates them here as it does in every project.
- Add baseline specs for existing behaviour, taken from the code, with the README and comments as a guide. Each requirement names what tests it, or says that nothing does.

## Capabilities

### New Capabilities

- `conventions-injection`: the SessionStart hook that prints `conventions/*.md` into every session, `process.md` first, within a character budget.
- `setup-staleness`: the startup hook that reports a `coldlogic-devenv` pin behind its remote, OpenSpec skills from another CLI version, and prunable auto-installed plugins.
- `plugin-validation`: `scripts/validate.sh` (manifest validation with one tolerated warning, script syntax, the conventions budget) and the CI workflow that runs it.
- `marketplace-and-plugin-manifest`: the `coldlogic-plugins` marketplace entry, the `coldlogic` plugin manifest and its bundled `dependencies`, and the deliberate absence of a `version`.
- `devenv-lock-updates`: the `update-coldlogic-devenv` workflow, which moves the `coldlogic-devenv` pin and the inputs aligned with it, and proposes the result as an auto-merging PR.

### Modified Capabilities

None. No specs existed before this change.

## Impact

- New files only: `openspec/` and two `.gitignore` lines. No plugin, script or workflow changes, so projects that load the plugin see no difference.
- Later changes to this repository open an OpenSpec change against these specs.
