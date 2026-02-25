---
name: simulation-for-inference-validation
description: Use when defining a simulate function for inference-focused scientific software - designs a generative simulation API aligned to inferential assumptions and specifies simulation-based validation checks.
---

# Simulation For Inference Validation

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Design a simulation pathway that mirrors inferential assumptions so users can test inference behavior under controlled data generation.

## Path Contract (Unambiguous)

1. This skill has no installation-local playbook file dependencies.
2. API contracts in this skill define model/data interfaces, not filesystem path contracts.

## Input Contract

Required inputs:
1. Selected model specification (from `provided-model` or `suggested-model` path).
2. Parameterization used by inference routines.
3. Observed data schema and expected output schema.

Optional inputs:
1. Simulation scale/performance constraints.
2. Required reproducibility constraints (seed policy, deterministic replay).
3. Preferred validation protocols (parameter recovery, SBC, posterior predictive checks).

## Output Contract

This skill must produce:
1. Simulation API contract:
- function/CLI signature
- required inputs
- generated outputs
- seed/randomness controls
2. Assumption-alignment matrix:
- inferential assumption -> generative simulation rule
- mismatch risk notes
3. Validation experiment plan:
- parameter recovery test design
- simulation-based calibration (SBC) plan (when applicable)
- posterior predictive check plan (when applicable)
4. Explicit status:
- `pass` | `blocked`

## Workflow

1. Confirm model and inference parameterization are explicit and internally consistent.
2. Define a `simulate` contract that generates synthetic data from model parameters.
3. Ensure simulation output includes all fields needed for downstream inference validation.
4. Specify reproducible RNG behavior (seed/PRNG key handling and replay expectations).
5. Map inferential assumptions to simulation-generative assumptions.
6. Design minimum validation experiments for calibration/recovery behavior.
7. If assumptions cannot be mapped clearly, return `blocked` with explicit gaps.

## Hard Stops

1. Do not finalize simulation design without an explicit model specification.
2. Do not leave RNG behavior implicit; seed/reproducibility controls are required.
3. Do not mix mismatched parameterizations between simulation and inference without explicit transformation notes.
4. If required assumptions are unknown, return `blocked` and request clarification.

## Do/Don't

1. Contract design
- Do: define `simulate(params, config, seed) -> synthetic_batch` with typed outputs.
- Don't: define simulation as side-effectful random behavior with hidden state.

2. Alignment
- Do: document which simulation choices correspond to inferential assumptions.
- Don't: claim validation value when simulation assumptions diverge from inference assumptions.

3. Validation
- Do: include at least one recovery/calibration experiment before implementation handoff.
- Don't: defer all simulation-validation planning to a later undefined phase.
