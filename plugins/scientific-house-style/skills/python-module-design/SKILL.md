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

**Equally important:** once the same boundary starts repeating across several sibling files, promote that boundary into a subpackage instead of continuing to encode it in filenames.

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
- "Why do we have `resource_io.py`, `sumstats_io.py`, and `plink.py` all at the same package level?"
- "This package is flat, but several files clearly belong to the same seam."

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

### Rule: Promote repeated seams into subpackages
- Do: Create a subpackage when multiple sibling files are all expressing the same boundary, for example repeated IO adapters, repeated workflow families, or repeated domain-specific compute surfaces.
- Do: Let directory structure carry the boundary once it is stable.
- Don't: Keep adding more siblings with seam-encoded names such as `resource_io.py`, `sumstats_io.py`, `geno_io.py`, `foo_workflow.py`, `bar_workflow.py` when they all belong to one obvious cluster.
- Why: repeated filename prefixes/suffixes are often a signal that the codebase has already discovered a subpackage boundary but has not named it directly.

### Rule: Subpackages still need coarse, meaningful modules
- Do: Inside a subpackage, group code by stable responsibilities such as `sumstats.py`, `plink.py`, `resource.py`, or `reconcile.py`.
- Do: Merge tiny sibling modules when they would otherwise create a directory full of 20-line files.
- Don't: Replace one giant `io.py` with `io/sub1.py` through `io/sub22.py` where each file is only a thin wrapper or trivial parser.
- Don't: Dump every unrelated adapter into one umbrella `io.py` once the subpackage exists.
- Why: the right goal is meaningful middle granularity: modules large enough to represent a real responsibility, small enough to stay navigable.

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

### Rule: Flat packages are fine until the boundary repeats
- Do: Keep a package flat when there are only a few strong sibling boundaries and they still read naturally as one layer of concepts.
- Do: Re-evaluate once one of those boundaries starts accumulating several sibling modules.
- Don't: treat "flat package" as the default end state for a growing codebase.
- Why: flatness is good when the package is still one navigable layer; it becomes noise when repeated seams are only visible through filenames.

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
  - Have we invented a repeated seam that now deserves its own subpackage?
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

Before keeping several related files flat in one package, also ask:

1. Are multiple sibling files all expressing the same seam, such as IO, workflows, adapters, or algorithms?
2. Are we relying on filename suffixes/prefixes to communicate a boundary the directory structure does not express?
3. Would an `io/`, `workflows/`, `adapters/`, or similar subpackage make navigation more obvious?
4. Is the next natural feature likely to add yet another file to this same cluster?

If yes, prefer a subpackage over more seam-encoded sibling filenames.

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

### Good reasons to promote a subpackage
- three or more sibling modules clearly belong to one seam
- repeated filename suffixes or prefixes are carrying architectural meaning
- a boundary has both public entrypoints and internal helpers/types
- new work is likely to add more files to the same cluster
- package navigation is easier by opening a directory than by scanning similarly named siblings

### Good reasons to merge files inside a subpackage
- two adapter files are both tiny and are usually changed together
- one file only forwards to another module without adding meaningful boundary logic
- splitting by file format or data source created many low-signal modules
- engineers need to open several tiny files to understand one real responsibility

## Real-World Layout Examples

Use these as positive examples of module granularity that reflects real boundaries rather than taxonomy.

### Example: workflow-oriented subpackages (`jaxqtl`)

Observed layout:

```text
jaxqtl/
  __init__.py
  cli.py
  log.py
  families/
    distribution.py
    links.py
    utils.py
  infer/
    glm.py
    optimize.py
    permutation.py
    solve.py
    stderr.py
    utils.py
  io/
    covar.py
    expr.py
    geno.py
    pheno.py
    readfile.py
  map/
    cis.py
    nominal.py
    utils.py
  post/
    qvalue.py
```

Why this is a good split:
- Top-level modules are reserved for package entrypoints and distinct workflows (`cli.py`, simulation entrypoints, logging).
- Subpackages correspond to durable technical seams: distribution families, inference internals, IO adapters, mapping workflows, and post-processing.
- Each subpackage contains several related files, not a pile of one-class placeholders.
- Small passive containers stay near the workflow that uses them, for example `ReadyDataState` in `io/readfile.py` and `GLMState` in `infer/glm.py`, instead of being moved to global `types.py` or `schemas.py`.

Takeaway:
- Create a subpackage when a boundary has its own internal ecosystem of algorithms, helper types, and reusable internals.
- Do not create extra cross-cutting taxonomy layers on top of that. `jaxqtl` uses `infer/`, `io/`, and `map/`, not `models/`, `schemas/`, `services/`, and `helpers/` for the same concepts.

### Example: flat package with sibling domain modules (`perturbvi`)

Observed layout:

```text
perturbvi/
  __init__.py
  annotation.py
  cli.py
  common.py
  factorloadings.py
  guide.py
  infer.py
  io.py
  log.py
  sim.py
  sparse.py
  utils.py
```

Why this is a good split:
- The package stays flat even though it has several modules, because the boundaries are understandable without introducing another nesting level.
- `infer.py` remains the orchestration center and composes domain-specific pieces from `annotation.py`, `factorloadings.py`, `guide.py`, `sparse.py`, `common.py`, and `utils.py`.
- Shared core types live in `common.py`, for example `DataMatrix` and `ModelParams`, because those contracts are reused across several sibling modules instead of belonging to only one workflow.
- `io.py` owns persistence and plotting/output concerns, and `cli.py` owns command-line execution, which keeps side effects separate from the core variational inference modules.
- Specialized representations such as sparse-matrix adapters get their own module (`sparse.py`) because they are a real reusable boundary, not just a helper function.
- The package has one `io.py`, not a growing family of sibling `*_io.py` files.

Takeaway:
- A flat package is still a good choice when the module graph has several sibling boundaries but does not need subpackages yet.
- Split into sibling modules when each file carries a real domain role, but promote a subpackage once one of those roles turns into a cluster rather than preserving flatness by habit.

### Pattern choice heuristic

- Prefer a flat package like `perturbvi` when several sibling modules exist but they still read as one layer of concepts.
- Prefer subpackages like `jaxqtl` when multiple areas have grown into independent clusters with their own APIs and helper internals.
- In both cases, keep lightweight containers, exceptions, and helpers inside the workflow module that gives them meaning unless reuse across boundaries is already real.
- Do not let repeated filename suffixes stand in for a real directory boundary once the cluster is obvious.
- Inside a subpackage, prefer a few responsibility-sized modules over either one giant umbrella module or many trivial leaf modules.

## Review Checklist

Use this checklist when reviewing Python module layout:

- Does each module have one clear responsibility?
- Could two neighboring modules be merged without losing clarity?
- Are there several sibling files that obviously belong to one seam and should become a subpackage?
- Are there passive container files that are only imported by one module?
- Are there trivial wrappers that add no contract value?
- Are custom exceptions doing real work?
- Is the package organized around workflows and boundaries, or around taxonomic labels?
- Are filename prefixes/suffixes doing work the directory structure should do instead?
- Does the current structure reduce navigation cost, or increase it?

## Common Failure Modes

| Failure mode | Why it happens | Better choice |
|--------------|----------------|---------------|
| One file per dataclass | "Schemas feel clean" | Keep small containers near the code that uses them |
| One file per helper | "Helpers should be reusable someday" | Keep private helpers local until reuse is real |
| `base.py` with little value | Want a common place for setup | Put real shared behavior where it is used; avoid placeholder abstraction |
| Many tiny `schemas/` modules | Contract-first planning drift | Use a single local module or colocate types until stable reuse appears |
| FCIS split into too many files | Treating purity as a filesystem rule | Keep the boundary in code flow, not necessarily in file count |
| Repeated seam suffixes in flat packages | Avoiding subpackages too long | Promote the repeated seam into `io/`, `workflows/`, `adapters/`, etc. |

## Smells That Suggest A Missing Subpackage

These are patterns where the codebase is often telling you a real boundary exists, but the directory layout has not caught up yet.

### Smell: multiple sibling `*_io.py` files at one package level
- Example smell: `resource_io.py` and `sumstats_io.py` living next to `plink.py`, `output.py`, and workflow modules in the same package.
- Why it matters: repeated `*_io.py` naming usually means IO has become a real shared concern rather than a one-off helper. The package has started encoding an `io` boundary in filenames instead of in the directory structure.
- Better choice: if there are several IO-oriented modules at the same package level, strongly consider introducing an `io/` subpackage and moving those modules under it.
- Heuristic: two `*_io.py` files is a review trigger; three or more usually means the `io/` boundary is already real.
- Counterpoint: do not create `io/` for a single adapter or a tiny codebase with only one narrow file-format boundary.

### Smell: repeated seam suffixes or prefixes in general
- Example smell: `foo_workflow.py`, `bar_workflow.py`, `baz_workflow.py`, or `geno_adapter.py`, `pheno_adapter.py`, `covar_adapter.py` all living at one package level.
- Why it matters: the codebase is signaling a stable cluster, but the package layout is still pretending those files are unrelated siblings.
- Better choice: create a subpackage that names the seam directly, for example `workflows/` or `adapters/`.
- Heuristic: when filenames need repeated prefixes/suffixes to explain their relationship, the relationship probably deserves a directory.

### Smell: giant umbrella subpackage module
- Example smell: one `io.py` inside an established IO boundary handles genotype readers, sumstats parsing, resource lookup, reconciliation, and output serialization for unrelated workflows.
- Why it matters: the boundary is real, but the module inside it is too broad to navigate cleanly.
- Better choice: split the subpackage into a few responsibility-sized modules.

### Smell: directory full of tiny leaf modules
- Example smell: `io/resource.py`, `io/sumstats.py`, `io/plink.py`, `io/gtf.py`, `io/covar.py`, `io/pheno.py` where several files are only a few lines long and mostly mirror one another.
- Why it matters: the subpackage boundary is correct, but the internal granularity is too fine.
- Better choice: merge tiny files until each module represents a substantial responsibility rather than a filename taxonomy.

## Interaction With Planning Skills

When writing implementation plans:
- name exact files only when investigation shows a new file is necessary
- prefer module-level responsibilities first, file paths second
- prefer naming boundary clusters before naming individual files inside them
- treat "create a new file" as a choice that needs justification

When executing implementation plans:
- allow consolidation if the plan's file layout turns out to be unnecessarily fragmented
- allow promotion from flat files to a subpackage if implementation reveals a repeated seam
- do not preserve temporary phase boundaries just because they were written down earlier

## Output Expectations

When this skill is active, explicitly state:
- whether a new file is justified
- what boundary that file represents
- whether several related files should instead be grouped under a subpackage boundary
- which tiny modules should be merged if reviewing existing code

If no strong justification exists, say so directly and keep the code in an existing module.
