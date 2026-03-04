---
name: python-module-design
description: Use when designing or reviewing Python package/module structure, deciding whether to create or merge files, organizing dataclasses/types/helpers/exceptions, or preventing over-fragmented internal architecture.
user-invocable: false
metadata:
  short-description: Python module/package design
---

# Python Module Design

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Overview

**Core principle:** A new file is a design decision, not a default action.

Prefer cohesive modules over file-per-concept decomposition. Separate modules when there is a real boundary: public API, side-effect boundary, reusable domain model, independent algorithm, or size/readability pressure. Do not create modules just because a concept has a name.

## When to Use

**Use this skill when:**
- deciding whether to create a new Python file or reuse an existing one
- planning package/module layout for a new feature
- reviewing a codebase with many tiny modules or passive schema files
- organizing dataclasses, exceptions, config objects, helpers, and workflow code
- consolidating code after phased delivery

**Trigger symptoms:**
- "Should this be its own file?"
- "We have too many tiny modules."
- "There are a lot of dataclasses and wrappers."
- "The plan names many files, but I am not sure they are real boundaries."

## Scope Boundary

This skill is authoritative for:
- Python module and package granularity
- when to split or merge files
- placement of passive data containers, helpers, and exceptions
- cohesion vs taxonomy tradeoffs
- anti-fragmentation review checks

This skill is not the source of truth for:
- functional-core / imperative-shell separation
- JAX runtime semantics
- CLI/user-facing API contract policy
- test methodology

Use companion skills for those concerns.

## Core Defaults

### Rule: Prefer cohesive modules over file-per-concept decomposition
- Do: Group related types, helpers, and workflow logic into one module when they serve one responsibility.
- Don't: Create a new file just because a class, function, or concept has a name.
- Why: File count is a maintenance cost. Small files are useful only when they create a meaningful boundary.

### Rule: New files require explicit justification
Before creating a new source file, identify at least one justification:
1. Distinct public API surface
2. Distinct side-effect boundary
3. Reused domain model shared by multiple workflows
4. Independent algorithmic component with meaningful tests
5. Existing file size/readability pressure

If none apply, keep the code in an existing module.

### Rule: Passive containers stay near their primary use by default
- Do: Keep lightweight dataclasses, named tuples, result bundles, and config objects near the code that uses them.
- Don't: Create standalone `schemas.py`, `types.py`, or per-domain schema modules full of passive containers unless the types are reused across multiple modules or form a stable public contract.
- Why: Passive containers scattered across many files increase navigation cost without strengthening design.

### Rule: Avoid one-function and one-class utility modules
- Do: Colocate small private helpers with their primary workflow or domain module.
- Don't: Create a module whose entire purpose is one helper, one exception, one dataclass, or one trivial wrapper.
- Why: These modules rarely represent a real architectural seam.

### Rule: Exceptions need contract value
- Do: Use built-in exceptions unless callers need to catch a specific domain exception type or the exception carries meaningful structure.
- Don't: Create per-module exception subclasses that add no behavior or public contract.
- Why: Exception proliferation is another form of fragmentation.

### Rule: Organize around workflows or real shared boundaries
- Do: Prefer modules organized around cohesive workflows or genuinely shared boundaries, for example `munge`, `ldscore`, `h2`, `rg`, shared IO adapters, or shared math.
- Don't: Introduce extra taxonomic micro-layers such as `schemas`, `validation`, `types`, `helpers`, or `base` unless they are clearly reused and improve clarity.
- Why: Workflow cohesion is usually more valuable than taxonomic neatness.

### Rule: FCIS boundaries are conceptual, not automatically file boundaries
- Do: Preserve functional-core / imperative-shell separation in control flow and API design.
- Do: Allow one module to contain nearby pure helpers and thin orchestration when that improves cohesion.
- Don't: Split files purely to satisfy a purity label.
- Why: Over-literal FCIS application creates artificial fragmentation.

### Rule: Consolidate before completion
- Do: Review newly added files before calling a feature complete.
- Ask:
  - Can any adjacent modules be merged without losing a real boundary?
  - Are any dataclasses, exceptions, or wrappers only used once?
  - Was any file created to satisfy the plan rather than the code?
- If yes: consolidate before final review.
- Why: Phased delivery often creates temporary boundaries that should not become permanent.

## Decision Framework

Before creating a new Python module, ask:

1. What responsibility would this file own?
2. Is that responsibility materially different from nearby modules?
3. Will another engineer benefit from navigating to this file instead of being forced to jump across more files?
4. Is the boundary likely to remain stable after the current feature is finished?

If the answers are weak, do not create the file.

## Preferred Shapes

### Good reasons to keep code together
- a workflow entrypoint plus a few closely related helpers
- a compute function plus its small result/config types
- an adapter plus the validation logic specific to that adapter
- a shared math routine plus the two helpers only it needs

### Good reasons to split code apart
- a file mixes unrelated workflows
- IO and compute boundaries are reused by multiple features
- one algorithm has independent tests, invariants, and lifecycle
- a public contract must remain stable across several callers
- an existing module has become difficult to read end-to-end

## Review Checklist

Use this checklist when reviewing Python module layout:

- Does each module have one clear responsibility?
- Could two neighboring modules be merged without losing clarity?
- Are there passive container files that are only imported by one module?
- Are there trivial wrappers that add no contract value?
- Are custom exceptions doing real work?
- Is the package organized around workflows and boundaries, or around taxonomic labels?
- Does the current structure reduce navigation cost, or increase it?

## Common Failure Modes

| Failure mode | Why it happens | Better choice |
|--------------|----------------|---------------|
| One file per dataclass | "Schemas feel clean" | Keep small containers near the code that uses them |
| One file per helper | "Helpers should be reusable someday" | Keep private helpers local until reuse is real |
| `base.py` with little value | Want a common place for setup | Put real shared behavior where it is used; avoid placeholder abstraction |
| Many tiny `schemas/` modules | Contract-first planning drift | Use a single local module or colocate types until stable reuse appears |
| FCIS split into too many files | Treating purity as a filesystem rule | Keep the boundary in code flow, not necessarily in file count |

## Interaction With Planning Skills

When writing implementation plans:
- name exact files only when investigation shows a new file is necessary
- prefer module-level responsibilities first, file paths second
- treat "create a new file" as a choice that needs justification

When executing implementation plans:
- allow consolidation if the plan's file layout turns out to be unnecessarily fragmented
- do not preserve temporary phase boundaries just because they were written down earlier

## Output Expectations

When this skill is active, explicitly state:
- whether a new file is justified
- what boundary that file represents
- which tiny modules should be merged if reviewing existing code

If no strong justification exists, say so directly and keep the code in an existing module.
