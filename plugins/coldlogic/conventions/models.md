# Models

- The main session runs the latest Opus and orchestrates. Set a different default per project with `claude.code.model`.
- Pass an explicit `model` whenever you spawn a subagent, including the built-in `Explore` and `Plan`, and give every subagent a `name`. Use the aliases, which track the latest versions:
  - Planning (design, architecture, working out an approach): `opus`, or `fable` for the hardest and longest-running problems.
  - Coding: `sonnet` for contained, well-specified changes, or `opus` for hard or security-sensitive work (auth, crypto, cross-cutting refactors).
  - Tasks (searching, running commands and reporting, mechanical edits): `haiku`, or `sonnet` when the result takes judgement.
- A fork always runs on the session's model. Spawn a named subagent when the work calls for a different one.
- A session running on Fable never writes code itself and never spawns a fork. Every code or file change goes through a subagent. If a safeguard cancels Fable's own work, retry that exact work through a subagent.
