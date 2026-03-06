---
name: creating-an-agent
description: Use when creating or updating repository agents for plugins or maintainer workflows - defines trigger descriptions, tool scopes, mandatory first actions, and output contracts
user-invocable: false
---

# Creating an Agent

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Path Contract (Unambiguous)

1. Repository agents live under `plugins/<plugin-name>/agents/*.md`.
2. If an agent is exposed through a plugin manifest, list it explicitly in `.claude-plugin/plugin.json` using a `./agents/<name>.md` path.
3. If an agent depends on skills, reference them by skill ID or namespaced skill ID, not by repo-local `skills/.../SKILL.md` paths.
4. If a repo contract requires special sections, follow that contract exactly. In this repo, `plugins/scientific-plan-execute/agents/*.md` must include `## Mandatory First Actions` before `## Responsibilities`.

## Overview

Create an agent when a focused delegate with narrower tools, clearer triggers, or
stronger process discipline will outperform the default assistant. Good agents do
not restate generic model behavior; they make delegation safer and more
predictable.

## When to Use

Use this skill when:
- adding a new agent to a plugin
- tightening trigger descriptions so delegation happens for the right tasks
- restricting tools for review, maintenance, or research work
- standardizing output format across repeated delegated tasks

Do not create an agent for:
- work that a skill alone can guide
- one-off tasks with no recurring trigger
- vague responsibilities that overlap every other agent

## Minimal Agent Template

```markdown
---
name: agent-name
description: Use when [specific triggers or symptoms] - [what the agent does]
tools: Read, Grep, Glob, Bash
model: sonnet
---

# Agent Name

## Mandatory First Actions

Required skills to load first:
- `some-skill`

Additional skills to load only when scope indicates they apply:
- `other-skill`

Fail action:
- If a required skill cannot be loaded, stop and report `blocked`.

## Responsibilities

1. Analyze the task in scope.
2. Perform the bounded workflow.
3. Return structured findings or implementation status.
```

## Description Rules

The `description` field is the routing hook. Make it concrete.

Good descriptions:
- start with `Use when ...`
- include real trigger symptoms, artifacts, or decisions
- say what the agent does after delegation

Bad descriptions:
- "Helps with code"
- "General assistant for projects"
- descriptions that name responsibilities but not triggers

## Mandatory First Actions

Use this section whenever the agent must load other skills or enforce a startup
gate.

Structure it exactly as:

1. required skills that must be loaded first
2. additional skills loaded only when scope indicates they apply
3. fail action if required skills cannot be loaded

Keep the list short. Only require skills the agent cannot operate safely
without.

## Tool Selection

Choose the smallest tool set that still lets the agent finish its work:

| Tool | Use when |
| --- | --- |
| `Read`, `Grep`, `Glob` | analysis, review, discovery |
| `Edit`, `Write` | implementation or document updates |
| `Bash` | command execution, git, verification |
| `Task` | further delegation when truly needed |

Examples:
- reviewer: `Read, Grep, Glob`
- maintainer: `Read, Edit, Write, Grep, Glob, Bash`
- implementor: `Read, Edit, Write, Grep, Glob, Bash`

## Body Structure

After frontmatter, keep the body practical:

1. one-paragraph role statement
2. `## Mandatory First Actions` when required
3. `## Responsibilities`
4. `## Workflow`
5. `## Output Format`
6. `## Constraints`

If the workflow mostly delegates to a skill, say so instead of duplicating the
entire skill.

## Output Contracts

Agents should return a stable structure when humans or parent workflows depend
on the output. Examples:
- findings with severity and file references
- maintenance report with updated files
- status report with blockers and verification evidence

Do not make output formats so rigid that the agent cannot handle edge cases.

## Validation Checklist

Before shipping the agent:

- description triggers the right work and excludes obvious non-target work
- tools are no broader than necessary
- required skills exist and are named correctly
- manifest lists the agent if the plugin exposes agents
- any repo-specific section order contract is satisfied

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Agent overlaps every task | Narrow the description to concrete triggers |
| Agent body duplicates a full skill | Point to the skill and keep the agent focused on delegation behavior |
| Tools include write access for pure review | Restrict to read/search tools |
| Skill references use file paths | Use skill IDs instead |
| Missing `## Mandatory First Actions` where required | Add the section before responsibilities |
