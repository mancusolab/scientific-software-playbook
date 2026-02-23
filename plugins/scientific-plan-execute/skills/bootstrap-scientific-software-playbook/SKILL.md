---
name: bootstrap-scientific-software-playbook
description: Use when initializing the current project with the scientific software playbook from CODEX_HOME - writes a project-local AGENTS.md that references globally installed playbook assets.
---

# Bootstrap Scientific Software Playbook

Use this skill to initialize the current project with a minimal playbook footprint.
It is a one-time initializer and should not be treated as an architecture or implementation skill.

## Path Contract (Unambiguous)

1. Installation-local plugin path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/`
- Claude plugin install: `<claude-plugin-root>/`
2. Project-local path resolution:
- `AGENTS.md` is written to the active downstream project root (the current working directory when this skill runs).

## Preconditions

1. Plan-execute plugin is installed:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/`
or
- `<claude-plugin-root>/`
2. Current working directory is the target downstream project root.

## Workflow

1. Resolve Codex home:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
2. Resolve bootstrap script path:
- `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run bootstrap in the current downstream project root:
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
