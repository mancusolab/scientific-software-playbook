---
name: set-design-plan-status
description: Use when transitioning scientific design-plan status in Codex or Claude with readiness gates enforced, without requiring users to run scripts directly.
---

# Set Design Plan Status

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

Updates plan status with transition and readiness checks.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/set-design-plan-status.sh`
- Claude plugin install: `<claude-plugin-root>/scripts/set-design-plan-status.sh`
2. Script resolution rule:
- resolve from the installed plugin location only (Codex bundle or Claude plugin root).
- do not use repository-local `scripts/...` paths.
3. Project-local input/output paths:
- Any plan path passed to this skill resolves within the active downstream project root unless explicitly absolute.

## Required Input

1. Plan path.
2. Status token:
- `draft`
- `in-review`
- `approved-for-implementation`

## Workflow

1. Validate plan path and status token.
2. Resolve utility path by runtime:
- Codex: `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"` then `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/set-design-plan-status.sh"`
- Claude plugin: `SCRIPT_PATH="<claude-plugin-root>/scripts/set-design-plan-status.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run transition utility:
- `bash "$SCRIPT_PATH" "<plan-path>" "<status-token>"`
4. If target status is `approved-for-implementation`, require readiness validation pass.
5. Report old and new status values.

## Output

1. Transition result (`success` or `blocked`).
2. Reason for block when transition fails.
