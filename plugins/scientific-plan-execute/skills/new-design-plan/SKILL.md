---
name: new-design-plan
description: Use when creating a dated scientific architecture plan and required companion artifacts from inside Codex, without asking users to run scripts directly.
---

# New Design Plan

Creates a new design plan and required artifact files.

## Path Contract (Unambiguous)

1. Installation-local utility path examples:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/new-design-plan.sh`
- Claude plugin install: `<claude-plugin-root>/scripts/new-design-plan.sh`
2. Project-local output paths:
- `docs/...` paths in this skill are relative to the active downstream project root.

## Required Input

1. Slug: lowercase hyphenated token, for example `genetics-infer`.
2. Optional title override.

## Workflow

1. Validate slug format (`a-z`, `0-9`, `-`).
2. Resolve utility path:
- `CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"`
- `SCRIPT_PATH="$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/new-design-plan.sh"`
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
