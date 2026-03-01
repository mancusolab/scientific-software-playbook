---
name: validate-design-plan
description: Use when validating scientific design-plan readiness in Codex or Claude Code for in-review or approval phases, including model-path and synthetic-data-validation-contract gating checks, without requiring users to run validation scripts directly.
---

# Validate Design Plan

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Runs design-plan readiness checks and reports pass/fail gaps.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/scripts/resolve-plugin-path.sh`
2. Script resolution rule:
- resolve script paths through the shared resolver only.
- resolver locates installed plugin roots for Codex/Claude runtime and returns absolute script paths.
- do not use repository-local `scripts/...` paths.
3. Project-local input paths:
- Any design plan path passed to this skill resolves within the active downstream project root unless explicitly absolute.

## Required Input

1. Plan path.
2. Optional phase:
- `in-review`
- `approval` (default)

## Workflow

1. Verify plan path exists.
2. Resolve validator path by runtime resolver:
- `RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"`
- fail if `"$RESOLVER_PATH"` does not exist.
- `SCRIPT_PATH="$(bash "$RESOLVER_PATH" --plan-execute-script "validate-design-plan-readiness.sh")"`
3. Run readiness validator:
- `bash "$SCRIPT_PATH" "<plan-path>" --phase "<phase>"`
4. Report:
- pass/fail
- missing sections/artifacts
- placeholder content status
- required workflow-state gating failures (for example `model_path_decided`, `codebase_investigation_complete_if_port`, `simulation_contract_complete_if_in_scope`)
- model-path/evidence gating failures (for example missing model-path decision, suggested-model selection without citations, or existing-codebase-port source pin/parity/investigation gaps)
- synthetic-data-validation gating failures (for example validation scope `yes` without explicit simulate contract or validation experiments)

## Output

1. Validation result (`pass` or `fail`).
2. Remaining blockers (if any).
