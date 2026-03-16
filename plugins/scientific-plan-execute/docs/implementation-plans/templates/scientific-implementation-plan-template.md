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
- Architecture profile: `compact-workflow` | `modular-domain`
- Profile selection rule:
  - default to `compact-workflow` for small-scope projects or single-workflow CLIs
  - choose `modular-domain` when multiple scientific domains/workflows evolve independently
- Boundary invariants by profile:
  - `compact-workflow`:
    - one module may handle CLI parsing, boundary validation, file I/O, numerics dispatch, and output writing
    - validation and raw-container conversion must still happen before numerics dispatch
    - numerics entrypoints remain array/PyTree-only
  - `modular-domain`:
    - organize modules by scientific concern (for example: distribution, infer, io), with shallow package depth
    - keep parsing/format conversion and CLI argument concerns out of numerics kernels
    - keep numerics entrypoints array/PyTree-only

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
| Phase | File | Goal | Review Profile | Done Gate |
| --- | --- | --- | --- | --- |
| 1 | `phase_01.md` | | `minimal` | |

## Simulation-Validation Phase Requirement (When In Scope)
- If synthetic-data validation scope is `yes` in the design plan, include at least one dedicated simulation-validation phase file:
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
1. Run `scientific-code-reviewer` after each phase.
2. Select phase-level baseline reviewers from the phase review profile:
- `minimal`, `api-cli`, `numerics`, `inference`, `full`.
3. Add specialist reviewers from baseline code-review `Specialist Escalations` (`needed: ✅` only).
4. Safety fallback only: if architecture artifacts changed (`.plans/design-plans`, `.plans/implementation-plans`, `AGENTS.md`, `CLAUDE.md`), add `scientific-architecture-reviewer`.
5. Evaluate boundary findings against the selected architecture profile, not an implicit deep-layering assumption.
6. Resolve all blocking findings before continuing.

## Execution Log
| Date | Phase | Status | Evidence |
| --- | --- | --- | --- |
| __DATE__ | initialization | blocked | implementation plan created |
