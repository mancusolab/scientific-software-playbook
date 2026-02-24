---
description: Create a phase-based implementation plan from an approved scientific architecture plan with test-first traceability and execution gates
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, WebSearch, WebFetch
model: sonnet
argument-hint: "<design-plan-path> [implementation-slug]"
---

# Start Scientific Implementation Plan

Create a detailed implementation plan from an approved scientific design plan.

## Inputs

1. Required design plan path: `$1`
2. Optional implementation slug override: `$2`

## Workflow

1. Require design plan path in `$1`.
2. If `$2` is provided, use it as the implementation slug override.
3. Use the `start-scientific-implementation-plan` skill.
4. When implementation tasks depend on uncertain external facts, run `scientific-internet-research-pass` and capture citations.
   - Delegate `internet-researcher` for general/API web evidence.
   - Delegate `scientific-literature-researcher` for paper-backed support.
5. Report:
- implementation plan directory path
- phase files created or updated
- test requirements artifact path
- external research citations captured (when triggered)
- simulation validation traceability coverage (when simulation is in scope)
- dedicated simulation-validation phase path (when simulation is in scope)
- explicit handoff status (`blocked` or `ready-to-execute`)
6. Resolve and verify absolute implementation plan directory path.
7. If ready, provide next step using the absolute path:
- Claude Code path: `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`
- Codex path: invoke `execute-scientific-implementation-plan` with the same absolute path.
8. Recommend running the execution step in a fresh session/context for cleaner phase execution.

## Hard Stop

Fail when any are true:
1. The design plan is missing or not `Approved for Implementation`.
2. Design plan readiness validation (approval phase) fails.
3. Acceptance criteria cannot be traced to concrete implementation tasks and tests.
4. Simulation validation scope exists but simulation ACs are not mapped to tasks/tests.
5. Simulation validation scope exists but no dedicated simulation-validation phase was created.
