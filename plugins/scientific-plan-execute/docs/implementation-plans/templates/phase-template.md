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

## Review Profile
- Profile: `minimal` | `api-cli` | `numerics` | `inference` | `full`
- Why this profile:

## Architecture Profile
- Profile: `compact-workflow` | `modular-domain`
- Why this profile:

## Multi-Input Reconciliation (When Applicable)
- Entity key(s):
- Join type and rationale:
- Duplicate/missing-key policy:
- Row-order determinism policy:
- Reconciliation verification command(s):

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
1. Always run `scientific-code-reviewer` with this phase scope.
2. Apply reviewers from profile baseline:
   - `minimal`: code review only
   - `api-cli`: add `scientific-cli-api-reviewer`
   - `numerics`: add `numerics-interface-auditor`
   - `inference`: add `numerics-interface-auditor` and `scientific-inference-algorithm-reviewer`
   - `full`: run all specialized reviewers
3. Escalate reviewers when touched surfaces require them, even if profile is lower:
   - boundary-contract change -> `scientific-architecture-reviewer`
   - numerics change -> `numerics-interface-auditor`
   - CLI/API change -> `scientific-cli-api-reviewer`
   - objective/update-rule/deterministic-solver/inference-engine change -> `scientific-inference-algorithm-reviewer`
4. Compute final specialized reviewer list deterministically in fixed order:
   - `scientific-architecture-reviewer`
   - `numerics-interface-auditor`
   - `scientific-cli-api-reviewer`
   - `scientific-inference-algorithm-reviewer`
5. Resolve blocking findings before phase status is `completed`.
6. Evaluate boundary findings against the selected architecture profile (`compact-workflow` or `modular-domain`).

## Completion Checklist
- [ ] All task-level failing tests observed before implementation.
- [ ] All phase verification commands pass.
- [ ] Multi-input reconciliation behavior is explicit and verified (when applicable).
- [ ] Review findings resolved or explicitly accepted as non-blocking risk.
- [ ] AC and test traceability updated in implementation plan README.
