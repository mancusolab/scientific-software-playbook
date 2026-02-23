# __TITLE__ Implementation Plan

## Status
Draft

## Metadata
- Date: __DATE__
- Slug: __SLUG__
- Source design plan: `__DESIGN_PLAN_PATH__`
- Working directory: `__WORKDIR__`

## Handoff Decision
- Current decision: blocked
- Ready to execute: no
- Blocking items:
  - Pending complete AC-to-task-to-test traceability.

## Execution Constraints
- Required workflow: task-level TDD (`failing test -> implementation -> passing test`)
- Boundary invariants:
  - ingress parses external formats
  - pipeline accepts canonical objects only
  - numerics accepts arrays/PyTrees only
  - egress performs output conversion

## External Dependency Research (When Triggered)
| Claim ID | Related Phase/Task | Claim | Source URL | Access Date | Confidence | Impact on Plan |
| --- | --- | --- | --- | --- | --- | --- |
| EXT-1 | | | | | high/med/low | |

## Acceptance Criteria Traceability
| AC ID | Design Plan Criterion | Phase | Task IDs | Test IDs | Status |
| --- | --- | --- | --- | --- | --- |
| __SLUG__.AC1 | | | | | blocked |

## Simulation Validation Traceability (When In Scope)
| Validation ID | Design Simulation Requirement | Phase | Task IDs | Test IDs | Status |
| --- | --- | --- | --- | --- | --- |
| SIMVAL-1 | | | | | blocked |

## Phase Index
| Phase | File | Goal | Done Gate |
| --- | --- | --- | --- |
| 1 | `phase_01.md` | | |

## Simulation Phase Requirement (When In Scope)
- If design plan simulation scope is `yes`, include at least one dedicated simulation-validation phase file:
  - Example: `phase_0X_simulation_validation.md` or a scoped `phase_0X.md` following `phase-simulation-validation-template.md`.
- That phase must cover:
  - `simulate` interface implementation
  - seed/reproducibility checks
  - recovery + SBC/PPC validation tasks (as applicable)

## Global Verification Commands
```text
# command -> expected result
```

## Review Checkpoints
1. Run `scientific-architecture-reviewer` after each phase.
2. Run `numerics-interface-auditor` for numerics-touching phases.
3. Resolve all blocking findings before continuing.

## Execution Log
| Date | Phase | Status | Evidence |
| --- | --- | --- | --- |
| __DATE__ | initialization | blocked | implementation plan created |
