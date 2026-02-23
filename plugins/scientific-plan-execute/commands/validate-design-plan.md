---
description: Validate that a design plan meets hard-stop readiness requirements before approval
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
argument-hint: "<plan-path> [--phase in-review|approval]"
---

# Validate Design Plan

Run readiness validation checks for a plan and its companion artifacts.

## Workflow

1. Require plan path in `$1`.
2. Optional phase arguments:
- default: `approval`
- draft review: `--phase in-review`
3. Use the `validate-design-plan` skill with the plan path and phase.
4. Report pass/fail and any listed gaps/placeholders.
