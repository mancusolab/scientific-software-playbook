---
name: writing-skills
description: Use when creating new skills, revising existing skills, or tightening skill quality before release - covers trigger writing, structure, progressive disclosure, and validation with behavioral tests
user-invocable: false
---

# Writing Skills

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

1. Playbook skills live under `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`.
2. Keep the main `SKILL.md` concise and place heavy examples or references in nearby files only when needed.
3. If the skill needs reusable instruction-writing guidance, use `writing-claude-directives`.
4. If the skill changes behavior rather than just storing reference material, validate it with `testing-skills-with-subagents`.

## Core Principle

Good skills are short, findable, and behavioral. A skill should change how the
assistant works, not just repeat general knowledge in a new file.

## Start With The Trigger

The description field determines whether the skill is found.

Write descriptions that:
- start with `Use when ...`
- name real triggers, symptoms, or decisions
- say what the skill changes or enables

Avoid:
- vague summaries
- first-person wording
- descriptions that mention scope but not triggers

## Minimal Skill Structure

```markdown
---
name: skill-name
description: Use when [trigger] - [what the skill does]
user-invocable: false
---

# Skill Title

## Runtime Compatibility
...

## Path Contract (Unambiguous)
...

## Overview
...

## When to Use
...

## Workflow
...

## Common Mistakes
...
```

Not every skill needs every section, but every section should earn its keep.

## What Belongs In The Main File

Keep in `SKILL.md`:
- trigger conditions
- decision rules
- workflow steps
- short examples
- common failure modes

Move to nearby reference files:
- long examples
- comparison matrices
- framework- or runtime-specific variants
- large copied reference material

## Skill Types

| Type | What matters most |
| --- | --- |
| discipline | explicit boundaries and loophole closure |
| technique | concise steps and examples |
| pattern | recognition guidance and non-examples |
| reference | discoverability and accurate lookup |

## Validation Level

Use the smallest validation that matches the skill's risk:

- reference-only skill: read for clarity and path correctness
- technique skill: run one or two application scenarios
- discipline skill: baseline + pressure + loophole tests

If the skill is supposed to prevent rationalization, test it under pressure.

## Companion Skills

- `writing-claude-directives` for better instruction wording
- `testing-skills-with-subagents` for behavior-change evidence
- `creating-a-plugin` when the work expands into a full plugin integration task

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Skill is longer than the behavior it governs | Cut to the rules that actually change decisions |
| Description is not searchable | Add trigger symptoms and task language |
| Heavy examples sit inline in the main file | Move them to a nearby example or reference file |
| No test evidence for a discipline skill | Run baseline and pressure scenarios |
| Repo-specific rules live only in a skill when they should be in `AGENTS.md` | Put repository contracts in the repo context file |

## Release Checklist

- name and directory use the same kebab-case identifier
- description begins with `Use when ...`
- runtime compatibility block is synced
- path contract matches actual repo/runtime behavior
- references are one level deep at most
- validation effort matches the skill's behavioral risk
