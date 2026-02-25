---
name: starting-an-implementation-plan
description: Use when moving from an approved scientific design plan to executable implementation with plan-and-execute parity handoff semantics.
user-invocable: false
---

# Starting an Implementation Plan (Scientific Parity)

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Overview

Use this parity wrapper to preserve the classic branch -> plan -> execute handoff while keeping scientific gates strict.

## Required Input

1. Design plan path.

Optional inputs:
1. Implementation slug override.
2. Branch/worktree preference.

## Workflow

1. Create an orchestration tracker with `update_plan`:
- Validate design-plan readiness
- (conditional) Read implementation guidance
- Create scientific implementation plan
- Execution handoff

2. Validate design plan readiness before planning:
- path exists
- status is `Approved for Implementation`
- approval validation has no blocking failures

3. Resolve guidance files in this order:
- `.scientific/implementation-plan-guidance.md`
- `.ed3d/implementation-plan-guidance.md` (legacy fallback)
If found, read and apply guidance while generating phase tasks and review gates.

4. Invoke `start-scientific-implementation-plan` with the provided design-plan path and optional slug override.

5. Resolve and verify the absolute implementation plan directory path output.

6. Provide parity handoff instructions (copy before fresh session):
- `execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`
- `execute-scientific-implementation-plan <absolute-implementation-plan-dir>`

7. Recommend running execution in a fresh session/context.

## Hard Stops

1. Do not create implementation phases from non-approved design plans.
2. Do not emit handoff as ready when AC-to-task-to-test traceability is incomplete.
3. Do not skip validation evidence in handoff status.
