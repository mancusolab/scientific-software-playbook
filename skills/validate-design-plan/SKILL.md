---
name: validate-design-plan
description: Use when validating scientific design-plan readiness in Codex for in-review or approval phases, including model-path and simulation-contract gating checks, without requiring users to run validation scripts directly.
---

# Validate Design Plan

Runs design-plan readiness checks and reports pass/fail gaps.

## Required Input

1. Plan path.
2. Optional phase:
- `in-review`
- `approval` (default)

## Workflow

1. Verify plan path exists.
2. Run readiness validator:
- `bash scripts/validate-design-plan-readiness.sh "<plan-path>" --phase "<phase>"`
3. Report:
- pass/fail
- missing sections/artifacts
- placeholder content status
- model-path/evidence gating failures (for example missing `provided-model`/`suggested-model` decision or suggested-model selection without citations)
- simulation gating failures (for example simulation scope `yes` without explicit simulate contract or validation experiments)

## Output

1. Validation result (`pass` or `fail`).
2. Remaining blockers (if any).
