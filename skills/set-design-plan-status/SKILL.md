---
name: set-design-plan-status
description: Use when transitioning scientific design-plan status in Codex with readiness gates enforced, without requiring users to run scripts directly.
---

# Set Design Plan Status

Updates plan status with transition and readiness checks.

## Required Input

1. Plan path.
2. Status token:
- `draft`
- `in-review`
- `approved-for-implementation`

## Workflow

1. Validate plan path and status token.
2. Run transition utility:
- `bash scripts/set-design-plan-status.sh "<plan-path>" "<status-token>"`
3. If target status is `approved-for-implementation`, require readiness validation pass.
4. Report old and new status values.

## Output

1. Transition result (`success` or `blocked`).
2. Reason for block when transition fails.
