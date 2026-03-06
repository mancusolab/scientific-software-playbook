---
name: writing-claude-directives
description: Use when writing instructions that guide assistant behavior in this repository - skills, AGENTS.md or CLAUDE.md files, and agent prompts. Covers concise directive writing, discovery optimization, and compliance structure.
user-invocable: false
metadata:
  short-description: Write clear directives
---

# Writing Claude Directives

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

1. This skill applies to prompt-like files in `plugins/`, `AGENTS.md`, and companion `CLAUDE.md` files.
2. Examples in this skill are patterns, not mandatory repository wording unless another contract file says otherwise.

## Scope Boundary

This skill is authoritative for:
- concise directive wording
- instruction ordering and emphasis
- discovery-oriented description writing
- prompt structure for skills, agents, and context files

This skill is not the source of truth for:
- plugin registration work
- whether a context file is needed
- the substantive workflow owned by another skill

Use `creating-a-plugin`, `maintaining-project-context`, or the relevant task
skill for those concerns.

## Core Principles

1. The model is already capable. Only write the constraints and context it is
   likely to miss.
2. Tell it what to do, then explain why when the rule is non-obvious.
3. Put critical boundaries near the top of the file and near decision points.
4. Keep prompt structure predictable so important rules are easy to find again.

## Keep Directives Short and Specific

Prefer:
- one clear default action
- one clear escape hatch
- one explicit stop condition

Avoid:
- long narrative history
- multiple competing defaults
- repeating the same rule three different ways unless it is truly a hard stop

## Discovery Rules for Skills and Agents

Descriptions should include:
- the trigger condition
- the user symptom or scenario
- the outcome the directive provides

This matters because discovery depends more on the description than on the body.

## Scope Boundaries Belong in the File

If a directive overlaps a neighboring skill, state the handoff explicitly.

Example:

```markdown
## Scope Boundary

This skill is authoritative for plugin structure and repo registration.
Use `writing-skills` for SKILL.md body content and `creating-an-agent` for
agent prompt design.
```

Do not bury boundary splits in a paragraph the next maintainer will miss.

## Structure Patterns That Work

Preferred sections:

1. `## Path Contract (Unambiguous)` when paths matter
2. `## Scope Boundary` when neighboring ownership exists
3. a short workflow or decision framework
4. a short common-mistakes table

Use XML or fenced blocks only when they genuinely improve copying or parsing.

## AGENTS-First Guidance

When a repository uses `AGENTS.md` as the canonical context file:
- write instructions for `AGENTS.md` first
- use `CLAUDE.md` companions only when the repo already follows that convention
- avoid wording that assumes `CLAUDE.md` is always the primary file

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing abstract principles with no operational action | Add a default action and stop condition |
| Over-explaining obvious ideas | Keep only the non-obvious boundary or workflow |
| Using stale upstream namespace references | Point to local skills or give a direct fallback |
| Treating examples as mandatory text | Label examples as patterns unless they are contract text |
