# Models

- The main session runs the latest Opus and orchestrates (per project: `claude.code.model`).
- Every subagent gets an explicit `model` (built-in `Explore` and `Plan` too) and a `name`. Use the aliases:
  - Planning (design, writing the OpenSpec change): `opus`.
  - Coding: `sonnet` for contained, well-specified changes; `opus` for hard or security-sensitive work (auth, crypto, cross-cutting refactors).
  - Tasks (searching, running and reporting, mechanical edits): `haiku`, or `sonnet` when it takes judgement.
- A fork runs on the session's model. Spawn a named subagent for a different one.

## Fable

- Read-only research and planning only. A subagent may run on `fable` only if its `subagent_type` is `Explore`, `Plan` or `claude-code-guide`, or its `name` starts with `research-`. That check isn't a sandbox: give such an agent read-only work. On the hardest problems such an agent works out the approach, and an `opus` planner writes the change.
- Fable never writes code or changes files, as main session or subagent. A Fable session never forks (a fork inherits Fable) and routes every change through a subagent on another model, retrying there any work a safeguard cancelled.
