---
description: Route the current request into the correct scientific workflow entrypoint
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, WebSearch, WebFetch
model: sonnet
argument-hint: "[request-summary]"
---

# Start Plan-And-Execute

If the user has not yet described what they want to build, change, or investigate, ask for a brief summary first.

If the user has already provided context, do not ask them to repeat it.

Use your Skill tool to engage the `using-plan-and-execute` skill. Follow it exactly as written and continue with the routed workflow.

