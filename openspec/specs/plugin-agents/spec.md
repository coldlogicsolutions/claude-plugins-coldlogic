# plugin-agents Specification

## Purpose
The coldlogic plugin ships the subagents that the dev process (conventions/process.md) assigns its research, planning and coding steps to. Each agent's frontmatter fixes its model and tool access, its body holds its brief, and validation keeps them in line with each agent's role.

## Requirements

### Requirement: The plugin ships five agents
`plugins/coldlogic/agents/` SHALL hold exactly `researcher.md`, `planner.md`, `planner-plus.md`, `coder.md` and `coder-plus.md`, loaded by the default `agents/` scan, so they're invoked as `coldlogic:<name>`. `plugin.json` SHALL NOT set `agents`.

Tested by: `scripts/validate.sh` (the agents table); nothing checks that `plugin.json` has no `agents` key.

#### Scenario: Listing the agents
- **WHEN** the plugin is enabled
- **THEN** `coldlogic:researcher`, `coldlogic:planner`, `coldlogic:planner-plus`, `coldlogic:coder` and `coldlogic:coder-plus` are available as subagent types

### Requirement: Each agent sets its own model
Each agent's frontmatter SHALL set `name` to its file's name without `.md`, a `description`, and `model` to an alias: `researcher` and `planner-plus` `fable`, `planner` and `coder-plus` `opus`, `coder` `sonnet`. Callers then don't pass `model`.

Tested by: `scripts/validate.sh`; `claude plugin validate` warns on a missing frontmatter or description, which fails the script.

#### Scenario: Calling an agent without a model
- **WHEN** a session spawns `coldlogic:coder` with no `model`
- **THEN** the subagent runs on `sonnet`

### Requirement: Tool access follows each agent's role
`researcher` SHALL list only `Read, Grep, Glob, Bash, WebFetch, WebSearch`. `planner` and `planner-plus` SHALL list `Read, Grep, Glob, Bash, Write, Edit, Skill, WebFetch, WebSearch`. `coder` and `coder-plus` SHALL set no `tools`, so they get every tool. No agent SHALL set `hooks`, `mcpServers` or `permissionMode`, which plugin agents ignore.

Tested by: `scripts/validate.sh` checks the write tools and the ignored keys; nothing checks the exact lists.

#### Scenario: The researcher can't edit
- **WHEN** `coldlogic:researcher` runs
- **THEN** it has no `Write`, `Edit` or `NotebookEdit` tool

#### Scenario: A coder has every tool
- **WHEN** `coldlogic:coder` runs
- **THEN** it has the same tools as an unrestricted subagent

### Requirement: Each agent's body is its brief
The researcher's body SHALL give the complex triggers and its output: a tier with the reason, findings, constraints and open questions. A planner's body SHALL require `/opsx:*` and writing only under `openspec/changes/`, and `planner-plus`'s also a design.md covering alternatives and risks. A coder's body SHALL give the gate and devenv rules.

Tested by: none (review only).

#### Scenario: Research output
- **WHEN** `coldlogic:researcher` finishes
- **THEN** its report opens with a tier, standard or complex, and the trigger or reason for it

#### Scenario: A complex plan
- **WHEN** `coldlogic:planner-plus` finishes a change
- **THEN** the change has a design.md with alternatives and risks

### Requirement: Validation checks every agent against the agents table
`scripts/validate.sh` SHALL hold a table of each agent's name, model and write access (`none`, `changes` or `any`), and fail, printing one line per problem to stderr, when an agent file isn't in the table, a listed agent has no file, a `name` differs from the file's, or a `model` isn't an alias or differs from the table.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: An agent missing from the table
- **WHEN** `agents/extra.md` exists and the table doesn't name it
- **THEN** the script prints `agents: extra.md is not in the agents table` to stderr and exits non-zero

#### Scenario: A listed agent with no file
- **WHEN** the table names `coder` and `agents/coder.md` doesn't exist
- **THEN** the script prints `agents: coder is in the table but coder.md doesn't exist` to stderr and exits non-zero

#### Scenario: A name that doesn't match its file
- **WHEN** `researcher.md` sets `name: research`
- **THEN** the script prints `agents: researcher.md: name is 'research', not 'researcher'` to stderr and exits non-zero

#### Scenario: A full model ID
- **WHEN** `researcher.md` sets `model: claude-opus-5-5`
- **THEN** the script prints `agents: researcher.md: model 'claude-opus-5-5' isn't an alias (haiku, sonnet, opus, fable)` to stderr and exits non-zero

#### Scenario: A model that differs from the table
- **WHEN** the table gives `planner-plus` `fable` and `planner-plus.md` sets `model: opus`
- **THEN** the script prints `agents: planner-plus.md: model is opus, the table says fable` to stderr and exits non-zero

### Requirement: Validation checks write access
For an agent the table marks `none` or `changes`, `scripts/validate.sh` SHALL fail when its frontmatter has no one-line comma-separated `tools`. For `none`, it SHALL also fail when `tools` lists `Write`, `Edit` or `NotebookEdit`. It SHALL fail when any agent sets `hooks`, `mcpServers` or `permissionMode`.

Tested by: `scripts/validate.sh`, on every CI run.

#### Scenario: A read-only agent with a write tool
- **WHEN** `researcher.md` lists `tools: Read, Grep, Edit`
- **THEN** the script prints `agents: researcher.md: a read-only agent lists Edit` to stderr and exits non-zero

#### Scenario: A restricted agent with no tools line
- **WHEN** `planner-plus.md` has no `tools` key, or gives it as a YAML list
- **THEN** the script prints `agents: planner-plus.md: no one-line tools list, so it would get every tool` to stderr and exits non-zero

#### Scenario: A key plugin agents ignore
- **WHEN** `planner-plus.md` sets `permissionMode: plan`
- **THEN** the script prints `agents: planner-plus.md: plugin agents ignore permissionMode` to stderr and exits non-zero

#### Scenario: Agents in line with the table
- **WHEN** the five agent files match the table
- **THEN** the agents checks print nothing
