# marketplace-and-plugin-manifest Specification

## Purpose
The `coldlogic-plugins` marketplace publishes one plugin, `coldlogic`, whose manifest declares the plugins every Cold Logic project uses as dependencies and carries no version, so that each commit is meant to be a release.

## Requirements

### Requirement: The marketplace publishes the coldlogic plugin
`.claude-plugin/marketplace.json` SHALL name the marketplace `coldlogic-plugins` and list exactly one plugin, `coldlogic`, with source `./plugins/coldlogic`, so its identifier is `coldlogic@coldlogic-plugins`.

Tested by: `scripts/validate.sh` (schema only).

#### Scenario: Marketplace entry
- **WHEN** `marketplace.json` is read
- **THEN** its `name` is `coldlogic-plugins` and its `plugins` array holds one entry, `coldlogic`, with source `./plugins/coldlogic`

### Requirement: The plugin declares the shared plugin set as dependencies
`plugins/coldlogic/.claude-plugin/plugin.json` SHALL declare as `dependencies` `codex@openai-codex`, and `pr-review-toolkit`, `code-review`, `commit-commands` and `context7` from `claude-plugins-official`. The README relies on Claude Code installing them when `coldlogic` is enabled; nothing in this repository checks that.

Tested by: `scripts/validate.sh` (schema only).

#### Scenario: Declared dependencies
- **WHEN** `plugin.json` is read
- **THEN** `dependencies` lists exactly those five plugins

#### Scenario: Adding a plugin everywhere
- **WHEN** a change adds a line to `dependencies`
- **THEN** the change touches only `plugin.json` (and `marketplace.json` if the plugin comes from a marketplace not yet listed)

### Requirement: Dependency marketplaces are listed for cross-marketplace use
The marketplace SHALL list in `allowCrossMarketplaceDependenciesOn` each other marketplace a dependency comes from: `claude-plugins-official` and `openai-codex`.

Tested by: `scripts/validate.sh` (schema only).

#### Scenario: Every dependency's marketplace is listed
- **WHEN** `plugin.json` and `marketplace.json` are read
- **THEN** the marketplace after `@` in each dependency appears in `allowCrossMarketplaceDependenciesOn`

### Requirement: The plugin has no version
`plugin.json` SHALL NOT declare a `version`. As `scripts/validate.sh` records, the intent is that each commit counts as a new version, so auto-update delivers every merge to `main` with no release step; nothing in this repository verifies that.

Tested by: `scripts/validate.sh` (schema only) tolerates the missing-version warning; nothing fails if a `version` is added.

#### Scenario: No version in the manifest
- **WHEN** `plugin.json` is read
- **THEN** it has no `version` key

### Requirement: The plugin registers its SessionStart hooks
`plugins/coldlogic/hooks/hooks.json` SHALL declare SessionStart command hooks whose commands start with `"${CLAUDE_PLUGIN_ROOT}"`: one `scripts/conventions.sh <part>` per conventions part with no matcher, and `scripts/staleness.sh` with the `startup` matcher.

Tested by: `scripts/validate.sh` (schema, and the conventions parts it checks against the table).

#### Scenario: Hook declarations
- **WHEN** `hooks.json` is read
- **THEN** `SessionStart` holds one entry without a matcher running `"${CLAUDE_PLUGIN_ROOT}"/scripts/conventions.sh 1` and `… 2`, and one with matcher `startup` running `"${CLAUDE_PLUGIN_ROOT}"/scripts/staleness.sh`
