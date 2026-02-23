# Phase __PHASE_NUMBER__: __PHASE_TITLE__

**Goal:** __PHASE_GOAL__

## Scope Boundaries
- In scope:
  - __IN_SCOPE_ITEM__
- Out of scope:
  - __OUT_OF_SCOPE_ITEM__

## Dependencies
- Prior phases:
  - __DEPENDENCY__

## Tasks

<!-- START_TASK_1 -->
### Task 1: __TASK_TITLE__
- Inputs:
  - __INPUT__
- Deliverables:
  - __DELIVERABLE__
- Files expected to change:
  - `__FILE_PATH__`
- TDD requirement:
  - failing test:
  - minimal implementation:
  - passing test:
- Verification commands:
  - `__COMMAND__`
<!-- END_TASK_1 -->

<!-- START_TASK_2 -->
### Task 2: __TASK_TITLE__
- Inputs:
  - __INPUT__
- Deliverables:
  - __DELIVERABLE__
- Files expected to change:
  - `__FILE_PATH__`
- TDD requirement:
  - failing test:
  - minimal implementation:
  - passing test:
- Verification commands:
  - `__COMMAND__`
<!-- END_TASK_2 -->

## Phase Verification
```text
# command -> expected result
```

## Review Gate
1. Run `scientific-architecture-reviewer` with this phase scope.
2. If numerics code is touched, run `numerics-interface-auditor`.
3. Resolve blocking findings before phase status is `completed`.

## Completion Checklist
- [ ] All task-level failing tests observed before implementation.
- [ ] All phase verification commands pass.
- [ ] Review findings resolved or explicitly accepted as non-blocking risk.
- [ ] AC and test traceability updated in implementation plan README.
