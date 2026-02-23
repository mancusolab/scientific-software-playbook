---
name: new-design-plan
description: Use when creating a dated scientific architecture plan and required companion artifacts from inside Codex, without asking users to run scripts directly.
---

# New Design Plan

Creates a new design plan and required artifact files.

## Required Input

1. Slug: lowercase hyphenated token, for example `genetics-infer`.
2. Optional title override.

## Workflow

1. Validate slug format (`a-z`, `0-9`, `-`).
2. Run plan creation utility:
- `bash scripts/new-design-plan.sh "<slug>"`
or with title:
- `bash scripts/new-design-plan.sh "<slug>" "<title>"`
3. Report created plan file and artifact files.
4. If plan already exists, stop and ask whether to reuse/update it.

## Output

1. Plan path: `docs/design-plans/YYYY-MM-DD-<slug>.md`
2. Artifact directory:
- `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/`
