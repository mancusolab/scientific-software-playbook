---
name: scientific-software-architecture
description: Compatibility wrapper that runs the canonical scientific design lifecycle with kickoff gating.
user-invocable: false
---

# Scientific Software Architecture

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

This wrapper preserves compatibility for callers that still invoke `scientific-software-architecture`.

Canonical lifecycle is now:
1. `starting-a-design-plan` (canonical lifecycle semantics)
2. `scientific-kickoff` as an early gate inside that lifecycle
3. `starting-an-implementation-plan`
4. `executing-an-implementation-plan`

## Required Behavior

1. Use `starting-a-design-plan` as the source of truth for design workflow behavior.
2. Do not bypass kickoff mode selection (`provided-model`, `suggested-model`, `existing-codebase-port`).
3. Preserve scientific hard stops through readiness state recording and approval gating.
4. Hand off implementation only after explicit design approval.
