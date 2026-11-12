# Models

- The main session runs the latest Opus and orchestrates (per project: `claude.code.model`).
- Process work goes to the plugin's agents (process.md). Each sets its model in its frontmatter, so call it by `subagent_type` with a `name` and no `model`.

| Agent | Model | Writes | Used for |
|---|---|---|---|
| `coldlogic:researcher` | fable | nothing | findings and a tier, for every non-trivial change |
| `coldlogic:planner` | opus | `openspec/changes/` | the OpenSpec change for a standard change |
| `coldlogic:planner-plus` | fable | `openspec/changes/` | the OpenSpec change, with design.md, for a complex change |
| `coldlogic:coder` | sonnet | anything | implementation, by default |
| `coldlogic:coder-plus` | opus | anything | hard or security-sensitive code |

- Any other subagent (searching, running and reporting, mechanical edits) gets an explicit `model` and a `name`: `haiku`, or `sonnet` when it takes judgement. Built-in `Explore` and `Plan` too.
- A fork runs on the session's model. Spawn a named subagent for a different one.

## Fable

- If a safeguard cancels `planner-plus`, rerun the work on `coldlogic:planner`, told that the change is complex and needs a design.md with alternatives and risks. If it cancels the researcher, rerun it on `general-purpose` with `model: opus`, given the researcher's brief and told to stay read-only.
