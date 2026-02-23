---
description: Start architecture planning with clarifying questions, model/simulation contract design, internet research gating, and approval checks before implementation
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, WebSearch, WebFetch
model: sonnet
argument-hint: "[plan-slug]"
---

# Start Scientific Architecture

Run the scientific architecture kickoff workflow end-to-end.

## Inputs

- Optional slug: `$1`

## Workflow

1. Use the `scientific-architecture-planner` agent to lead planning.
2. If `$1` is provided and a plan file does not already exist, use `new-design-plan`.
3. Gather and confirm:
- Core inputs and source formats.
- CLI shape and workflows.
- Core inference goals and outputs.
- Performance, memory, and reproducibility constraints.
- Model artifacts (`.tex`, papers, equation images) if available.
4. Require an early model-path decision:
- `provided-model`: user supplies model equations/update rules from files/input.
- `suggested-model`: planner proposes literature-backed model candidates.
5. Decide simulation scope:
- if inference validation should use synthetic-data generation, require `simulate` contract via `simulation-for-inference-validation`.
6. If `provided-model` and model equations or explicit update rules are provided:
- Run mathematical sanity checks.
- Ask solver strategy preference:
  `custom updates` vs `Optimistix/Lineax translation` vs `compare both`.
- Record translation feasibility.
7. If `suggested-model`:
- Generate candidate models with assumptions/tradeoffs.
- Cite supporting scientific literature for each candidate.
- Require explicit user model selection before proceeding.
8. If external facts are uncertain (API behavior, library versions, format specs, standards, or model-evidence claims):
- Run `scientific-internet-research-pass`.
- Delegate `internet-researcher` for general/API web evidence.
- Delegate `scientific-literature-researcher` for paper-backed support.
- Record cited claims (source URL + access date + confidence) in the design plan.
9. Produce or update the design plan with status `In Review`.
10. Run in-review validation with `validate-design-plan` and capture any remaining placeholders/gaps.
11. Request explicit approval and stop.

## Hard Stop

Do not start implementation tasks or implementation skills until:
1. the user explicitly approves the plan, and
2. model-path choice is explicit (`provided-model` or `suggested-model`), and
3. suggested-model recommendations (if used) are cited and user-selected, and
4. provided-model path (if used) includes concrete model sources/update rules, and
5. simulation contract is explicit when simulation-based validation is in scope.
