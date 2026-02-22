---
name: scientific-software-architecture
description: Use when designing scientific software systems with CLI ingress and JAX numerics - asks clarifying questions, ingests model specs from LaTeX/images, and produces a reviewable design plan before implementation.
---

# Scientific Software Architecture

Use this skill to design or review scientific software that separates ingress, orchestration, and numerics execution.

## Input Contract

Required inputs (ask if missing):
1. Problem statement and target workflow (`fit`, `infer`, `simulate`, or other).
2. Intended input formats (tabular and/or domain-specific scientific formats).
3. Desired CLI surface and output expectations.
4. Inference/model goals and constraints.

Optional but strongly requested inputs:
1. Model artifacts (`.tex`, PDFs, equation images).
2. Existing update rules and inferential procedures.
3. Performance/reproducibility constraints.

## Output Contract

This skill must produce:
1. A design plan at `docs/design-plans/YYYY-MM-DD-<slug>.md` (or equivalent structured conversation output).
2. Companion artifacts when model/update rules are in scope:
- `model-symbol-table.md`
- `equation-to-code-map.md`
- `solver-feasibility-matrix.md`
3. Explicit status value: `Draft`, `In Review`, or `Approved for Implementation`.
4. Explicit handoff decision: `blocked` or `ready-for-implementation`.

## Mandatory Architecture Workflow

1. Clarify intent before architecture decisions.
2. Ask whether model-specification artifacts exist (LaTeX files, papers, equation screenshots, diagram images).
3. Detect uncertainty and contradictions explicitly.
4. Ask targeted clarifying questions until goals and success criteria are concrete.
5. Run mathematical sanity checks on provided model/inference artifacts.
6. Ask for solver-strategy preference when explicit update rules are provided.
7. Evaluate whether update rules can map to existing solver frameworks (for example Optimistix/Lineax) or require custom solver updates.
8. Produce a draft design plan artifact for user review.
9. Gate implementation work on explicit user approval of the plan.

## Operational Assets

Use these repo assets to keep planning and reviews consistent:

1. Kickoff command: `commands/start-scientific-architecture.md`
2. Plan generator: `scripts/new-design-plan.sh`
3. Status transition tool: `scripts/set-design-plan-status.sh`
4. Plan template: `docs/design-plans/templates/scientific-architecture-plan-template.md`
5. Model artifacts templates:
- `docs/design-plans/templates/artifacts/model-symbol-table-template.md`
- `docs/design-plans/templates/artifacts/equation-to-code-map-template.md`
- `docs/design-plans/templates/artifacts/solver-feasibility-matrix-template.md`
6. Review template: `docs/reviews/review-template.md`

## Integrated Guidance

Use these core playbook skills directly for downstream design constraints (no companion pairing required):

1. `skills/ingress-to-canonical-jax/SKILL.md`
2. `skills/validation-first-pipeline-api/SKILL.md`
3. `skills/jax-equinox-core-numerics-shell/SKILL.md`
4. `skills/scientific-cli-thin-shell/SKILL.md`

## Uncertainty Triggers (Must Ask Questions)

Ask clarifying questions before proposing architecture when any are true:

1. Primary workflow is unclear (for example `fit` vs `infer` vs `simulate` priorities).
2. Success criteria are missing or qualitative only.
3. Input format scope is ambiguous (tabular only vs domain-specific scientific formats too).
4. Performance, memory, or reproducibility constraints are unstated.
5. Requirements conflict (for example "minimal validation" and "strict validation-first").
6. Ownership boundaries are unclear (what belongs in ingress vs pipeline vs numerics).
7. Model equations/notation are ambiguous, incomplete, or inconsistent.
8. Inference rule specification is unclear (objective, optimization direction, prior/likelihood role, decision rule).
9. Solver strategy preference is unknown (custom updates vs existing solver translation).
10. Update rules are present but mapping feasibility to existing solvers is unclear.

## Clarifying Question Protocol

1. Ask one focused question at a time when uncertainty is material.
2. Use concrete options when choices are discrete.
3. Prefer "what must be true for done?" over "what do you want?" phrasing.
4. Confirm Definition of Done and non-goals before drafting architecture.
5. Ask explicitly whether the user can provide model artifacts (LaTeX, images, existing derivations).
6. If image equations are ambiguous, request typed/LaTeX confirmation before finalizing assumptions.
7. If explicit update rules exist, ask whether the user prefers:
- custom solver updates,
- translation to existing solvers (Optimistix/Lineax), or
- evaluation of both options before deciding.
8. If uncertainty remains unresolved, state assumptions explicitly in the draft plan.

## Required Design Plan Artifact

Before any implementation-oriented skill is used, produce a plan in:

- `docs/design-plans/YYYY-MM-DD-<slug>.md` when repository docs are available.
- Conversation output with the same structure if no writable plan location exists.
- Prefer generating files with:
`scripts/new-design-plan.sh <slug>`

Plan structure (minimum):

1. `Status` (`Draft`, `In Review`, `Approved for Implementation`).
2. `Handoff Decision` (`blocked` or `ready-for-implementation` + blockers).
3. `Problem Statement`.
4. `Definition of Done`.
5. `Goals and Non-Goals`.
6. `Model Specification Sources` (LaTeX/image/text inputs and provenance).
7. `Mathematical Sanity Checks` (results and unresolved issues).
8. `Solver Strategy Decision` (custom updates vs Optimistix/Lineax translation, with rationale).
9. `Solver Translation Feasibility` (what can/cannot be mapped to existing solvers).
10. `Layer Contracts` (ingress, pipeline, numerics, egress).
11. `Data Conversion and Copy Strategy`.
12. `Validation Strategy`.
13. `Testing and Verification Strategy` (TDD + completion verification).
14. `Risks and Open Questions`.
15. `Acceptance Criteria`.

Companion artifact files (required when model/update rules are in scope):

1. `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/model-symbol-table.md`
2. `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/equation-to-code-map.md`
3. `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/solver-feasibility-matrix.md`

## Approval Gate (Hard Stop)

1. Do not hand off to downstream implementation skills until user explicitly approves the design plan.
2. Accepted approvals are explicit statements such as "approved" or "looks good, proceed."
3. If feedback is partial, keep status as `In Review`, revise, and re-present.
4. If mathematical inconsistencies remain unresolved, keep status as `In Review` and do not hand off implementation.
5. If explicit update rules exist but solver strategy is undecided, keep status as `In Review`.
6. Use `scripts/set-design-plan-status.sh` for status transitions when the plan file exists.

## Model Artifact Intake (LaTeX and Images)

1. Always ask if the user has formal model artifacts before locking architecture.
2. Accept model sources from:
- `.tex` and related files.
- PDFs/papers with model equations and assumptions.
- Images/screenshots of equations, probabilistic graphs, or inferential rules.
3. Normalize extracted model information into:
- Symbols and parameter definitions.
- Objective or posterior/likelihood expressions.
- Inference/update rules and stopping criteria.
4. When notation from images is ambiguous, request confirmation or text transcription.
5. Record source path/reference and interpretation confidence in the design plan.

## Mathematical Sanity Checks (Required When Model Artifacts Exist)

1. Symbol consistency: no undefined symbols or conflicting reuse.
2. Support/domain constraints: parameter and data supports match model assumptions.
3. Objective consistency: maximize/minimize direction and signs are coherent.
4. Inference-rule coherence: update equations match stated model and objective.
5. Shape/dimensional consistency: terms combine with valid dimensions and tensor shapes.
6. Identifiability/degeneracy risk: obvious non-identifiability or redundant parameterization is flagged.
7. Numerical implementability: potential instability or non-differentiable constructs are documented.

## Solver Strategy Decision (Required When Explicit Update Rules Exist)

1. Ask whether the user wants:
- Custom solver updates tailored to the model.
- Translation to existing solver APIs (Optimistix/Lineax).
- Comparative evaluation before selecting.
2. If translation is requested or considered, check:
- Can update rules be represented as root finding, least squares, or minimization?
- Are derivatives available/tractable for chosen methods?
- Are constraints/projections compatible with existing solver hooks?
- Can stopping/error semantics map to structured result channels?
3. If custom solver updates are chosen:
- Record why existing solvers are insufficient.
- Define minimum validation/benchmark comparisons against a baseline approach.
4. Record final solver strategy and rationale in the design plan.

## Architecture Contracts

1. Ingress is the only place where external formats are parsed.
2. Ingress converts tabular and domain-specific scientific formats into canonical core objects immediately when feasible.
3. Pipeline entrypoints accept canonical core objects only.
4. Core numerics accepts arrays/PyTrees only.
5. Egress is the only place where user/reporting output formats are reconstructed.

## Layer Model

1. CLI/Ingress Adapter
- Parse files/flags.
- Convert to canonical JAX/PyTree-oriented objects.
- Declare copy behavior (`zero-copy`, `mmap`, or `single-copy fallback`).

2. Core Object Factory
- Build typed domain objects.
- Normalize dtype and shape once at boundary.
- Eliminate parallel host/container representations.

3. Validation-First Pipeline API
- Validate schema/range/shape before dispatch.
- Reject non-canonical input types.
- Route only validated canonical objects to numerics.

4. Core Numerics Shell
- Keep kernels pure and transformation-friendly.
- Use structured result/status channels.
- Keep exceptions at boundaries, not inside traced loops.

5. Egress Adapter
- Convert structured results to CLI/JSON/report outputs.
- Preserve stable stdout/stderr and exit-code contracts.

## Do/Don't Examples

1. Ingress boundary
- Do: parse `CSV`, `Parquet`, `VCF`, or instrument-native files directly into canonical arrays/PyTrees.
- Don't: pass `DataFrame` objects, file handles, or domain parser objects into pipeline code.

2. Pipeline contract
- Do: `fit(request: CanonicalBatch) -> FitResult`.
- Don't: `fit(df: DataFrame)` or `fit(vcf_path: str)` in pipeline entrypoints.

3. Numerics kernel
- Do: run `eqx.filter_jit` on numerics APIs that accept canonical arrays/PyTrees.
- Don't: load files, parse formats, or perform CLI argument validation in numerics functions.

4. Egress and reporting
- Do: translate internal result/status to stable user outputs and exit codes at boundaries.
- Don't: expose solver-internal objects directly as the default user-facing contract.

5. Clarification behavior
- Do: ask clarifying questions when scope, goals, or constraints are ambiguous.
- Don't: infer missing success criteria and jump directly to implementation tasks.

6. Planning gate
- Do: generate a design plan that the user can review and approve first.
- Don't: start coding because the architecture "seems obvious."

7. Model artifact usage
- Do: ask for LaTeX/images when users mention existing statistical model definitions.
- Don't: ignore formal model artifacts and rely only on prose summaries.

8. Mathematical sanity
- Do: record sanity-check findings and unresolved issues in the plan.
- Don't: pass an unverified model specification into implementation as if mathematically settled.

9. Solver strategy
- Do: explicitly query custom-update preference vs existing-solver translation when update rules are provided.
- Don't: assume custom solver implementation without evaluating existing solver fit.

## Implementation Gates (TDD + Verification)

1. No boundary change without a failing test first.
- Do: add a failing test that proves container rejection or conversion behavior before code changes.
- Don't: edit ingress/pipeline/numerics contracts first and backfill tests later.

2. No completion claim without fresh command evidence.
- Do: run the repository verification commands after edits and report actual results.
- Don't: claim "done" based on static inspection or prior runs.

## Required Review Questions

1. Can any non-canonical container cross ingress? If yes, fix boundary.
2. Can pipeline code parse files or domain formats? If yes, move to ingress.
3. Can numerics code parse/validate user input? If yes, move to boundary.
4. Is copy behavior explicit for each format adapter? If no, document and test.
5. Did boundary contract changes follow red-green-refactor and include verification evidence?
6. Were clarifying questions asked for all material uncertainty triggers?
7. Does an explicit design plan artifact exist with status and acceptance criteria?
8. Was implementation blocked until user approval was explicit?
9. Were model artifacts (LaTeX/images) requested and captured when available?
10. Were mathematical sanity checks completed and documented?
11. If sanity checks found issues, were they resolved or marked as blocking risks?
12. If explicit update rules existed, was solver strategy explicitly decided with user input?
13. Was translation feasibility to Optimistix/Lineax evaluated and documented?
14. Were required artifact files generated and populated?
15. Was reviewer output produced using `docs/reviews/review-template.md`?
16. Is `Handoff Decision` explicit and consistent with plan status?

## Weighted Review Guidance

Use weighted gate scoring in `docs/reviews/review-template.md`:
1. Hard-stop failures must be zero.
2. Weighted score should be `>= 90/100` before approval recommendation.
