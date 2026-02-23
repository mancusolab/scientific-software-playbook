---
description: Generate a new dated architecture design plan from template artifacts
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
model: sonnet
argument-hint: "<plan-slug>"
---

# New Design Plan

Create a new design plan file and companion artifact templates.

## Workflow

1. Require a slug in `$1` (`lowercase-hyphenated`).
2. Use the `new-design-plan` skill with the provided slug.
3. Report created files and instruct user to begin with status `Draft`.
4. If plan already exists, stop and ask whether to reuse it.
