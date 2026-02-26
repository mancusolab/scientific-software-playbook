---
name: using-plan-and-execute
description: Use when starting a conversation to choose the correct scientific workflow entry point and enforce skill-first execution discipline.
user-invocable: true
metadata:
  short-description: Workflow entry router
---

# Using Plan-And-Execute

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Purpose

Route each request into the correct lifecycle entrypoint before doing work.

## Entry Decision Table

| Request Type | First Action | Follow-On |
|---|---|---|
| General design request in an existing project | Use `starting-a-design-plan` | Use `new-design-plan` when scaffolding a dated plan file is needed |
| Fresh-project architecture start with model-path decisions | Use `scientific-kickoff` | Then continue with `starting-a-design-plan` and pass kickoff output (`.scientific/kickoff.md`) |
| User asks for model suggestions with citations | Use `scientific-kickoff` (`suggested-model`) | Run `scientific-internet-research-pass` when evidence is uncertain |
| User asks to port from an existing codebase | Use `scientific-kickoff` (`existing-codebase-port`) | Run `scientific-codebase-investigation-pass` and capture file-level findings |
| Approved design plan is ready for task breakdown | Use `starting-an-implementation-plan` | Continue to `executing-an-implementation-plan` in fresh context |
| Implementation plan directory already exists | Use `executing-an-implementation-plan` | Apply review and verification gates before completion |

## Kickoff Scope Rule

`scientific-kickoff` is for fresh-project/model-path tracks. It is not required for every general design request.

Run kickoff when any of these apply:
- model path is not yet selected
- user requests model-family suggestion/selection
- user requests existing-codebase porting
- architecture readiness will be validated for scientific approval

If none apply, continue with normal design orchestration and only introduce kickoff if scope changes.

When kickoff is used, treat `.scientific/kickoff.md` as handoff input to `starting-a-design-plan`.

## Mandatory Operating Rules

1. Before acting, identify the relevant skill(s) and load them.
2. Announce skill usage before using the skill.
3. If a skill has a checklist, create explicit todo items with `update_plan` (or equivalent runtime mapping).
4. Respect hard stops in `AGENTS.md` for approval, traceability, review closure, and verification evidence.

## Default Recommendation

When uncertain, start with `starting-a-design-plan`. If model-path gating becomes necessary, run `scientific-kickoff`, then resume design with kickoff handoff.
