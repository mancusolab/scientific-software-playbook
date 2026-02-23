---
description: Execute a scientific implementation plan phase-by-phase with TDD, verification evidence, and review checkpoints
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
model: sonnet
argument-hint: "<absolute-implementation-plan-dir>"
---

# Execute Scientific Implementation Plan

Execute a phase-based scientific implementation plan with hard gates.

## Inputs

1. Required implementation plan directory path: `$1` (absolute path recommended)

## Workflow

1. Require implementation plan directory path in `$1`.
2. Resolve and verify path existence before execution.
3. Use the `execute-scientific-implementation-plan` skill.
4. Execute each phase with:
- task-level TDD (`failing test -> implementation -> passing test`)
- phase verification commands
- review checkpoints and fix loops
- explicit issue tracking, retry limits, and escalation on persistent blockers
 - delegate output visibility after each delegate run
5. Report:
- per-phase completion status
- issue registry summary by severity
- verification evidence summary
- unresolved blockers (if any)
- final status (`blocked` or `completed`)

## Hard Stop

Stop execution when any are true:
1. Required implementation plan artifacts are missing.
2. A task changes behavior without a preceding failing test.
3. Verification commands fail and are not resolved.
4. High-severity review findings remain unresolved.
5. Delegate evidence is not surfaced between execution/review/fix cycles.
6. `README.md` does not expose a readable source design plan with explicit model path, solver decision, and simulation scope.
7. Simulation is in scope but simulation-validation mappings/tasks/phases are missing before execution begins.
