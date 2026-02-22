---
description: Start architecture planning with clarifying questions, model sanity checks, and approval gating before implementation
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
model: sonnet
argument-hint: "[plan-slug]"
---

# Start Scientific Architecture

Run the scientific architecture kickoff workflow end-to-end.

## Inputs

- Optional slug: `$1`

## Workflow

1. Use the `scientific-architecture-planner` agent to lead planning.
2. If `$1` is provided and a plan file does not already exist, run:
`!bash scripts/new-design-plan.sh "$1"`
3. Gather and confirm:
- Core inputs and source formats.
- CLI shape and workflows.
- Core inference goals and outputs.
- Performance, memory, and reproducibility constraints.
- Model artifacts (`.tex`, papers, equation images) if available.
4. If model equations or explicit update rules are provided:
- Run mathematical sanity checks.
- Ask solver strategy preference:
  `custom updates` vs `Optimistix/Lineax translation` vs `compare both`.
- Record translation feasibility.
5. Produce or update the design plan with status `In Review`.
6. Run in-review validation and capture any remaining placeholders/gaps:
`!bash scripts/validate-design-plan-readiness.sh "<plan-path>" --phase in-review`
7. Request explicit approval and stop.

## Hard Stop

Do not start implementation tasks or implementation skills until the user explicitly approves the plan.
