---
name: bootstrap-scientific-software-playbook
description: Use when initializing the current project with the scientific software playbook from CODEX_HOME - runs the installed bootstrap script against the working directory and verifies required assets are present.
---

# Bootstrap Scientific Software Playbook

Use this skill to install playbook assets into the current project directory.
It is a one-time initializer and should not be treated as an architecture or implementation skill.

## Preconditions

1. Playbook is installed in Codex home:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/`
2. Current directory is the target project root.

## Workflow

1. Resolve Codex home:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
2. Verify bootstrap script exists:
- `"$CODEX_ROOT/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh"`
3. Run bootstrap in current directory:
- `bash "$CODEX_ROOT/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh"`
4. If project is already bootstrapped and user wants overwrite, re-run with force:
- `bash "$CODEX_ROOT/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh" --force`
5. Verify expected files:
- `AGENTS.md`
- `agents/`
- `commands/`
- `hooks/hooks.json`
- `commands/start-simulation-validation.md`
- `scripts/new-design-plan.sh`
- `docs/design-plans/templates/scientific-architecture-plan-template.md`
- `docs/implementation-plans/templates/scientific-implementation-plan-template.md`
- `docs/implementation-plans/templates/phase-simulation-validation-template.md`

## Output

Report:
1. Whether bootstrap succeeded.
2. Which files/directories were created or overwritten.
3. Next command to start planning:
- invoke `scientific-software-architecture` (Codex), or run `/start-scientific-architecture <slug>` (Claude).
