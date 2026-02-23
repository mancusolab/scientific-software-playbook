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
2. Resolve utility path:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
- `SCRIPT_PATH="scripts/set-design-plan-status.sh"`
- `if [[ ! -f "$SCRIPT_PATH" ]]; then SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/set-design-plan-status.sh"; fi`
- `if [[ ! -f "$SCRIPT_PATH" ]]; then SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/scripts/set-design-plan-status.sh"; fi` (legacy compatibility fallback)
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run transition utility:
- `bash "$SCRIPT_PATH" "<plan-path>" "<status-token>"`
4. If target status is `approved-for-implementation`, require readiness validation pass.
5. Report old and new status values.

## Output

1. Transition result (`success` or `blocked`).
2. Reason for block when transition fails.
