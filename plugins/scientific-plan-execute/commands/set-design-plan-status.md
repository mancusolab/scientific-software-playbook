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
3. Use the `set-design-plan-status` skill with the plan path and target status token.
4. Report old and new status.

## Hard Stop

When target status is `approved-for-implementation`, the command must fail unless
the plan passes readiness validation via the `validate-design-plan` skill (phase `approval`).
