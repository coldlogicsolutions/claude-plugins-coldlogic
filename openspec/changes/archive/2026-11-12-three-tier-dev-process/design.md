# Design

## Context

See proposal.md, "Why". The facts below shape the approach. Each was checked on 2026-11-12 against Claude Code 2.1.322 and its docs (code.claude.com/docs/en/sub-agents and /plugins-reference).

- A plugin agent is `agents/<name>.md` with YAML frontmatter, namespaced `coldlogic:<name>`. `name` and `description` are required. `model` takes `haiku`, `sonnet`, `opus`, `fable`, a full ID or `inherit`, and a per-call `model` overrides it. `tools` is an allowlist: leave it out and the agent inherits every tool.
- `tools` restricts by tool only. A specifier such as `Bash(git log *)` doesn't narrow Bash in a subagent, and nothing confines `Write`/`Edit` to a path.
- Plugin agents ignore `hooks`, `mcpServers` and `permissionMode`, so a plugin agent can't carry its own PreToolUse guard. Hooks elsewhere get the agent's name as `agent_type`.
- `claude plugin validate` checks agent files only lightly. Tried on a scratch plugin, it warned on a missing frontmatter block and a missing `description`, and those warnings already fail `scripts/validate.sh`. It said nothing about a missing `name`, `model: gpt-9`, an unknown tool, an unknown key or `hooks` in a plugin agent. So name, model and tools need a check of our own.
- Conventions part 1 prints 5,813 characters today, against a 9,000 limit. With the new process.md (4,718 bytes) and models.md (1,666), part 1 would reach 8,351.
- The coldlogic guard in coldlogic-devenv already refuses shell edits and redirects into project files, including from subagents. That covers part of what a read-only Bash would otherwise leave open.

## Goals / Non-Goals

**Goals:**
- Every rule in the checklist is stated once. Other files point to it.
- Every guarantee about an agent that can be checked is checked in `scripts/validate.sh`. The design says plainly which guarantees are guidance only.

**Non-Goals:**
- Enforcing Fable's allowed agents, or `planner-plus`'s write paths, at runtime. Anything that blocks lives in coldlogic-devenv (process.md, "Where rules live"), so that's coldlogic-devenv#49.
- Checking the conventions' wording or the agents' briefs. Nothing checks conventions content today, and this change adds no such check.
- Changing git.md, devenv.md, github-identity.md or tasks.md.

## Decisions

> **Revised after review (2026-11-12):** Derek removed the explicit Fable limits. Fable gets no rules beyond the defaults: the limits existed only because a Fable orchestrator spawned Fable subagents by default, and the user-scoped Fable hook is gone. models.md no longer restricts which agents run on Fable or what Fable may write, validation no longer fails a Fable agent marked `any`, and the coldlogic-devenv#49 enforcement isn't needed. Each agent's `none`/`changes`/`any` write access stays, as part of its role. Decision 1's enforcement bullets and the Fable-specific risks are superseded. Later review rounds also reworded parts of process.md, models.md, planner-plus.md and the validate.sh tools check (verify before archive and gate again, the trivial tier for wording fixes, read-only fallbacks, rejecting tool specifiers and space-separated tools, the wrong-finding branch of step 18, agent descriptions naming steps rather than numbering them), and Derek added a rule: the main checkout stays on `main`, and all branch work, trivial included, happens in a harness worktree (git.md, step 3). Enforcement for the process is ticketed in coldlogic-devenv (#88 to #92, #51). So where the appendix and the shipped files differ, the shipped files win.

### 1. `planner-plus` on Fable: "never writes code", not "never changes files"

The current models.md says Fable "never writes code or changes files". #49 lets `planner-plus` write OpenSpec artifacts. The new rule reads: Fable never writes code; the researcher changes nothing; `planner-plus` writes only OpenSpec artifacts under `openspec/changes/`. Both planners' briefs say the same.

What's enforced:
- Validation fails if any Fable agent is marked `any` in the agents table.
- `planner-plus` must list its tools explicitly, so it never silently inherits `NotebookEdit`, MCP tools or `Agent`.

What isn't: `planner-plus` needs `Write` and `Edit` to create artifacts, and nothing in a plugin can confine those to a path. `tools` has no path syntax, plugin agents ignore `hooks`, and the plugin never blocks through hooks anyway.
- So the path rule is guidance, stated in models.md and in the agent's brief.
- The runtime fix belongs to coldlogic-devenv#49: a PreToolUse hook that denies `Write`/`Edit` outside `openspec/changes/` when `agent_type` is `coldlogic:planner-plus`. It's listed as a follow-up task.
- Alternative rejected: keep "Fable never changes files" and let `planner-plus` only draft text that an `opus` agent writes. That's two agents per complex plan, and it's the hand-off #49 means to remove.

### 2. The researcher's Bash: tool-level enforcement, command-level guidance

The researcher needs Bash for `git log`, `openspec show` and `gh-app issue view`.
- Enforced: the agent has no `Write`, `Edit` or `NotebookEdit` (validation checks this). The coldlogic guard refuses shell writes into the project, and the sandbox bounds the rest.
- Guidance only: Bash isn't limited to reading. `gh-app issue comment`, `git commit` or a write to `$TMPDIR` would run. The brief lists the read-only commands it may use and says it changes nothing.
- Alternative rejected: drop Bash from the researcher. Then it can't read issues, git history or `openspec show`, which the research step needs.

### 3. Verify runs once, before archive

Step 9 in #49 says archive "verifies the change before moving it". `/opsx:archive` doesn't: it checks that the artifacts are done and the tasks ticked off, and it syncs the specs. It never compares the code with the change.
- Step 9 is therefore "`/opsx:verify`, then `/opsx:archive`". This keeps #49's intent: no verify on the trivial path, none after archive.
- After the archive, review fixes that touch the archived tasks, design or specs are edited by hand on the branch, both the archived change's files and `openspec/specs/`. No `/opsx:*` command edits an archive. openspec.md names this as the one allowed hand edit, and the gate's `openspec validate --all --strict` checks its structure.
- This matches the current openspec.md, which already archives before the final review so the review covers the archive. It drops only the re-run of verify.

### 4. The planners also get Bash

#49 lists the planners' tools as "read, plus Write/Edit and Skill". But the `/opsx:*` skills run the `openspec` CLI through Bash. So both planners list `Read, Grep, Glob, Bash, Write, Edit, Skill, WebFetch, WebSearch`. The web tools are there for checking external docs, which this change needed itself.

### 5. Validation uses a table in `scripts/validate.sh`

The table gives each agent's name, model and write access (`none`, `changes` or `any`), the same way `conventions.sh` keeps a table for its parts. Validation checks each file against its entry (specs: `plugin-agents`).
- Alternative rejected: a custom frontmatter key such as `writes: none`. Claude Code ignores unknown keys silently, so it would look like a runtime control without being one.
- Alternative rejected: infer read-only from the model. That ties two independent facts together and can't tell `planner-plus` from the researcher.
- The parser reads one-line `key: value` frontmatter. A `tools` YAML list counts as no list for `none` and `changes` agents, because a check that can't read the list shouldn't pass it. This was prototyped and run against the five agents and a broken set; the outputs match the spec's scenarios.

### 6. Rebalance by moving `models.md` to part 2

Part 1 becomes `process.md`, `openspec.md` and `pull-requests.md`, at about 6,685 characters. Part 2 becomes `devenv.md`, `git.md`, `github-identity.md`, `tasks.md` and `models.md`, at about 6,093.
- Alternative rejected: a third part. It works, but it means another hook and a changed hooks.json and manifest scenario, for no gain while two parts fit.
- Alternative rejected: leave part 1 at 8,351. The next edit to process.md would break the gate.

### 7. Conventions text isn't specced

The conventions are guidance read by sessions, and nothing tests their content. Specifying them would mean copying the files into requirements. The exact target text lives in the appendix below and is reviewed like code.

### 8. The checklist points at git.md for branching

Step 3 says "branch from `origin/main` with `--no-track`, or take a harness worktree (git.md)". git.md's rule against `git worktree add`, and its first steps for a worktree, stay in git.md and aren't restated.

## Risks / Trade-offs

- [Sessions keep calling `Explore`/`Plan` on Fable] → models.md says "Never pass `model: fable`". The hook from coldlogic-devenv#49 will enforce it.
- [The user-scoped Fable hook treats a missing `model` as Fable and refuses the new agents] → Derek is removing that hook (#21, step 3). Until then a session can pass the agent's own model explicitly. The alias matches the frontmatter, so nothing changes.
- [`planner-plus` writes outside `openspec/changes/`] → It's guidance until coldlogic-devenv#49 ships the path check, and review covers the whole branch diff, so a stray write shows up.
- [The researcher runs a write command through Bash] → The guard refuses project writes, and the brief limits the commands. Outside the project, nothing stops it. Accepted for a Fable agent with no Write or Edit.
- [A safeguard cancels a Fable agent mid-task] → models.md says to rerun `planner-plus`'s work on `coldlogic:planner`, and the researcher's on `Explore` with `model: opus`, each told what its brief would have required (a design.md, a tier).
- [Agent briefs drift from the conventions] → Each brief cites the conventions file it follows instead of restating it, except the devenv and gate rules. Subagents don't get the SessionStart conventions, so those rules have to be in the brief.
- [The frontmatter parser is stricter than YAML] → It fails closed, and every message says what to change.

## Migration Plan

Merging to `main` ships everything on each project's next plugin auto-update. Rollback is a revert PR. Sequence with coldlogic-devenv#49: this change can merge first, because until that hook exists the Fable rule is guidance either way.

## Appendix: target text

The coder copies these exactly. Every file ends with a single newline.

### `plugins/coldlogic/conventions/process.md`

````markdown
# Dev process (mandatory)

Every change takes the checklist below in order. Its tier decides which steps run, which agents do them and how hard review looks.

## Tiers

- **Trivial**: no behavior or spec change, such as typos, comments or version bumps. Conventions, agent briefs and specs are behavior. It skips the Plan steps and the archive, never stalls on a missing `openspec/`, reviews at `low`, and its commit carries a `Process: trivial (<reason>)` trailer. If it turns out to change behavior, it's non-trivial: go to step 5.
- **Standard**: the researcher judges it so. Planned by `coldlogic:planner`, reviewed at `medium`.
- **Complex**: the researcher judges it so. Planned by `coldlogic:planner-plus` with a design.md covering alternatives and risks, reviewed at `high`. Triggers: security-sensitive work (auth, crypto, sandbox, guard, permissions), a cross-cutting refactor, cross-repo work, more than one spec capability, or an unclear approach.
- A tier only moves up. Re-reviews use the tier's level. The agents are in models.md.

## Checklist

**Setup**
1. **Triage**: trivial or non-trivial. Say which, and why.
2. `git fetch origin main`. If the main checkout is on a clean `main`, `git pull --ff-only` too.
3. Branch from `origin/main`, or take a harness worktree, as git.md says, named `<type>/<kebab-name>`.
4. `devenv shell --quiet -- true`. If it reports stale settings, ask Derek to enter `devenv shell` once.

**Plan** (non-trivial only)
5. **Research**: `coldlogic:researcher` reads the code and specs and returns its findings and a tier, standard or complex, with the reason.
6. **Plan**: `coldlogic:planner` (standard) or `coldlogic:planner-plus` (complex) gets the findings and writes the OpenSpec change with `/opsx:*` (openspec.md). No sign-off: implement once it's written. A wrong spec is fixed in review.

**Build**
7. **Implement**: a trivial change directly; otherwise `/opsx:apply` through `coldlogic:coder`, or `coldlogic:coder-plus` for hard or security-sensitive code. A Workflow for a large fan-out.
8. **Gate**: `scripts/check.sh` through devenv, unpiped, checking its exit status (devenv.md).
9. **Archive** (non-trivial only): `/opsx:verify`, then `/opsx:archive`.

**Review**
10. `/code-review <tier level>` over the whole branch against `origin/main`, naming untracked files (new OpenSpec artifacts) so they're included.
11. Fix the findings, rerun the gate, and re-review the final diff at the same level until it's clean.
12. If a fix changes the archived tasks, design or specs, update them on the branch (openspec.md).

**Ship**
13. Commit: a conventional message, the Co-Authored-By trailer, and the trivial trailer for a trivial change (git.md).
14. Push over SSH. Retry once after a network error, never after a denial.
15. `gh-app pr create --reviewer derekjw`, ready for review, with a Summary, a Test plan and the OpenSpec change's name (pull-requests.md).
16. `gh-app pr merge <n> -R <owner/repo> --auto --squash`.
17. `/loop` until CI is green.
18. For each PR review comment, Derek's or a bot's, repeat steps 11 to 14, then reply in its thread naming the fixing commit and resolve it.

## When something breaks
````

After that heading, the "When something breaks", "Where rules live" and "Cross-repo work" sections stay exactly as they are in the current file.

### `plugins/coldlogic/conventions/models.md`

````markdown
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

- If a safeguard cancels `planner-plus`, rerun the work on `coldlogic:planner`, told that the change is complex and needs a design.md with alternatives and risks. If it cancels the researcher, rerun it on `general-purpose` with `model: opus`, given the researcher's brief.
````

### `plugins/coldlogic/conventions/openspec.md`

````markdown
# OpenSpec

- Every non-trivial change (process.md) gets an OpenSpec change, in every repo. A repo without `openspec/` is a setup gap, not an exemption: ticket it in that repo, ask Derek, and carry on with other work while you wait.
- A trivial change has no behavior or spec change, so it has no OpenSpec change, verify or archive. If it turns out to alter spec-level behavior, it isn't trivial.
- Call `/opsx:*` directly at each step. Don't hand-edit artifacts or work around the commands.
- A complex change has a design.md that covers the alternatives and the risks.
- After the gate, `/opsx:verify` and then `/opsx:archive`, on the feature branch and before the final `/code-review`, so the review covers the archive.
- If a review fix, before or after the PR opens, changes the archived tasks, design or specs, edit them on the same branch: the archived change's files and `openspec/specs/`. No command edits an archive, so this is the one hand edit; the gate's `openspec validate` checks it.
- If a change merged unarchived: `git fetch origin main`, archive it on a fresh `chore/archive-<id>` branch from `origin/main` (never the merged branch), and open an `Archive <id>` PR.
````

### `plugins/coldlogic/conventions/pull-requests.md`

````markdown
# Pull requests

- Review, fixes and thread replies follow process.md's Review and Ship steps, before every push, including fixes after the PR opens. Never `/code-review ultra` unless Derek asks.
- Open every PR ready for review, never as a draft.
- Right after opening a PR, turn on squash auto-merge: `gh-app pr merge <n> -R <owner/repo> --auto --squash`. Scripts opening PRs across repos do it too. The ruleset still requires Derek's approval and CI. If a repo refuses auto-merge, ticket it (process.md).
- If a finding is wrong, say so in its thread with evidence instead of changing the code.
- Stop to ask only when a finding is ambiguous or architecturally significant.
- Never merge from a session: no `gh-app pr merge` without `--auto`.
````

### `plugins/coldlogic/agents/researcher.md`

````markdown
---
name: researcher
description: Researches a non-trivial change before it's planned (coldlogic process.md, step 5). Reads the code, specs, conventions and issue, and returns findings and a tier, standard or complex, with the reason. Read-only.
model: fable
tools: Read, Grep, Glob, Bash, WebFetch, WebSearch
---
You research one change for the coldlogic dev process. You change nothing: no file edits, commits, pushes, issues, comments or PRs.

- Use Bash only for commands that read: `git log`, `git diff`, `git show`, `openspec list`, `openspec show`, `gh-app issue view`, `gh-app pr view`. Run each through `devenv shell --quiet -- <cmd>`, in its own Bash call, unpiped.
- Read the issue or request, then the code, the specs under `openspec/specs/` and the conventions it touches. Check external docs wherever the change depends on them.

The change is non-trivial, so it's standard at least. It's complex if any of these hold:
- security-sensitive work: auth, crypto, sandbox, guard, permissions
- a cross-cutting refactor
- cross-repo work
- changes to more than one spec capability
- an approach that isn't clear yet

Return, briefly:
1. **Tier**: standard or complex, naming the trigger or the reason.
2. **Findings**: what exists now, with `file:line` references, and what the change has to touch.
3. **Constraints**: the specs, conventions and docs that bind the change, and any conflicts between them.
4. **Open questions**: what only Derek can settle.

Keep what you checked apart from what you assume.
````

### `plugins/coldlogic/agents/planner.md`

````markdown
---
name: planner
description: Writes the OpenSpec change for a standard change (coldlogic process.md, step 6) from the researcher's findings, with the /opsx commands. Writes only under openspec/changes/.
model: opus
tools: Read, Grep, Glob, Bash, Write, Edit, Skill, WebFetch, WebSearch
---
You write the OpenSpec change for one standard change, from the researcher's findings you're given. You plan it; you don't implement it.

- Write only under `openspec/changes/<id>/`. Never edit code, conventions, main specs or anything else, and never commit, push, or open issues or PRs.
- Create the change with `/opsx:propose` and refine it with the other `/opsx:*` commands, through the Skill tool. Don't hand-edit around them. If a command fails, report it; don't work around it.
- Run each tool through `devenv shell --quiet -- <cmd>`, in its own Bash call, unpiped.
- Ground every artifact in the code and specs, not the findings alone. Keep what you checked apart from what you assume.
- tasks.md: small, ordered tasks a `sonnet` coder can follow without guessing, ending with the gate, `scripts/check.sh` through devenv.
- Write design.md only where the approach needs explaining.

Report briefly: the change id, the files you wrote, each decision you made, and anything only Derek can settle.
````

### `plugins/coldlogic/agents/planner-plus.md`

````markdown
---
name: planner-plus
description: Writes the OpenSpec change, with a design.md, for a complex change (coldlogic process.md, step 6) from the researcher's findings, with the /opsx commands. Writes only under openspec/changes/.
model: fable
tools: Read, Grep, Glob, Bash, Write, Edit, Skill, WebFetch, WebSearch
---
You write the OpenSpec change for one complex change, from the researcher's findings you're given. You plan it; you don't implement it.

- Write only under `openspec/changes/<id>/`. Never edit code, conventions, main specs or anything else, and never commit, push, or open issues or PRs.
- Create the change with `/opsx:propose` and refine it with the other `/opsx:*` commands, through the Skill tool. Don't hand-edit around them. If a command fails, report it; don't work around it.
- Run each tool through `devenv shell --quiet -- <cmd>`, in its own Bash call, unpiped.
- Ground every artifact in the code and specs, not the findings alone. Keep what you checked apart from what you assume.
- design.md is required. It covers the alternatives you rejected and why, each risk and what mitigates it, and the open questions.
- tasks.md: small, ordered tasks a `sonnet` coder can follow without guessing, ending with the gate, `scripts/check.sh` through devenv. The planning should leave nothing hard for the coder to work out.

Report briefly: the change id, the files you wrote, each decision you made, and anything only Derek can settle.
````

### `plugins/coldlogic/agents/coder.md`

````markdown
---
name: coder
description: Implements an OpenSpec change with /opsx:apply (coldlogic process.md, step 7). The default coder, for contained, well-specified work.
model: sonnet
---
You implement one OpenSpec change with `/opsx:apply`, task by task, ticking each off in tasks.md when it's done.

- Run every tool through `devenv shell --quiet -- <cmd>`, each in its own Bash call (devenv.md).
- Change project files only with Edit and Write, never a shell edit or redirect.
- Before you report done, run the gate, `scripts/check.sh`, through devenv, unpiped, and check its exit status. Never weaken a test to pass it: fix the code, or report that the spec is wrong.
- Don't commit, push, archive or open PRs unless you're told to. The orchestrating session does those.
- If a command is blocked, don't retry it another way. Report what was blocked and why.
- If a task is ambiguous or the spec looks wrong, stop and report it instead of guessing.

Report briefly: the tasks done, the gate's result (its output if it failed), and anything left open.
````

### `plugins/coldlogic/agents/coder-plus.md`

Same as `coder.md`, with these three differences:
- `name: coder-plus`
- `model: opus`
- `description: Implements an OpenSpec change with /opsx:apply (coldlogic process.md, step 7) where the code is hard or security-sensitive (auth, crypto, sandbox, guard, permissions, cross-cutting refactors).`

Its first body paragraph also gains a second sentence:

````markdown
You implement one OpenSpec change with `/opsx:apply`, task by task, ticking each off in tasks.md when it's done. The code is hard or security-sensitive: name the invariant or threat each change protects, and test its failure paths, not only the happy one.
````

### `scripts/validate.sh`: agents check

Insert after the `bash -n` loop and before the conventions comment. It uses the script's existing `status`.

````bash
# The plugin's agents: "<name> <model> <writes>", where <writes> is what the
# agent may change: none, changes (OpenSpec changes only) or any. Every
# agents/*.md is listed here, and its frontmatter must match its entry. Tools
# can't confine an agent to a path, so the `changes` limit is the brief's.
agents=(
  "researcher fable none" "planner opus changes" "planner-plus fable changes"
  "coder sonnet any" "coder-plus opus any"
)
agents_dir=plugins/coldlogic/agents

# Prints each top-level `key: value` line of a file's frontmatter as `key value`.
frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    /^[A-Za-z][A-Za-z0-9_-]*:/ {
      k = $0; sub(/:.*/, "", k)
      v = substr($0, length(k) + 2); gsub(/^[ \t]+|[ \t]+$/, "", v)
      print k, v
    }' "$1"
}
field() { awk -v k="$1" '$1 == k { sub(/^[^ ]+ ?/, ""); print; exit }' <<<"$2"; }
has_field() { awk -v k="$1" '$1 == k { f = 1 } END { exit !f }' <<<"$2"; }

check_agents() {
  local path f entry name model writes fm value tool key
  local -a tools
  for path in "$agents_dir"/*.md; do
    [[ -e $path ]] || continue
    f=${path##*/}
    if ! printf '%s\n' "${agents[@]}" | awk -v n="${f%.md}" '$1 == n { f = 1 } END { exit !f }'; then
      echo "agents: $f is not in the agents table" >&2
      status=1
    fi
  done
  for entry in "${agents[@]}"; do
    read -r name model writes <<<"$entry"
    f=$name.md
    path=$agents_dir/$f
    if [[ ! -f $path ]]; then
      echo "agents: $name is in the table but $f doesn't exist" >&2
      status=1
      continue
    fi
    fm=$(frontmatter "$path")
    value=$(field name "$fm")
    if [[ $value != "$name" ]]; then
      echo "agents: $f: name is '$value', not '$name'" >&2
      status=1
    fi
    value=$(field model "$fm")
    case $value in
      haiku | sonnet | opus | fable)
        if [[ $value != "$model" ]]; then
          echo "agents: $f: model is $value, the table says $model" >&2
          status=1
        fi
        ;;
      *)
        echo "agents: $f: model '$value' isn't an alias (haiku, sonnet, opus, fable)" >&2
        status=1
        ;;
    esac
    for key in hooks mcpServers permissionMode; do
      if has_field "$key" "$fm"; then
        echo "agents: $f: plugin agents ignore $key" >&2
        status=1
      fi
    done
    [[ $writes == any ]] && continue
    value=$(field tools "$fm")
    # Only a bare comma-separated list can be checked tool by tool: a flow list,
    # quotes or a wildcard would hide a write tool from the check below.
    if [[ -z $value || $value == *[][\"\'*]* ]]; then
      echo "agents: $f: no one-line tools list, so it would get every tool" >&2
      status=1
      continue
    fi
    IFS=, read -ra tools <<<"$value"
    for tool in "${tools[@]}"; do
      tool=${tool//[[:space:]]/}
      case $tool in
        Write | Edit | NotebookEdit)
          if [[ $writes == none ]]; then
            echo "agents: $f: a read-only agent lists $tool" >&2
            status=1
          fi
          ;;
      esac
    done
  done
}
check_agents
````
