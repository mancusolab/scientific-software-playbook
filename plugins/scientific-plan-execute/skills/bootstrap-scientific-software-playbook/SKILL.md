---
name: bootstrap-scientific-software-playbook
description: Use when initializing the current project with the scientific software playbook from CODEX_HOME - writes a project-local AGENTS.md that references globally installed playbook assets.
---

# Bootstrap Scientific Software Playbook

Use this skill to initialize the current project with a minimal playbook footprint.
It is a one-time initializer and should not be treated as an architecture or implementation skill.

## Preconditions

1. Plan-execute plugin is installed in Codex home:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/`
2. Current directory is the target project root.

## Workflow

1. Resolve Codex home:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
2. Resolve bootstrap script path with precedence:
- `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh"`
- if `"$SCRIPT_PATH"` is missing, fallback to legacy compatibility path:
  - `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run bootstrap in current directory:
- `bash "$SCRIPT_PATH"`
4. If project is already bootstrapped and user wants overwrite, re-run with force:
- `bash "$SCRIPT_PATH" --force`
5. Verify expected file:
- `AGENTS.md`

## Output

Report:
1. Whether bootstrap succeeded.
2. Whether `AGENTS.md` was created or overwritten.
3. Next command to start planning:
- invoke `scientific-software-architecture` (Codex), or run `/start-scientific-architecture <slug>` (Claude).
