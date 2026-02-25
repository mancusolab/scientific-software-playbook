---
name: starting-a-design-plan
description: Use when beginning a scientific design process with plan-and-execute parity - gathers context, applies project guidance, runs architecture gating, validates readiness, and stops for explicit approval before implementation.
user-invocable: false
---

# Starting a Design Plan (Scientific Parity)

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Overview

Use this skill as a parity wrapper for the classic plan-and-execute loop while preserving scientific-specific gates.

Core sequence:
1. Gather context and clarify unknowns.
2. Load project design guidance when present.
3. Run architecture workflow with explicit model-path decisioning.
4. Validate in-review readiness.
5. Stop for explicit user approval before implementation.

## Inputs

Optional:
1. Plan slug seed (for `new-design-plan`).

## Workflow

1. Create an orchestration tracker with `update_plan`:
- Context gathering
- (conditional) Read design guidance
- Scientific architecture planning
- In-review validation
- Approval handoff

2. Gather missing context from the user before architecture:
- problem statement and success criteria
- input formats and output expectations
- constraints (performance, reproducibility, compliance)
- available model artifacts (equations, papers, images)

3. Resolve project guidance files in this order:
- `.scientific/design-plan-guidance.md`
- `.ed3d/design-plan-guidance.md` (legacy fallback)
If found, read and apply the guidance to clarification and architecture decisions.

4. If a slug is provided and plan artifacts do not yet exist, invoke `new-design-plan` first.

5. Invoke `scientific-software-architecture` and follow it exactly:
- enforce early model-path decision (`provided-model` or `suggested-model`)
- trigger simulation-contract design when simulation is in scope
- trigger `scientific-internet-research-pass` when external facts are uncertain
- produce/update design plan with explicit status and handoff decision

6. Invoke `validate-design-plan` in review mode (`in-review`) and capture unresolved blockers.

7. Approval handoff:
- request explicit user approval
- if approved, run `set-design-plan-status` to `approved-for-implementation`
- if not approved, keep status as `In Review` and list required revisions

8. Provide the next-step command bundle:
- parity command: `start-implementation-plan <design-plan-path>`
- scientific command: `start-scientific-implementation-plan <design-plan-path>`

## Hard Stops

1. Do not start implementation planning until explicit user approval is recorded.
2. Do not proceed when model-path decision is implicit.
3. Do not mark design ready when in-review validation has unresolved hard-stop failures.
4. Do not treat uncited external claims as resolved facts.

## Notes

This wrapper is intentionally orchestration-first. Scientific depth remains in these skills:
1. `scientific-software-architecture`
2. `new-design-plan`
3. `validate-design-plan`
4. `set-design-plan-status`
