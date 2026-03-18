---
description: Start scientific kickoff to select model path and capture readiness state before design planning
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, WebSearch, WebFetch, Skill
model: sonnet
---

Use your Skill tool to engage the `scientific-kickoff` skill. Follow it exactly as written.

Before concluding, follow the skill's "Kickoff Handoff" section **verbatim** — output the handoff block exactly as written. Do NOT shorten or omit the `scientific-plan-execute:` plugin prefix from commands:
- Claude Code: `/scientific-plan-execute:start-design-plan <slug>`
- Codex: `$starting-a-design-plan <slug>`
- `/start-design-plan` alone will NOT resolve
- Explicitly require `.scientific/kickoff.md` handoff ingestion in that next step.
