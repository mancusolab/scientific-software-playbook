---
name: scientific-software-architecture
description: Use when designing scientific software systems with CLI ingress and JAX numerics - asks clarifying questions, enforces an early model-path decision (user-provided model vs literature-backed suggestions), runs external research passes when facts are uncertain, and produces a reviewable design plan before implementation.
---

# Scientific Software Architecture

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Use this skill to design or review scientific software that separates ingress, orchestration, and numerics execution.

## Path Contract (Unambiguous)

1. Project-local paths:
- `docs/...` paths in this skill are relative to the active downstream project root.
2. Installation-local plugin asset path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/...`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/...`
3. Skill references:
- Names like `new-design-plan` or `simulation-for-inference-validation` refer to skill IDs, not relative file paths.

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
4. User preference when no model is provided:
- receive literature-backed model suggestions, or
- postpone until user provides a model.
5. Simulation-validation intent:
- whether `simulate` should be part of the public tool surface.

## Output Contract

This skill must produce:
1. A design plan at `<project-root>/docs/design-plans/YYYY-MM-DD-<slug>.md` (or equivalent structured conversation output).
2. Companion artifacts when model/update rules are in scope:
- `model-symbol-table.md`
- `equation-to-code-map.md`
- `solver-feasibility-matrix.md`
3. Explicit status value: `Draft`, `In Review`, or `Approved for Implementation`.
4. Explicit handoff decision: `blocked` or `ready-for-implementation`.
5. Cited external research findings when research triggers are present.
6. Explicit model-path decision:
- `provided-model` or `suggested-model`
- selected model family and rationale
7. Simulation contract (when simulation is in scope):
- `simulate` input/output contract
- RNG controls
- inference-assumption alignment notes
- validation experiment plan

## Mandatory Architecture Workflow

1. Clarify intent before architecture decisions.
2. Ask whether model-specification artifacts exist (LaTeX files, papers, equation screenshots, diagram images).
3. Require an explicit model-path decision early:
- `provided-model` (user supplies model/update rules)
- `suggested-model` (planner proposes model options with literature support)
4. Detect uncertainty and contradictions explicitly.
5. Ask targeted clarifying questions until goals and success criteria are concrete.
6. For `provided-model`, run mathematical sanity checks on provided model/inference artifacts.
7. For `suggested-model`, generate candidate statistical model options supported by scientific literature and document tradeoffs before selection.
8. Run a formal internet research pass when external facts are uncertain, including model-suggestion evidence.
9. Ask whether simulation-based inference validation is in scope and, when yes, design `simulate` using `simulation-for-inference-validation`.
10. Ask for solver-strategy preference when explicit update rules are provided.
11. Evaluate whether update rules can map to existing solver frameworks (for example Optimistix/Lineax) or require custom solver updates.
12. Produce a draft design plan artifact for user review.
13. Gate implementation work on explicit user approval of the plan.

## Operational Assets

Use these assets to keep planning and reviews consistent:

1. Prefer skills as the primary interface:
- `new-design-plan`
- `validate-design-plan`
- `set-design-plan-status`
- `start-scientific-implementation-plan`
- `execute-scientific-implementation-plan`
2. Commands are optional wrappers from the installed plugin bundle:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/commands/`
- `${CLAUDE_PLUGIN_ROOT}/commands/`
3. Resolve templates with this precedence:
- project-local templates under `<project-root>/docs/...` when present
- otherwise installed plugin templates:
  - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/design-plans/templates/`
  - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/implementation-plans/templates/`
  - `${CLAUDE_PLUGIN_ROOT}/docs/design-plans/templates/`
  - `${CLAUDE_PLUGIN_ROOT}/docs/implementation-plans/templates/`
4. Review/checklist references (installed plugin bundle):
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/reviews/review-template.md`
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/checklists/skill-agent-io-checklist.md`
- `${CLAUDE_PLUGIN_ROOT}/docs/reviews/review-template.md`
- `${CLAUDE_PLUGIN_ROOT}/docs/checklists/skill-agent-io-checklist.md`
5. External research and simulation design:
- `scientific-internet-research-pass`
- `simulation-for-inference-validation`

## Integrated Guidance

Use these core playbook skills directly for downstream design constraints (no companion pairing required):

1. `validation-first-pipeline-api`
2. `jax-equinox-numerics` (from `scientific-house-style`, when installed)
3. `scientific-cli-thin-shell`
4. `scientific-internet-research-pass`
5. `simulation-for-inference-validation`

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
11. External API/library/file-format facts are uncertain or likely to change.
12. User has no model specified and asks for model recommendations.
13. Simulation API scope is ambiguous (needed for validation vs not in scope).

## External Research Pass (When Triggered)

Run `scientific-internet-research-pass` when research triggers are present.
Delegate as needed:
1. `internet-researcher` for general/API web evidence.
2. `scientific-literature-researcher` for paper-backed support.

Required research outputs:
1. Cited claim table (claim -> source URL -> access date -> confidence).
2. Decision impact summary (what changed in the architecture because of findings).
3. Explicit unresolved questions and risk level.
4. For suggested-model path, candidate model evidence table with literature citations.

Research guidance:
1. Prefer primary sources (official docs/specs/papers).
2. Mark secondary-source claims with reduced confidence.
3. If critical claims cannot be cited, keep status as `In Review`.
4. Do not propose suggested models without at least one supporting scientific citation per candidate.

## Clarifying Question Protocol

1. Ask one focused question at a time when uncertainty is material.
2. Use concrete options when choices are discrete.
3. Prefer "what must be true for done?" over "what do you want?" phrasing.
4. Confirm Definition of Done and non-goals before drafting architecture.
5. Ask explicitly whether the user can provide model artifacts (LaTeX, images, existing derivations).
6. Ask the user to choose model path when artifacts are missing or partial:
- provide model/update rules now, or
- receive literature-backed model suggestions.
7. If image equations are ambiguous, request typed/LaTeX confirmation before finalizing assumptions.
8. If explicit update rules exist, ask whether the user prefers:
- custom solver updates,
- translation to existing solvers (Optimistix/Lineax), or
- evaluation of both options before deciding.
9. Ask whether `simulate` should be included for assumption-aligned inference validation.
10. If uncertainty remains unresolved, state assumptions explicitly in the draft plan.

## Required Design Plan Artifact

Before any implementation-oriented skill is used, produce a plan in:

- `<project-root>/docs/design-plans/YYYY-MM-DD-<slug>.md` when repository docs are available.
- Conversation output with the same structure if no writable plan location exists.
- Prefer creating files via:
`/new-design-plan <slug>` (Claude Code) or `new-design-plan` (Codex).

Plan structure (minimum):

1. `Status` (`Draft`, `In Review`, `Approved for Implementation`).
2. `Handoff Decision` (`blocked` or `ready-for-implementation` + blockers).
3. `Problem Statement`.
4. `Definition of Done`.
5. `Goals and Non-Goals`.
6. `Model Acquisition Path` (`provided-model` or `suggested-model`) and why.
7. `Model Specification Sources` (LaTeX/image/text inputs and provenance).
8. `Model Option Analysis` (required for `suggested-model`: candidates, assumptions, tradeoffs, literature support).
9. `External Research Findings` (triggered claims, citations, confidence, access dates).
10. `Mathematical Sanity Checks` (results and unresolved issues).
11. `Solver Strategy Decision` (custom updates vs Optimistix/Lineax translation, with rationale).
12. `Solver Translation Feasibility` (what can/cannot be mapped to existing solvers).
13. `Layer Contracts` (ingress, pipeline, numerics, egress).
14. `Data Conversion and Copy Strategy`.
15. `Validation Strategy`.
16. `Testing and Verification Strategy` (TDD + completion verification).
17. `Simulation and Inference-Consistency Validation` (when in scope).
18. `Risks and Open Questions`.
19. `Acceptance Criteria`.

Companion artifact files (required when model/update rules are in scope):

1. `<project-root>/docs/design-plans/artifacts/YYYY-MM-DD-<slug>/model-symbol-table.md`
2. `<project-root>/docs/design-plans/artifacts/YYYY-MM-DD-<slug>/equation-to-code-map.md`
3. `<project-root>/docs/design-plans/artifacts/YYYY-MM-DD-<slug>/solver-feasibility-matrix.md`

## Approval Gate (Hard Stop)

1. Do not hand off to downstream implementation skills until user explicitly approves the design plan.
2. Accepted approvals are explicit statements such as "approved" or "looks good, proceed."
3. If feedback is partial, keep status as `In Review`, revise, and re-present.
4. If mathematical inconsistencies remain unresolved, keep status as `In Review` and do not hand off implementation.
5. If explicit update rules exist but solver strategy is undecided, keep status as `In Review`.
6. If research triggers were present and uncited external claims remain, keep status as `In Review`.
7. If model path is not explicit (`provided-model` or `suggested-model`), keep status as `In Review`.
8. If `suggested-model` is used and candidate model citations/user selection are missing, keep status as `In Review`.
9. If `provided-model` is selected but model sources/update rules are still missing, keep status as `In Review`.
10. If simulation is in scope and no simulation contract/validation experiments are documented, keep status as `In Review`.
11. Use `/set-design-plan-status` (Claude Code) or `set-design-plan-status` (Codex) for status transitions when the plan file exists.
12. After approval, start implementation orchestration with `start-scientific-implementation-plan` before phase execution.

## Model Selection Branch (Early Gate)

Require one of the following before architecture finalization:

1. `provided-model` path
- user provides model equations/rules from files, images, papers, or typed input.
- planner runs mathematical sanity checks and records unresolved risks.

2. `suggested-model` path
- planner proposes candidate model families aligned to user goals/data.
- each candidate includes assumptions, expected failure modes, and at least one supporting scientific citation.
- user selects a model (or asks for revision) before solver/implementation planning proceeds.

## Simulation Contract And Inference-Consistency Validation

When simulation-based validation is in scope, define:

1. `simulate` interface contract:
- user-facing entrypoint (CLI/API)
- required parameter/config inputs
- output schema for synthetic data
- seed/RNG controls for reproducibility
2. Assumption-alignment mapping:
- each inferential assumption matched to simulation-generative behavior
- explicit mismatch risks
3. Validation experiments:
- parameter recovery checks
- simulation-based calibration (SBC) checks when applicable
- posterior predictive checks when applicable

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

## Mathematical Sanity Checks (Required Before Implementation)

1. Symbol consistency: no undefined symbols or conflicting reuse.
2. Support/domain constraints: parameter and data supports match model assumptions.
3. Objective consistency: maximize/minimize direction and signs are coherent.
4. Inference-rule coherence: update equations match stated model and objective.
5. Shape/dimensional consistency: terms combine with valid dimensions and tensor shapes.
6. Identifiability/degeneracy risk: obvious non-identifiability or redundant parameterization is flagged.
7. Numerical implementability: potential instability or non-differentiable constructs are documented.
8. For `suggested-model`, sanity-check the selected candidate and record why alternatives were not selected.

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

10. Model selection path
- Do: force an early decision between user-provided model artifacts and literature-backed model suggestions.
- Don't: proceed with architecture while model source/selection is implicit.

11. Suggested model evidence
- Do: cite at least one scientific source per suggested model candidate.
- Don't: recommend model families from intuition only.

12. Simulation contract
- Do: define `simulate` as the generative inverse of inference assumptions when simulation is in scope.
- Don't: leave simulation behavior implicit or detached from inferential assumptions.

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
10. Was a model path decision (`provided-model` or `suggested-model`) explicitly recorded?
11. For `suggested-model`, were candidate models literature-backed and user selection recorded?
12. Were mathematical sanity checks completed and documented?
13. If sanity checks found issues, were they resolved or marked as blocking risks?
14. If explicit update rules existed, was solver strategy explicitly decided with user input?
15. Was translation feasibility to Optimistix/Lineax evaluated and documented?
16. If simulation is in scope, is the `simulate` contract explicit and aligned to inferential assumptions?
17. If simulation is in scope, are recovery/calibration validation experiments documented?
18. Were required artifact files generated and populated?
19. Was reviewer output produced using the installed plan-execute review template (`docs/reviews/review-template.md` under the plugin install location)?
20. Is `Handoff Decision` explicit and consistent with plan status?
21. Were external research triggers evaluated and, when triggered, cited findings documented with access dates?

## Weighted Review Guidance

Use weighted gate scoring in the installed plan-execute review template (`docs/reviews/review-template.md` under the plugin install location):
1. Hard-stop failures must be zero.
2. Weighted score should be `>= 90/100` before approval recommendation.
