---
name: scientific-kickoff
description: Use at design start to select one scientific delivery path (provided-model, suggested-model, or existing-codebase-port) and record required readiness state before architecture planning continues.
user-invocable: false
---

# Scientific Kickoff

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Purpose

Select exactly one kickoff mode and capture the minimum scientific contract needed for the rest of the loop.

Allowed modes:
1. `provided-model`
2. `suggested-model`
3. `existing-codebase-port`

## Required Output

Write kickoff output to `.scientific/kickoff.md` with:

- `mode`
- `model_path_decided: yes`
- `codebase_investigation_complete_if_port: yes|n/a`
- `simulation_contract_complete_if_in_scope: yes|n/a`
- mode-specific evidence (see below)

If a design plan file already exists, mirror this kickoff output into its workflow-state/model-path sections.

## Kickoff Flow

1. Ask the user to pick one mode (single choice only).
2. Run mode-specific collection:

### Mode A: `provided-model`

Collect and record:
- model source(s) (file path, URL, or pasted equations)
- update/inference rules (if provided)
- solver preference (custom updates vs existing solvers)
- known mathematical risks/unknowns

Set state:
- `codebase_investigation_complete_if_port: n/a`

### Mode B: `suggested-model`

Collect and record:
- target scientific objective and data constraints
- 2-3 candidate model families with citations
- explicit user selection from candidates
- selected model rationale and known tradeoffs

Required support:
- run `scientific-internet-research-pass` when citations are needed or uncertain

Set state:
- `codebase_investigation_complete_if_port: n/a`

### Mode C: `existing-codebase-port`

Collect and record:
- source pin (local path or GitHub URL + commit/tag)
- behavior/parity targets
- explicit exclusions

Required support:
- run `scientific-codebase-investigation-pass` and capture file-level findings

Set state:
- `codebase_investigation_complete_if_port: yes` only after findings are captured

3. Ask whether simulation-based inference validation is in scope.
4. If simulation is in scope:
- run `simulation-for-inference-validation`
- set `simulation_contract_complete_if_in_scope: yes` once contract is explicit

5. If simulation is not in scope:
- set `simulation_contract_complete_if_in_scope: n/a`

6. Write `.scientific/kickoff.md` and summarize the chosen mode + readiness state.
7. Conclude kickoff with the required handoff instructions in the "Kickoff Handoff" section below.

## Kickoff Handoff

After kickoff output is written, guide the user to start design planning with kickoff handoff ingestion.

**Do NOT run full design orchestration from this skill.** Hand off to `starting-a-design-plan` (or `/start-design-plan`) explicitly.

Announce kickoff completion and provide next steps:

Kickoff complete! Kickoff handoff saved to `.scientific/kickoff.md`.

Ready to start design planning?

**IMPORTANT: Copy the command for your runtime below BEFORE clearing context or starting a new session.**

(1) Copy this command now:

Claude Code:
```
/start-design-plan <slug>
```

Codex:
```
$starting-a-design-plan <slug>
```

(2) Start fresh context (recommended):

Claude Code:
```
/clear  # if your runtime supports it
```

Codex:
```
/new  # if your runtime supports it
```

If neither `/clear` nor `/new` is available, open a new session/conversation in the same repository.

(3) Paste and run the copied command in the fresh session.

`starting-a-design-plan` (or `/start-design-plan`) must ingest `.scientific/kickoff.md` before clarification/brainstorming proceeds.

## Hard Stops

1. Do not continue without exactly one selected mode.
2. Do not mark kickoff complete if required mode-specific evidence is missing.
3. For `existing-codebase-port`, do not mark complete without codebase investigation findings.
4. If simulation is in scope, do not mark complete without a simulation contract.
