---
description: Transition design plan status through Draft, In Review, and Approved for Implementation
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
model: sonnet
argument-hint: "<plan-path> <draft|in-review|approved-for-implementation>"
---

# Set Design Plan Status

Update plan status with transition checks.

## Workflow

1. Require plan path in `$1`.
2. Require status token in `$2`:
- `draft`
- `in-review`
- `approved-for-implementation`
3. Run:
`!bash scripts/set-design-plan-status.sh "$1" "$2"`
4. Report old and new status.

## Hard Stop

When target status is `approved-for-implementation`, the command must fail unless
the plan passes readiness validation via:
`scripts/validate-design-plan-readiness.sh <plan-path> --phase approval`.
