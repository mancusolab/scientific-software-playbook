---
name: executing-an-implementation-plan
description: Use when executing scientific implementation plans through compatibility command paths while preserving strict scientific execution gates.
user-invocable: false
---

# Executing an Implementation Plan (Scientific Parity)

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Inputs

1. Required implementation plan directory path.
2. Optional absolute working directory path.

## Workflow

1. Validate required implementation plan path exists and contains phase files.
2. If working directory is provided:
- require absolute path
- verify directory exists and is a git repository
- run execution from that directory
3. Resolve implementation guidance file (if present):
- `.scientific/implementation-plan-guidance.md`
- `.ed3d/implementation-plan-guidance.md` fallback
4. Invoke `execute-scientific-implementation-plan` and follow it exactly.
5. During delegate execution/review loops, surface delegate evidence to the user before proceeding.
6. Return final status as `completed` or `blocked` with per-phase evidence.

## Hard Stops

1. Do not continue when required artifacts are missing.
2. Do not skip failing-test-first evidence for behavior changes.
3. Do not hide delegate findings or verification output.
4. Do not mark completion when blocking review findings or coverage failures remain.
