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

## Summary
<!-- TO BE GENERATED after body is written -->

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

## Existing Patterns
Describe confirmed codebase patterns, constraints, or intentional divergences.

## Model Acquisition Path
- Path: `provided-model` | `suggested-model` | `existing-codebase-port`
- Why this path:
- User selection confirmation:

## Required Workflow States
- model_path_decided: yes|no
- codebase_investigation_complete_if_port: yes|no|n/a
- simulation_contract_complete_if_in_scope: yes|no|n/a

## Model Specification Sources
| Source ID | Path/Link | Type | Notes | Confidence (high/med/low) |
| --- | --- | --- | --- | --- |
| SRC-1 | | | | |

## Model Option Analysis (Required When `suggested-model`)
| Candidate ID | Model Family | When It Fits | Key Assumptions | Failure Modes | Supporting Citation(s) | Selection Status |
| --- | --- | --- | --- | --- | --- | --- |
| MOD-1 | | | | | | selected/rejected |

## Existing Codebase Port Contract (Required When `existing-codebase-port`)
- Porting objective:
- Source selection confirmation:

### Source Pin
| Source ID | Source Type (`local-directory` or `github-url`) | Path/URL | Commit/Tag | Notes |
| --- | --- | --- | --- | --- |
| PORT-SRC-1 | | | | |

### Behavior Inventory And Parity Targets
| Behavior ID | Surface (`cli`/`api`/`numerics`/`io`) | Current Behavior | Target Behavior | Evidence Plan (tests/golden outputs) |
| --- | --- | --- | --- | --- |
| PORT-BHV-1 | | | | |

## Codebase Investigation Findings (Required When `existing-codebase-port`)
- Investigation mode: `local-directory` | `github-url`
- Investigation completion: yes|no
- Investigator: `scientific-codebase-investigation-pass`

| Finding ID | Source Scope | Summary | Evidence (file:line or commit:path:line) | Status (`confirmed`/`discrepancy`/`addition`/`missing`) |
| --- | --- | --- | --- | --- |
| PORT-INV-1 | | | | confirmed |

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

## Multi-Input Reconciliation Contract (Required When Multiple Tabular Sources Feed Numerics)
- Sources:
- Entity key(s) (for example subject/sample ID):
- Join type and rationale:
- Duplicate-key policy:
- Missing-key policy:
- Row-order freeze policy:
- Reconciliation accounting (matched/dropped/retained counts):
- Conversion boundary (where reconciled tabular data becomes arrays/PyTrees):

## Validation Strategy
- Boundary checks:
- Shape/range/domain checks:
- Multi-input alignment checks (key uniqueness, overlap expectations, deterministic row ordering):
- Failure semantics:

## Testing and Verification Strategy
- TDD scope:
- Regression strategy:
- Verification commands:

## Implementation Phases
<!-- TO BE GENERATED with START_PHASE / END_PHASE markers -->

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

## Additional Considerations
<!-- Optional: include only when relevant -->

## Acceptance Criteria
<!-- TO BE GENERATED and validated before glossary -->

## Glossary
<!-- TO BE GENERATED after body is written -->

## Status Transition Log
| Date | From | To | Why | By |
| --- | --- | --- | --- | --- |
| __DATE__ | N/A | Draft | Plan created | |
