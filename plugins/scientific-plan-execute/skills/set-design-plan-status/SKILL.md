---
name: set-design-plan-status
description: Use when transitioning scientific design-plan status in Codex or Claude Code with readiness gates enforced, without requiring users to run scripts directly.
---

# Set Design Plan Status

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Updates plan status with transition and readiness checks.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/scripts/resolve-plugin-path.sh`
2. Script resolution rule:
- resolve script paths through the shared resolver only.
- resolver locates installed plugin roots for Codex/Claude runtime and returns absolute script paths.
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
2. Resolve utility path by runtime resolver:
- `RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"`
- fail if `"$RESOLVER_PATH"` does not exist.
- `SCRIPT_PATH="$(bash "$RESOLVER_PATH" --plan-execute-script "set-design-plan-status.sh")"`
3. Run transition utility:
- `bash "$SCRIPT_PATH" "<plan-path>" "<status-token>"`
4. If target status is `approved-for-implementation`, require readiness validation pass.
5. Report old and new status values.

## Output

1. Transition result (`success` or `blocked`).
2. Reason for block when transition fails.
