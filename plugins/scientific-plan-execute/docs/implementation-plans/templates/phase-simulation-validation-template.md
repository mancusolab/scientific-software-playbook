# Phase __PHASE_NUMBER__: Simulation Validation (__PHASE_TITLE__)

**Goal:** Implement and verify simulation pathways that align with inferential assumptions.

## Scope Boundaries
- In scope:
  - `simulate` API/CLI implementation for synthetic data generation
  - deterministic RNG/seed behavior
  - simulation-based validation experiments (recovery, SBC/PPC as applicable)
- Out of scope:
  - unrelated model redesign
  - non-validation feature work outside simulation/inference checks

## Dependencies
- Prior phases:
  - model and inference contracts are implemented or explicitly stubbed

## Simulation Contract Reference
- Design plan section:
  - `Simulation And Inference-Consistency Validation`
- Expected simulate entrypoint/signature:
  - `__SIMULATE_SIGNATURE__`

## Review Profile
- Profile: `inference` | `full`
- Why this profile:

## Tasks

<!-- START_TASK_1 -->
### Task 1: Implement `simulate` Interface
- Inputs:
  - parameter/config inputs from design simulation contract
  - seed/PRNG input
- Deliverables:
  - callable `simulate` entrypoint
  - typed synthetic output schema
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
### Task 2: Enforce Reproducibility And Assumption Alignment
- Inputs:
  - assumption-alignment mapping from design plan
- Deliverables:
  - deterministic replay tests (fixed seed -> reproducible output)
  - explicit checks/documentation for inference-to-simulation assumption mapping
- Files expected to change:
  - `__FILE_PATH__`
- TDD requirement:
  - failing test:
  - minimal implementation:
  - passing test:
- Verification commands:
  - `__COMMAND__`
<!-- END_TASK_2 -->

<!-- START_TASK_3 -->
### Task 3: Parameter Recovery Validation
- Inputs:
  - recovery experiment definitions (ground-truth parameter draws, inference procedure)
- Deliverables:
  - automated recovery validation test(s)
  - clear pass/fail thresholds
- Files expected to change:
  - `__FILE_PATH__`
- TDD requirement:
  - failing test:
  - minimal implementation:
  - passing test:
- Verification commands:
  - `__COMMAND__`
<!-- END_TASK_3 -->

<!-- START_TASK_4 -->
### Task 4: SBC/PPC Validation (As Applicable)
- Inputs:
  - SBC or PPC experiment definition from design plan
- Deliverables:
  - simulation-calibration test(s) for SBC and/or posterior predictive checks
  - documented experiment outputs/artifacts
- Files expected to change:
  - `__FILE_PATH__`
- TDD requirement:
  - failing test:
  - minimal implementation:
  - passing test:
- Verification commands:
  - `__COMMAND__`
<!-- END_TASK_4 -->

## Phase Verification
```text
# command -> expected result
```

## Review Gate
1. Run `scientific-code-reviewer` with simulation-validation scope.
2. Apply profile baseline:
   - `inference`: add `numerics-interface-auditor` and `scientific-inference-algorithm-reviewer`
   - `full`: add `scientific-architecture-reviewer`, `numerics-interface-auditor`, and `scientific-inference-algorithm-reviewer`
3. Escalate reviewers when touched surfaces require them:
   - boundary-contract change -> `scientific-architecture-reviewer`
   - CLI/API change -> `scientific-cli-api-reviewer`
4. Run `scientific-test-analyst` checks for simulation traceability coverage.
5. Resolve blocking findings before phase status is `completed`.

## Completion Checklist
- [ ] `simulate` contract is implemented and deterministic seed behavior is verified.
- [ ] Recovery and calibration experiments are mapped to tests and passing.
- [ ] Phase verification commands pass.
- [ ] Review findings resolved or explicitly accepted as non-blocking risk.
- [ ] Simulation traceability updated in implementation plan `README.md` and `test-requirements.md`.
