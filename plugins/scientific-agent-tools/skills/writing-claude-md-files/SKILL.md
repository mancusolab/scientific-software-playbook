---
name: writing-claude-md-files
description: Use when creating or updating project context files - covers AGENTS-first repositories, companion CLAUDE.md files where needed, top-level vs domain-level structure, and concise contract-focused content.
user-invocable: false
metadata:
  short-description: Write project context files
---

# Writing CLAUDE.md Files

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

1. Detect whether the repository is `AGENTS.md`-canonical or `CLAUDE.md`-canonical before editing.
2. In `AGENTS.md`-canonical repos, write the substantive content in `AGENTS.md`.
3. Add or maintain companion `CLAUDE.md` pointer files only when that repo already uses the companion convention or explicitly asks for it.
4. Do not create duplicate root context files with conflicting content.

## Scope Boundary

This skill is authoritative for:
- structuring project context files
- deciding what belongs in top-level vs domain-level context
- writing concise purpose, contracts, dependencies, and workflow sections

This skill is not the source of truth for:
- deciding whether a change requires a context update
- plugin manifests or installer docs
- release notes or user documentation

Use `maintaining-project-context` to decide whether an update is needed.

## Core Principle

Project context files should explain what future sessions need but the code will
not say plainly: purpose, contracts, boundaries, dependencies, and operating
rules.

## Top-Level vs Domain-Level

Use the top-level file for:
- repo-wide install or workflow commands
- plugin inventory
- global hard stops or contributor rules
- architecture-wide boundaries

Use a domain or subdirectory file for:
- why that subsystem exists
- contracts it exposes
- dependencies and boundaries specific to that subsystem
- invariants that are not obvious from code

## Recommended Sections

For a top-level context file:
- purpose and audience
- plugin or package inventory
- dependency contract
- source-of-truth paths
- workflow or contributor hard stops

For a domain-level context file:
- purpose
- contracts
- dependencies
- invariants
- key operating constraints

## Writing Rules

1. Prefer concrete statements over aspirational prose.
2. Document stable contracts, not transient implementation details.
3. Keep sections easy to scan.
4. Remove stale statements instead of appending contradictory updates.
5. Match the existing repo convention before introducing new sections.

## Companion CLAUDE.md Files

When a repo uses the AGENTS-plus-CLAUDE companion pattern, keep companion files
minimal. Their job is redirection, not duplication.

Typical companion content:

```markdown
Read @./AGENTS.md and treat its contents as if they were in CLAUDE.md
```

Do not fork the real content across both files.

## Freshness Metadata

Some repos use a `Last verified` date and some do not. Follow the local
convention:

1. if the file family already tracks freshness dates, update them with
   `date +%Y-%m-%d`
2. if the repo does not use freshness dates, do not introduce them casually

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing implementation trivia instead of contracts | Keep the focus on future-session guidance |
| Duplicating full content in both AGENTS.md and CLAUDE.md | Use a pointer companion file when the repo follows that pattern |
| Mixing project-wide and domain-specific rules in one place | Move domain rules to the nearest domain context file |
| Adding dates to repos that do not use them | Follow the existing convention |
