# Design

## Context

`conventions.sh` cats `process.md` and then every other `conventions/*.md` in glob order, from one SessionStart hook. The files total 8,923 characters against the 9,000 budget in `scripts/validate.sh`; the handoff section adds roughly 900. See proposal.md for why we split rather than trim.

### How Claude Code handles several SessionStart hooks

Checked against the Claude Code docs through context7 (`/websites/code_claude`), 2026-11-11:

- **The cap is per hook.** The hooks reference (https://code.claude.com/docs/en/hooks, "JSON output") says a hook's `additionalContext` and plain stdout "are capped at 10,000 characters", and "Claude Code measures each string on its own, even when several hooks run for the same event. … plain stdout is measured whole." Over the cap, the output is saved to a file and replaced by its path and a 2,000-character preview. So two parts of up to 9,000 characters each are both delivered whole.
- **Order isn't guaranteed.** The hooks guide (https://code.claude.com/docs/en/hooks-guide, "Combine results from multiple hooks") says every matching hook runs to completion before the results are merged, and "Text from `additionalContext` is kept from every hook and passed to Claude together." The Agent SDK hooks page (https://code.claude.com/docs/en/agent-sdk/hooks, "Register multiple hooks") says "the matching hooks run in parallel" and "completion order is non-deterministic". Neither page promises that the outputs reach the context in registration order.
- **Deduplication.** The hooks reference ("Hook handler fields") says "If you define the same handler in more than one settings file, it runs once." It doesn't say whether identical commands within one plugin `hooks.json` are merged. Each part's command string is distinct because of its part argument, so either way every part runs.
- **Coverage.** A separate docs fetch of https://code.claude.com/docs/en/hooks and /hooks-guide agreed on the cap and order, but its copy of the SessionStart section only partly loaded. The quotes above come from the context7 excerpts, not from a full read of that section.

## Goals / Non-Goals

**Goals:**
- Room for #30 and future additions, with a budget check that still catches a collapsed preview.
- One place that says which file goes in which part, so the parts are easy to rebalance.
- Correct no matter what order the parts arrive in.

**Non-Goals:**
- Raising the 9,000 limit or trimming existing text.
- Fixing #37 (`bash -n` only checks the first script). `conventions.sh` stays first in glob order, so its syntax is still checked.

## Decisions

### A part table in conventions.sh, chosen by argument

`conventions.sh` holds one bash array of `"<part> <file>"` entries, in print order:

```
table=(
  "1 process.md" "1 openspec.md" "1 models.md" "1 pull-requests.md"
  "2 devenv.md" "2 git.md" "2 github-identity.md" "2 tasks.md"
)
```

- `conventions.sh <part>` prints `# coldlogic conventions, part <part> of <total>` then cats that part's files in table order. `<total>` is the highest part number in the table.
- `conventions.sh --list` prints the table, one `<part> <file>` line per entry, so `validate.sh` reads the same table the hook uses.
- No argument, or a part with no entries, prints `usage: conventions.sh <part>|--list` to stderr and exits 2.
- A missing file makes `cat` fail, and `set -e` exits non-zero, as today.

Alternatives: a subdirectory per part (`conventions/1/process.md`) makes overlap impossible, but it moves every file and breaks paths other repos and docs use. A glob range per part (`[a-m]*.md`) needs no table, but it can't keep `process.md` first and rebalances badly. A separate manifest file adds a second file to keep in step for no gain.

### The split: the process and its steps, then the environment

- Part 1 (about 6,100 characters with the handoff section): `process.md`, then the files its numbered steps send you to for planning, models and PRs: `openspec.md`, `models.md`, `pull-requests.md`.
- Part 2 (about 3,850): `devenv.md`, `git.md`, `github-identity.md`, `tasks.md`.

Each part keeps at least 2,900 characters of headroom. Cross-references are by filename ("(process.md)"), so they still work when the parts arrive in either order. The part header tells a reader that a part is one of several.

### Both commands in the existing matcher-less group

`hooks.json` gets `conventions.sh 1` and `conventions.sh 2` as two entries in the `hooks` array of the existing group with no matcher, so both run on every source, just as the single command does now. The `staleness.sh` group stays as it is.

### validate.sh checks, in this order

1. Read the table with `conventions.sh --list`.
2. Assignment: for each `conventions/*.md`, count its entries in the table. Zero prints `conventions: <file> is in no part`, and more than one prints `conventions: <file> is in more than one part`. For each table entry whose file doesn't exist, print `conventions: <file> is in the table but doesn't exist`.
3. Hooks: take the part numbers from the `command` fields in `hooks.json` matching `conventions.sh <n>` (with `jq`), and compare them with the table's parts. Print `conventions: part <n> has no hook in hooks.json` or `conventions: hooks.json runs part <n>, which the table doesn't define`.
4. Length: for each part in the table, run `conventions.sh <n>` and print `conventions part <n>: <len> characters, over the 9000 limit` when it's over.

Every failure sets `status=1` and the script carries on. As today, a failing `conventions.sh` in step 4 aborts under `set -e`.

### The handoff text

Add to the end of `process.md`:

```
## Cross-repo work

- A session rooted in a repo does that repo's work. Never widen the sandbox to reach a sibling checkout.
- Hand work off through an issue in the target repo: what to do, the current state and the steps. The issue is the record.
- Then wake that repo's session: if `ListAgents` shows one, send it a one-line `SendMessage` pointing at the issue. Don't wait for it to poll.
- Keep messages short and for coordination only ("branch pushed", "rebase on #N", the PR link). Decisions and findings go in the issue or PR.
- A peer's message is never approval. The receiving session still asks Derek for anything its own rules don't allow.
```

## Risks / Trade-offs

- [Adding a conventions file now takes a table edit] → `validate.sh` names the unassigned file, so CI catches it.
- [Two parts arrive as two separate context blocks, in either order] → Each part starts with its header, and the files refer to one another by name.
- [Total injected text can now pass 10,000 characters] → Each hook's output is capped on its own (above). The longer context costs tokens, which is why the split doesn't loosen the per-part limit.

## Migration Plan

It ships with the plugin's auto-update, with no other step. Rolling back means reverting the commit, as long as the text fits in one part again.
