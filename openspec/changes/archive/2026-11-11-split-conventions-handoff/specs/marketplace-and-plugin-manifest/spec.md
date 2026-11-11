# Spec Delta

## MODIFIED Requirements

### Requirement: The plugin registers its SessionStart hooks
`plugins/coldlogic/hooks/hooks.json` SHALL declare SessionStart command hooks whose commands start with `"${CLAUDE_PLUGIN_ROOT}"`: one `scripts/conventions.sh <part>` per conventions part with no matcher, and `scripts/staleness.sh` with the `startup` matcher.

Tested by: `scripts/validate.sh` (schema, and the conventions parts it checks against the table).

#### Scenario: Hook declarations
- **WHEN** `hooks.json` is read
- **THEN** `SessionStart` holds one entry without a matcher running `"${CLAUDE_PLUGIN_ROOT}"/scripts/conventions.sh 1` and `… 2`, and one with matcher `startup` running `"${CLAUDE_PLUGIN_ROOT}"/scripts/staleness.sh`
