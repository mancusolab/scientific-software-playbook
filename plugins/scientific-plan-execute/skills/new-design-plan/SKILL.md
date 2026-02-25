---
name: new-design-plan
description: Use when creating a dated scientific architecture plan and required companion artifacts from inside Codex or Claude Code, without asking users to run scripts directly.
---

# New Design Plan

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

Creates a new design plan and required artifact files.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/new-design-plan.sh`
- Claude Code plugin install: `<claude-plugin-root>/scripts/new-design-plan.sh`
2. Script resolution rule:
- resolve from the installed plugin location only (Codex bundle or Claude Code plugin root).
- do not use repository-local `scripts/...` paths.
3. Project-local output paths:
- `docs/...` paths in this skill are relative to the active downstream project root.

## Required Input

1. Slug: lowercase hyphenated token, for example `genetics-infer`.
2. Optional title override.

## Workflow

1. Validate slug format (`a-z`, `0-9`, `-`).
2. Resolve utility path by runtime:
- Codex: `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"` then `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/new-design-plan.sh"`
- Claude Code plugin: `SCRIPT_PATH="<claude-plugin-root>/scripts/new-design-plan.sh"`
- fail if `"$SCRIPT_PATH"` does not exist.
3. Run plan creation utility:
- `bash "$SCRIPT_PATH" "<slug>"`
or with title:
- `bash "$SCRIPT_PATH" "<slug>" "<title>"`
4. Report created plan file and artifact files.
5. If plan already exists, stop and ask whether to reuse/update it.

## Output

1. Plan path: `<project-root>/docs/design-plans/YYYY-MM-DD-<slug>.md`
2. Artifact directory:
- `<project-root>/docs/design-plans/artifacts/YYYY-MM-DD-<slug>/`
