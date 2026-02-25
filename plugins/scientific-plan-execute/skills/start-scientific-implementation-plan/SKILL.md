---
name: start-scientific-implementation-plan
description: Use when moving from an approved scientific design plan to implementation - creates a phase-based implementation plan with acceptance-criteria-to-test traceability and explicit execution gates.
---

# Start Scientific Implementation Plan

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Create implementation-ready phase artifacts from an approved architecture plan.

## Path Contract (Unambiguous)

1. Project-local paths:
- `docs/...` paths in this skill are relative to the active downstream project root.
2. Installation-local template path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/implementation-plans/templates/`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/docs/implementation-plans/templates/`

## Input Contract

Required inputs:
1. Design plan path (`<project-root>/docs/design-plans/YYYY-MM-DD-<slug>.md`).
2. Design plan status equal to `Approved for Implementation`.

Optional inputs:
1. Implementation slug override.
2. Branch/worktree preference.
3. Priority constraints for phase ordering.
4. External dependency/API uncertainty notes.

## Output Contract

This skill must produce:
1. Implementation plan directory:
- `<project-root>/docs/implementation-plans/YYYY-MM-DD-<slug>/`
2. Required files:
- `README.md`
- `test-requirements.md`
- one or more `phase_XX.md` files
3. AC traceability:
- each design acceptance criterion mapped to one or more implementation tasks
- each mapped task has at least one test requirement entry
 - simulation-validation requirements mapped to tasks/tests when simulation is in scope
4. Explicit handoff decision:
- `blocked` or `ready-to-execute`
5. Explicit next step command suggestion:
- `execute-scientific-implementation-plan <implementation-plan-dir>`
6. External research citation notes when research triggers are present.
7. Fresh-context handoff bundle:
- absolute implementation plan path
- copy-paste execution command
- recommendation to run execution in a fresh session/context

## Clarifying Question Triggers

Ask clarifying questions before writing implementation phases when any are true:
1. Acceptance criteria are missing, ambiguous, or not testable.
2. Ownership boundaries are unclear across ingress, pipeline, numerics, and CLI.
3. A requirement implies multiple incompatible implementations.
4. Verification command expectations are undefined.
5. The user has branch/worktree constraints not captured in the design plan.
6. External APIs, formats, or version-sensitive behaviors required by planned tasks are unclear.
7. Design plan marks simulation scope in-scope but `simulate` contract or validation experiments are incomplete.

## Workflow

1. Validate the design plan path exists.
2. Validate design status is `Approved for Implementation`.
3. Run design readiness validation in approval mode before planning:
- `validate-design-plan <plan-path> --phase approval` (Claude Code)
- `validate-design-plan` with phase `approval` (Codex)
4. Resolve slug:
- default from design plan filename after date prefix
- or use user-provided override
5. Create implementation directory:
- `<project-root>/docs/implementation-plans/YYYY-MM-DD-<slug>/`
6. Resolve template source:
- prefer project-local templates when present:
  - `<project-root>/docs/implementation-plans/templates/`
- otherwise use installed plugin templates:
  - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/docs/implementation-plans/templates/`
  - `${CLAUDE_PLUGIN_ROOT}/docs/implementation-plans/templates/`
7. Create/update files using resolved templates:
- `scientific-implementation-plan-template.md`
- `test-requirements-template.md`
- `phase-template.md`
- `phase-simulation-validation-template.md` (when simulation scope is `yes`)
8. Define phased plan:
- keep phases cohesive and independently reviewable
- include phase goals, task list, and done gates
 - when simulation scope is `yes`, include at least one dedicated simulation-validation `phase_XX.md` built from `phase-simulation-validation-template.md`
9. Run research pass when implementation tasks rely on uncertain external facts:
- run `scientific-internet-research-pass`
- delegate `internet-researcher` for general/API web evidence
- delegate `scientific-literature-researcher` for paper-backed support
 - Record citations and decision impacts in implementation-plan `README.md`.
10. Build AC-to-task and AC-to-test traceability:
- populate `README.md` traceability table
- populate `test-requirements.md` for each AC/task mapping
 - include simulation-validation test mappings (recovery/SBC/PPC) when simulation is in scope
11. Add phase-level verification commands and reviewer checkpoints.
12. Set handoff decision:
- `ready-to-execute` only if all AC rows have task IDs and test IDs
- otherwise `blocked` with explicit blockers.
13. Resolve and verify absolute implementation plan directory path.
14. If handoff is `ready-to-execute`, emit a copy-paste execution command using the absolute path and recommend running it in a fresh session/context.

## Required Phase Content

Each `phase_XX.md` file must define:
1. Phase goal and scope boundaries.
2. Task markers (`START_TASK_N`) with concrete deliverables.
3. Task-level TDD requirements:
- failing test first
- minimal implementation
- passing test and regression coverage
4. Verification commands for that phase.
5. Review gate requirements before phase completion.

When simulation scope is `yes`, at least one phase must include:
1. `simulate` interface implementation tasks.
2. Seed/reproducibility verification tasks.
3. Recovery and calibration (SBC/PPC as applicable) test tasks.

## Hard Stops

1. Never generate an execution-ready plan from a non-approved design plan.
2. Never leave acceptance criteria unmapped to tests and still mark ready.
3. Never include implementation tasks that bypass boundary contracts:
- no raw container flow into pipeline/numerics
- no parser logic in numerics
4. Never emit `ready-to-execute` if blockers remain unresolved.
5. Never emit `ready-to-execute` if research-triggered external claims are uncited.
6. Never emit `ready-to-execute` if the absolute implementation plan path cannot be verified.
7. Never emit `ready-to-execute` when simulation is in scope but simulation ACs are unmapped to tasks/tests.
8. Never emit `ready-to-execute` when simulation is in scope but no dedicated simulation-validation phase exists.

## Do/Don't

1. Traceability
- Do: map every AC to tasks and tests.
- Don't: leave prose-only acceptance criteria with no executable checks.

2. Phase scope
- Do: split into small, reviewable phases with explicit completion gates.
- Don't: create one monolithic phase spanning ingress, numerics, and CLI at once.

3. Quality gates
- Do: include concrete verification commands in every phase.
- Don't: rely on "manual validation later" as a gate.

4. Boundary discipline
- Do: keep ingress parsing and conversion at boundaries.
- Don't: allow dataframes/domain containers in numerics task signatures.
