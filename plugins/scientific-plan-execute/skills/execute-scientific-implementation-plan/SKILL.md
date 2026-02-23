---
name: execute-scientific-implementation-plan
description: Use when executing a scientific implementation plan directory - runs phase-by-phase delegate execution with explicit issue tracking, retry-safe review loops, and traceability-driven test analysis.
---

# Execute Scientific Implementation Plan

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

Execute a prepared implementation plan with explicit quality gates, loop controls, and evidence requirements.

## Path Contract (Unambiguous)

1. Project-local execution paths:
- `docs/...` paths in this skill are relative to the active downstream project root.
2. Absolute paths:
- Absolute implementation-plan paths are preferred for handoff/execution to avoid ambiguity.

## Input Contract

Required inputs:
1. Implementation plan directory path:
- `<project-root>/docs/implementation-plans/YYYY-MM-DD-<slug>/`

Required artifacts in that directory:
1. `README.md`
2. `test-requirements.md`
3. `phase_XX.md` files (`phase_01.md` minimum)
4. `README.md` metadata with a resolvable `Source design plan` path.

## Output Contract

This skill must produce:
1. Per-phase execution status:
- `not-started` | `in-progress` | `completed` | `blocked`
2. Per-phase issue registry:
- open/closed findings by severity (`critical`, `high`, `medium`, `low`)
3. Verification evidence summary per phase:
- commands run
- pass/fail outcomes
4. Review evidence:
- reviewer used
- findings and resolution status across cycles
5. Traceability analysis result from `scientific-test-analyst`:
- `PASS` | `FAIL` | `BLOCKED`
6. Final execution decision:
- `completed` or `blocked`
7. Delegate visibility log:
- phase/task identifier
- delegate used
- key delegate evidence surfaced to the user (tests, findings, blockers, commits)

## Delegate Agents

Use these delegates when available:
1. `scientific-task-implementor-fast`
2. `scientific-task-bug-fixer`
3. `scientific-architecture-reviewer`
4. `numerics-interface-auditor`
5. `scientific-test-analyst`

If delegation is unavailable, execute equivalent steps directly with the same gates.

## Human Visibility Rules

1. Before every delegate call, state what the delegate is being asked to do and for which phase/task.
2. After every delegate response, surface the key evidence to the user before moving on:
- tests/verification results
- findings by severity
- blockers or retry reasons
- commit/reference identifiers when produced
3. Do not silently absorb delegate output and continue execution.

## Workflow

1. Validate implementation plan directory and required artifacts exist.
2. Load implementation-plan `README.md` and resolve the `Source design plan` path.
3. Run scope preflight checks before any task execution:
- extract design-level `Model Acquisition Path` (`provided-model` or `suggested-model`)
- extract design-level `Solver Strategy Decision`
- extract design-level simulation scope (`In scope: yes|no`)
- verify implementation `README.md` keeps boundary invariants:
  - pipeline accepts canonical objects only
  - numerics accepts arrays/PyTrees only
- if simulation scope is `yes`, verify all of:
  - `Simulation Validation Traceability` section exists with at least one mapped validation row
  - phase index includes at least one dedicated simulation-validation phase
  - at least one `phase_XX.md` includes `simulate` tasks, seed/reproducibility checks, and recovery or SBC/PPC validation tasks
4. Discover phase files in lexical order (`phase_01.md`, `phase_02.md`, ...).
5. Create an execution tracker with one cycle per phase:
- `Read`
- `Implement`
- `Review/Fix Loop`
6. Execute phases one at a time (no full-plan preload).

### Phase Cycle

For each phase:
1. Read phase goal, task markers (`START_TASK_N`), and verification commands.
2. Initialize an issue registry for this phase.
3. Implement each task (or subcomponent group) in order:
- dispatch `scientific-task-implementor-fast`
- require TDD evidence (`failing -> passing`)
- require verification evidence for task commands
 - surface implementor evidence to the user before next task
4. If implementor reports blockers, mark phase `blocked` and stop.
5. Run phase review checkpoint:
- always run `scientific-architecture-reviewer`
- run `numerics-interface-auditor` when numerics APIs changed
 - surface reviewer findings before entering fix loops
6. Record findings by severity in the issue registry.
7. If blocking findings exist:
- dispatch `scientific-task-bug-fixer`
- re-run applicable reviewers
- update issue registry (closed/open)
 - surface bug-fixer and re-review evidence each cycle
8. Repeat review/fix loop until blocking findings are closed or loop limit is reached.
9. Mark phase:
- `completed` only when required evidence exists and no blocking findings remain
- otherwise `blocked`.

### Review/Fix Loop Control

1. Blocking severities: `critical`, `high`.
2. `medium`/`low` findings must be fixed or explicitly marked as accepted risk.
3. Timeout/empty reviewer response policy:
- retry with narrowed scope (changed files only)
- retry limit: 3 attempts per review call
4. Re-review persistence policy:
- if same blocking finding persists across 3 fix cycles, stop and escalate to user
5. Every fix cycle must include fresh verification evidence.

### Finalization Sequence

After all phases are `completed`:
1. Run full verification commands from implementation plan `README.md`.
2. Dispatch `scientific-test-analyst` for AC-to-task-to-test coverage using:
- `README.md`
- `test-requirements.md`
- all `phase_XX.md`
3. If test analyst returns `FAIL`:
- dispatch `scientific-task-bug-fixer` for missing coverage
- re-run `scientific-test-analyst`
- stop after 3 unresolved cycles and mark `blocked`
4. If test analyst returns `BLOCKED`, mark execution `blocked`.
5. Report final decision with evidence summary.

## Mandatory Evidence Rules

1. No behavior-changing task may pass without failing-test-first evidence.
2. No finding may be marked resolved without command evidence.
3. No phase may be marked complete if required review commands were skipped.
4. No final `completed` status without test-analyst coverage `PASS`.

## Issue Registry Requirements

Track findings with:
1. Finding ID or stable label.
2. Severity.
3. Source reviewer (`architecture`, `numerics`, `test-analyst`).
4. Status (`open`, `closed`, `accepted-risk`).
5. Fix evidence reference (command and outcome).

Update registry each loop iteration so issue state is auditable.

## Hard Stops

1. Stop if required phase artifacts are missing.
2. Stop if a task cannot identify test coverage for behavior changes.
3. Stop if implementor output lacks required TDD or verification evidence.
4. Stop if phase verification commands fail and fixes are not completed.
5. Stop if review returns unresolved blocking findings after loop limits.
6. Stop if test-analyst coverage remains unresolved after loop limits.
7. Stop if execution diverges from approved design/implementation plan contracts without user-approved plan update.
8. Stop if delegate calls continue without surfacing required evidence to the user.
9. Stop if `Source design plan` path is missing or cannot be read.
10. Stop if model acquisition path, solver decision, or simulation scope cannot be unambiguously determined from the design plan.
11. Stop if simulation scope is `yes` but simulation-validation mappings/tasks/phases are missing or placeholder-only in implementation artifacts.
12. Stop if implementation `README.md` boundary invariants allow raw containers to bypass canonical-object or array/PyTree contracts.

## Do/Don't

1. Phase loading
- Do: load one phase at a time to keep context focused.
- Don't: batch all phase content into one execution pass.

2. Test discipline
- Do: enforce red-green per task.
- Don't: implement first and write tests only at the end.

3. Review discipline
- Do: run review/fix loops before moving to next phase.
- Don't: defer known findings to a final cleanup phase.

4. Loop control
- Do: enforce retry and three-strike limits explicitly.
- Don't: run open-ended re-review loops without escalation.

5. Contract fidelity
- Do: stop and request plan update when scope changes materially.
- Don't: silently rewrite architecture decisions during implementation.
