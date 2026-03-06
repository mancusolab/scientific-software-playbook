---
name: testing-skills-with-subagents
description: Use when validating a new or revised skill before treating it as stable - runs baseline and pressure scenarios with delegate agents or direct execution, captures failure modes, and iterates until the skill closes the right loopholes.
user-invocable: false
metadata:
  short-description: Test skills under pressure
---

# Testing Skills With Subagents

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

1. Keep scenario notes and examples inside the skill directory.
2. The worked example for this skill lives at `examples/CLAUDE_MD_TESTING.md`.
3. Test the source-of-truth skill under `plugins/`, not only the installed copy in `CODEX_HOME`.

## Scope Boundary

This skill is authoritative for:
- designing baseline and pressure scenarios for skills
- capturing exact failure modes and rationalizations
- iterating until a skill closes the observed loopholes

This skill is not the source of truth for:
- writing the skill body itself
- plugin registration or manifest updates
- general code testing outside the skill-authoring context

Use `writing-skills` to revise the skill and
`scientific-plan-execute:test-driven-development` when it is installed and
relevant.

## Core Principle

Skill testing is TDD for process guidance. If you did not watch the model fail
without the skill, you do not yet know what the skill must prevent.

## RED / GREEN / REFACTOR

1. **RED**
   - run a realistic scenario without the skill
   - capture the exact shortcut, omission, or rationalization
2. **GREEN**
   - revise the skill to address that specific failure
   - rerun the same scenario with the skill
3. **REFACTOR**
   - add pressure or new edge cases
   - close any new loopholes that appear

If `scientific-plan-execute:test-driven-development` is available, follow it
explicitly. If it is unavailable, use the same discipline directly.

## Good Test Scenario Properties

A useful scenario:
- forces a real choice
- includes pressure or tradeoff
- makes the agent act instead of reciting policy
- gives you a concrete wrong answer when the skill fails

Pressure types worth combining:
- time pressure
- sunk cost
- authority pressure
- exhaustion
- apparent pragmatism

## Minimal Test Loop

1. Write one baseline scenario.
2. Run it without the skill.
3. Record the exact failure.
4. Revise the skill narrowly.
5. Run the same scenario with the skill.
6. Add one harder scenario.
7. Repeat until failures stop changing.

## When Not to Use This

Usually skip this workflow for:
- pure reference skills with no behavioral rule to violate
- tiny wording tweaks that do not change the skill's operational claims
- repo changes unrelated to skill behavior

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Testing only with the skill present | Always capture a baseline failure first |
| Writing academic quiz prompts | Force an actual decision with concrete tradeoffs |
| Revising for hypothetical loopholes only | Address the observed failure before broadening |
| Treating one passing run as enough | Add at least one harder follow-up scenario |
