---
name: maintaining-project-context
description: Use when completing development phases or branches to review whether AGENTS.md or CLAUDE.md files became stale - maps code changes to context-file updates and coordinates accurate contract maintenance
user-invocable: false
---

# Maintaining Project Context

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

1. In AGENTS-first repositories, update `AGENTS.md` as the canonical file and keep companion `CLAUDE.md` pointer files aligned when the repo uses them.
2. In CLAUDE-only repositories, update `CLAUDE.md` directly.
3. Use `writing-claude-md-files` for file structure and wording patterns rather than inventing a new format in place.
4. Use actual repository paths and current code state; do not infer contracts from stale context files alone.

## Core Principle

Context files record contracts, boundaries, and operating rules that are easy to
lose between sessions. When the code changes those contracts, the context must
change too. Stale instructions are worse than short instructions.

## First Decision: Which File Is Canonical?

Check the repo root first:

- root `AGENTS.md` exists: treat `AGENTS.md` as canonical
- no root `AGENTS.md`, but root `CLAUDE.md` exists: treat `CLAUDE.md` as canonical

For AGENTS-first repos:
- read the existing `AGENTS.md` before editing
- update `AGENTS.md`
- ensure companion `CLAUDE.md` pointer files exist where the repo expects them

Companion pointer content:

```markdown
Read @./AGENTS.md and treat its contents as if they were in CLAUDE.md
```

## When Updates Are Required

Update project context when work changed:
- public interfaces or exports
- allowed inputs, outputs, or invariants
- architecture or dependency boundaries
- required workflow steps or operational constraints
- important file layout or source-of-truth paths

Usually do not update context for:
- internal refactors with unchanged contracts
- test-only work
- comment-only edits
- formatting-only changes

## Workflow

### 1. Identify What Changed

Diff against the start of the phase or branch. Separate changes into:
- structural
- contract-facing
- behavioral/invariant
- internal-only

### 2. Map Changes To Context Files

Use the lowest-level file that owns the contract:
- project-wide rules -> root context file
- domain-specific behavior -> domain context file
- cross-domain dependency change -> each affected boundary owner

### 3. Verify Before Editing

Read the current code, not just the old docs. Confirm:
- exported surfaces still match
- invariants still hold
- dependency descriptions are still true
- no stale rules remain after the code change

### 4. Update The Context File

When editing:
- keep the scope of each file tight
- remove stale rules instead of appending new contradictions
- update freshness dates using `date +%Y-%m-%d` when the file format uses them
- keep companion `CLAUDE.md` pointers aligned in AGENTS-first repos

### 5. Report The Maintenance Result

Return:
- which canonical format was detected
- which files changed
- why those files needed updates
- any uncertainty that needs human review

## Quick Rules

| Situation | Action |
| --- | --- |
| New module or domain with its own contract | Create or extend a domain context file |
| CLI/API behavior changed | Update root or owning domain context |
| Architecture decision changed a boundary | Document the new boundary explicitly |
| Implementation details changed only | Usually no context update |

## Integration Points

This skill is the expected context-maintenance bridge for:
- `project-claude-librarian`
- `executing-an-implementation-plan` when available
- `finishing-a-development-branch`

Use `writing-claude-md-files` when the workflow reaches the actual rewrite.

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Updating docs for every code change | Limit updates to contract or boundary changes |
| Editing AGENTS.md without reading it first | Always confirm the current contract before rewriting |
| Leaving a companion pointer stale | Update or create the `CLAUDE.md` pointer in AGENTS-first repos |
| Copying implementation detail into context files | Document intent, boundaries, and contracts instead |
| Guessing freshness dates | Use `date +%Y-%m-%d` |
