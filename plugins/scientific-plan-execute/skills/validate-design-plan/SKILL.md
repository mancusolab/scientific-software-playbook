---
name: validate-design-plan
description: Use when validating scientific design-plan readiness in Codex for in-review or approval phases, including model-path and simulation-contract gating checks, without requiring users to run validation scripts directly.
---

# Validate Design Plan

Runs design-plan readiness checks and reports pass/fail gaps.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/validate-design-plan-readiness.sh`
- Claude plugin install: `<claude-plugin-root>/scripts/validate-design-plan-readiness.sh`
2. Project-local input paths:
- Any design plan path passed to this skill resolves within the active downstream project root unless explicitly absolute.

## Required Input

1. Plan path.
2. Optional phase:
- `in-review`
- `approval` (default)

## Workflow

1. Verify plan path exists.
2. Resolve validator path:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
- `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/validate-design-plan-readiness.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run readiness validator:
- `bash "$SCRIPT_PATH" "<plan-path>" --phase "<phase>"`
4. Report:
- pass/fail
- missing sections/artifacts
- placeholder content status
- model-path/evidence gating failures (for example missing `provided-model`/`suggested-model` decision or suggested-model selection without citations)
- simulation gating failures (for example simulation scope `yes` without explicit simulate contract or validation experiments)

## Output

1. Validation result (`pass` or `fail`).
2. Remaining blockers (if any).
