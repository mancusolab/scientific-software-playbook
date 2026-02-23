# __TITLE__ Design

## Status
Draft

## Handoff Decision
- Current decision: blocked
- Ready for implementation: no
- Blocking items:
  - Pending plan review and explicit approval.

## Metadata
- Date: __DATE__
- Slug: __SLUG__
- Artifact Directory: `__ARTIFACT_DIR__`

## Problem Statement
Describe the scientific problem and why this software artifact is needed.

## Definition of Done
List concrete outcomes that must be true for completion.

## Goals and Non-Goals
### Goals
- Goal 1
- Goal 2

### Non-Goals
- Non-goal 1
- Non-goal 2

## Model Acquisition Path
- Path: `provided-model` | `suggested-model`
- Why this path:
- User selection confirmation:

## Model Specification Sources
| Source ID | Path/Link | Type | Notes | Confidence (high/med/low) |
| --- | --- | --- | --- | --- |
| SRC-1 | | | | |

## Model Option Analysis (Required When `suggested-model`)
| Candidate ID | Model Family | When It Fits | Key Assumptions | Failure Modes | Supporting Citation(s) | Selection Status |
| --- | --- | --- | --- | --- | --- | --- |
| MOD-1 | | | | | | selected/rejected |

## External Research Findings (When Triggered)
| Claim ID | Claim | Source URL | Source Type | Access Date | Confidence (high/med/low) |
| --- | --- | --- | --- | --- | --- |
| EXT-1 | | | official-doc/paper/standard/reference-implementation/secondary | | |

## Mathematical Sanity Checks
- Summary:
- Blocking issues:
- Accepted risks:

Detailed artifacts:
- `__ARTIFACT_DIR__/model-symbol-table.md`
- `__ARTIFACT_DIR__/equation-to-code-map.md`

## Solver Strategy Decision
- User preference:
- Chosen strategy:
- Why this strategy:

## Solver Translation Feasibility
- Summary:
- Blocking constraints:
- Custom-solver rationale (if chosen):

Detailed artifact:
- `__ARTIFACT_DIR__/solver-feasibility-matrix.md`

## Layer Contracts
### Ingress
- Contract:
- Rejection rules:

### Pipeline
- Contract:
- Validation-first checks:

### Numerics
- Contract:
- Result/status semantics:

### Egress
- Contract:
- Output/exit-code mapping:

## Data Conversion and Copy Strategy
For each source format, record copy mode (`zero-copy`, `mmap`, `single-copy fallback`) and rationale.

## Validation Strategy
- Boundary checks:
- Shape/range/domain checks:
- Failure semantics:

## Testing and Verification Strategy
- TDD scope:
- Regression strategy:
- Verification commands:

## Simulation And Inference-Consistency Validation
- In scope: yes|no
- Simulate entrypoint/signature:
- Inputs:
- Outputs:
- Seed/RNG policy:

### Assumption Alignment
| Inference Assumption | Simulation Rule | Mismatch Risk | Mitigation |
| --- | --- | --- | --- |
| | | | |

### Planned Validation Experiments
| Experiment ID | Type (recovery/SBC/PPC) | Success Criterion | Notes |
| --- | --- | --- | --- |
| SIM-1 | | | |

## Risks and Open Questions
| ID | Risk or Question | Severity | Mitigation or Next Step | Owner |
| --- | --- | --- | --- | --- |
| R1 | | | | |

## Acceptance Criteria
1. AC1
2. AC2
3. AC3

## Status Transition Log
| Date | From | To | Why | By |
| --- | --- | --- | --- | --- |
| __DATE__ | N/A | Draft | Plan created | |
