---
name: validate-design-plan
description: Use when validating scientific design-plan readiness in Codex or Claude Code for in-review or approval phases, including model-path and simulation-contract gating checks, without requiring users to run validation scripts directly.
---

# Validate Design Plan

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

Runs design-plan readiness checks and reports pass/fail gaps.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/validate-design-plan-readiness.sh`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/scripts/validate-design-plan-readiness.sh`
2. Script resolution rule:
- resolve from the installed plugin location only (Codex bundle or Claude Code plugin root).
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
2. Resolve validator path by runtime:
- Codex: `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"` then `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/validate-design-plan-readiness.sh"`
- Claude Code plugin: `SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/scripts/validate-design-plan-readiness.sh"`
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
