---
name: bootstrap-scientific-software-playbook
description: Use when initializing the current project with the scientific software playbook from the installed Codex bundle in CODEX_HOME - writes a project-local AGENTS.md that references globally installed playbook assets.
---

# Bootstrap Scientific Software Playbook

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

Use this skill to initialize the current project with a minimal playbook footprint.
It is a one-time initializer and should not be treated as an architecture or implementation skill.

## Path Contract (Unambiguous)

1. Installation-local plugin path:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/`
2. Script resolution rule:
- resolve from the installed Codex bundle only.
- do not use repository-local `scripts/...` paths.
3. Project-local path resolution:
- `AGENTS.md` is written to the active downstream project root (the current working directory when this skill runs).

## Preconditions

1. Plan-execute plugin is installed:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/`
2. Current working directory is the target downstream project root.

## Workflow

1. Resolve bootstrap script path:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
- `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
2. Run bootstrap in the current downstream project root:
- `bash "$SCRIPT_PATH"`
3. If project is already bootstrapped and user wants overwrite, re-run with force:
- `bash "$SCRIPT_PATH" --force`
4. Verify expected file:
- `AGENTS.md`

## Output

Report:
1. Whether bootstrap succeeded.
2. Whether `AGENTS.md` was created or overwritten.
3. Next command to start planning:
- invoke `scientific-software-architecture`.
