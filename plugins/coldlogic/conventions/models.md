# Models

- A session running on Fable orchestrates and never writes code itself. Every code or file change goes through a subagent with an explicit `model`, and every subagent gets a `name`. Never spawn a fork from Fable.
- Pick the subagent model by task size:
  - `haiku`: small, mechanical, well-specified work (a one-file edit, a rename, running a script and reporting).
  - `sonnet`: the default for ordinary implementation (a contained fix, tests, porting a component, a PR description).
  - `opus`: hard or security-sensitive work (auth, crypto, cross-cutting refactors, architectural judgement).
- If a safeguard cancels Fable's own work, retry that exact work through a subagent.
