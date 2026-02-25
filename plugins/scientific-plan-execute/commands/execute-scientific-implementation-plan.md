---
description: Compatibility alias for execute-implementation-plan
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
model: sonnet
argument-hint: "<absolute-implementation-plan-dir> [absolute-working-dir]"
---

Use your Skill tool to engage the `executing-an-implementation-plan` skill. Follow it exactly as written.

Pass `$1` as the implementation plan directory. Pass `$2` as the working directory when available.
If `$2` is omitted, resolve and use the current repository root as the working directory.
