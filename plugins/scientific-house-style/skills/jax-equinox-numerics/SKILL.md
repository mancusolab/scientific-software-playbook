---
name: jax-equinox-numerics
description: Use for any JAX + Equinox numerics project; repo-agnostic patterns plus companion checklists to align with local style.
metadata:
  short-description: JAX/Equinox numerics
---

# JAX + Equinox Best Practices

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Guidance for software engineering practices around numerical/JAX codebases using
JAX + Equinox + Lineax + Optimistix.

This file is the entrypoint. Keep it lightweight and load focused references for
implementation details.

## Scope boundary (authoritative split)

This skill is authoritative for numerics runtime semantics:
- JIT boundaries and static/dynamic partitioning
- PyTree and dtype stability in traced execution
- solver/result/failure semantics for numerics surfaces
- traced-kernel error signaling (`result` channels and/or `eqx.error_if`)
- AD/batching/transform correctness checks

This skill is not the source of truth for project-level engineering policy. For:
- API lifecycle/versioning/deprecation policy
- CLI UX/exit-code/stdout-stderr contract
- documentation and docstring style standards
- type-checking and CI/release gates
- packaging and distribution policy
use `../jax-project-engineering/SKILL.md`.

## Path Contract (Unambiguous)

1. All relative paths in this file resolve from this skill directory (the directory containing this `SKILL.md`).
2. Companion checklist and snippet paths are installation-local paths relative to this directory.

## Companion checklists

Apply these checklists when using this skill.

### Installation-local paths (relative to this `SKILL.md`)
- `checklists/jax_equinox_design_checklist.md`
- `checklists/jit_static_pytree_checklist.md`
- `checklists/numerics_ad_testing_checklist.md`
- `checklists/linear_algebra_checklist.md`

## Checklist workflow
- Before implementation: open the relevant companion checklist(s) and scope the work against them.
- During implementation: keep checklist items aligned with code/design decisions.
- Before completion: re-run the checklist and explicitly document any intentionally unchecked item.

## Companion snippets

Use these snippets as implementation starters when they match the task.

### Installation-local paths (relative to this `SKILL.md`)
- `snippets/jit_boundary.py`
- `snippets/partition_static_state.py`
- `snippets/filter_vmap_batching.py`
- `snippets/prng_split_by_tree.py`
- `snippets/filter_cond_static.py`
- `snippets/linear_operator_pattern.py`
- `snippets/custom_jvp_norm.py`
- `snippets/implicit_jvp.py`
- `snippets/test_jvp_finite_difference.py`
- `snippets/abc_module_pattern.py`

## Snippet workflow
- Before implementation: pick a matching snippet and adapt names/signatures to your API.
- During implementation: keep semantics aligned with this skill's rules and your chosen checklist(s).
- Before completion: remove stale placeholder code and verify the adapted snippet still satisfies invariants.

## Definitions (strict)
- JIT boundary: the public API function wrapped with `eqx.filter_jit`/`jax.jit`.
- Static data: non-array metadata/config that must be compile-time constant across calls.
- Dynamic data: array leaves that vary per call and flow through JIT.
- PyTree stability: identical treedef and leaf shapes/dtypes across iterations and calls.
- Abstract module: `eqx.Module` with `abc.abstractmethod` or `eqx.AbstractVar`.
- Final module: concrete `eqx.Module` with no further overrides or subclassing.

## Abstract-vs-Final Module Pattern (Required)

Use abstract-or-final module design by default:
- define interfaces as abstract modules (`abc.abstractmethod`/`eqx.AbstractVar`)
- implement behavior in concrete final modules (no further subclassing)
- avoid subclassing concrete modules to change runtime behavior

Load these assets immediately when module inheritance/composition is in scope:
- snippet: `snippets/abc_module_pattern.py`
- reference: `references/jit_pytree_controlflow.md` (abstract-or-final guidance)

Trigger this section when any of these apply:
- introducing a new `eqx.Module` interface
- extending/reusing an existing module family
- reviewing subclass-based customization in numerics code

## `eqx.Module` vs `typing.NamedTuple` (Decision Rule)

Use `eqx.Module` when:
- the state is coupled to behavior/methods that should travel with that state
- you need abstract/final module interfaces or composition patterns across model components
- explicit module-level extension points/contracts are part of the design

Use `typing.NamedTuple` when:
- the object is a lightweight immutable container (parameters, result bundle, metadata, config snapshot)
- fields are fixed and behavior-free
- no module inheritance/composition contract is required
- you want a simple PyTree-compatible carrier that can still flow through numerics paths

Avoid representing the same conceptual entity as both `eqx.Module` and `NamedTuple`
in the same layer unless a boundary contract explicitly requires conversion.

## Core defaults

### Rule: Keep transformation boundaries explicit
- Do: Put JIT at public boundaries and keep non-array config static.
- Don’t: Let control metadata drift as dynamic leaves across calls.
- Why: Stable traces reduce recompilation risk and debugging overhead.

### Rule: Keep PyTree structure and dtype policy stable
- Do: Maintain treedef/shape stability and normalize to a clear inexact dtype policy.
- Don’t: Mutate structure mid-loop or mix dtypes implicitly in hot paths.
- Why: Structural and dtype drift causes retracing and numerical surprises.

### Rule: Convert tabular/dataframe inputs at boundaries
- Do: Convert Polars/Pandas/table-like inputs to JAX/NumPy arrays immediately at ingress (`to_jax()` and `jnp.asarray(...)` where values are assigned into arrays).
- Do: For workflows with multiple tabular sources (for example phenotype, sample metadata for genotype, covariates), reconcile rows in tabular adapters first using explicit entity keys before array conversion.
- Do: Document reconciliation policy at ingress: join keys, join type, duplicate-key handling, missing-key handling, deterministic row-order freeze, and dropped-row accounting.
- Do: Convert back to tabular formats only at egress adapters.
- Don't: Assume positional row alignment across independently loaded inputs.
- Don’t: Pass dataframe objects into `jit`/`vmap`/`scan` or core solver internals.
- Why: Tabular containers are host-side objects that destabilize tracing, dtype policy, and reproducibility.

### Rule: Keep ingress adapters explicit and copy-policy aware
- Do: Parse external formats at ingress only and convert to canonical JAX/PyTree objects immediately when feasible.
- Do: Declare copy mode per adapter (`zero-copy`, `mmap`, or `single-copy fallback`) and justify any fallback copy.
- Do: Drop raw source containers after conversion so downstream layers carry one canonical representation.
- Don’t: Let raw containers or format-specific objects cross into pipeline/numerics execution.
- Why: Clear ingress boundaries prevent memory duplication and trace instability.

### Rule: Define ingress adapter contracts and tests
- Do: Specify format name, canonical output type, copy mode, and validation checks for each adapter.
- Do: Validate required fields, dtype normalization, shape/index alignment, and domain invariants before adapter output.
- Do: When reconciling multiple tabular inputs, include key-level validation tests (duplicate/missing keys, overlap expectations, deterministic row ordering, and reconciliation counts).
- Do: Use TDD for adapters: failing tests first for boundary rejection, conversion correctness, and copy-mode behavior.
- Don’t: Mark an adapter complete if copy behavior is undefined or untested.
- Why: Ingress defects are hard to diagnose once propagated into numerics.

### Rule: Thread PRNG keys explicitly
- Do: Accept/return keys, split deterministically, and fold in step identifiers.
- Don’t: Use hidden global RNG state.
- Why: Determinism across `jit`/`vmap`/`scan` depends on explicit key flow.

### Rule: Prefer Lineax/Optimistix primitives for solver APIs
- Do: Build linear/nonlinear solves using Lineax/Optimistix entry points first.
- Don’t: Reimplement generic solver loops unless introducing a new algorithm.
- Why: Reuses mature APIs for results, failure signaling, and transform compatibility.

### Rule: Pick one failure contract per numerics surface
- Do: use structured result/status channels when callers must recover/branch on solver outcomes.
- Do: use exception-first semantics when fail-fast behavior is desired for the workflow.
- Do: keep the chosen contract explicit, documented, and tested.
- Don’t: assume convergence or silently ignore solver failures.
- Don’t: mix multiple failure channels by default unless an integration requirement demands it.
- Why: explicit single-channel contracts reduce accidental complexity.

### Rule: Raise early at boundaries; keep traced kernels exception-free
- Do: Perform structural/range/input validation before entering the JIT boundary and raise actionable Python exceptions there.
- Do: Inside traced numerics, use JAX-compatible checks (`result` channels and/or `eqx.error_if`) for runtime checks.
- Don’t: Raise Python exceptions from JIT-compiled loops or solver steps.
- Why: Boundary validation should fail fast, while traced execution requires JAX-compatible control flow.

### Rule: Verify AD and batching behavior, not just primal outputs
- Do: Test JVP/VJP vs finite differences under JIT and mapped execution.
- Don’t: Treat successful forward values as sufficient verification.
- Why: Most regressions in numerics show up first in gradients and batching semantics.

## Pressure-test scenarios (for `testing-skills-with-subagents`)

Use these prompts to harden boundary-conversion and failure-policy compliance:

1. Dataframe ingress pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

You need to feed a Polars DataFrame into a jitted solver in 10 minutes.
A teammate says "just pass the frame through and convert later if needed."

Options:
A) Pass the DataFrame through JIT and convert inside solver steps.
B) Convert at ingress (`to_jax()` / `jnp.asarray(...)`) and keep traced numerics array-only.
C) Convert half now and leave a DataFrame field in solver state.

Choose A, B, or C.
```

2. Traced exception pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

Invalid values appear mid-iteration. It's tempting to `raise ValueError` directly from
the jitted loop because it is the fastest patch.

Options:
A) Raise Python exceptions from the traced loop.
B) Validate earlier at boundaries and use JAX-compatible signaling (`result` and/or `eqx.error_if`) inside traced numerics.
C) Ignore and hope downstream checks catch it.

Choose A, B, or C.
```

## Reference map (load on demand)

Load only the files relevant to your task.

- `references/jit_pytree_controlflow.md`
  Covers JIT boundaries, abstract-or-final module patterns, static/dynamic partitioning,
  `lax.scan`/`while_loop`/`cond`, vmapping/sharding guidance, and PRNG discipline.

- `references/lineax_optimistix_patterns.md`
  Covers operator-centric linear solves, `AutoLinearSolver(well_posed=...)`, trusted tags,
  and nonlinear solve APIs (`root_find`, `least_squares`, `minimise`) with failure handling.

- `references/ad_checkpointing_callbacks.md`
  Covers Equinox AD wrappers, tangent-path failure rules, checkpointing, callback guidance,
  custom primitive helpers, and AD-focused test/diagnostic patterns.

- `references/numerics_dtype_stability.md`
  Covers dtype normalization, guarded divisions/norms, and early nonfinite surfacing.

## Decision guide

If the task is primarily about JIT boundaries, PyTree stability, or mapped control flow,
load `references/jit_pytree_controlflow.md` first.

If the task involves module interface design or inheritance/composition tradeoffs,
load `snippets/abc_module_pattern.py` and `references/jit_pytree_controlflow.md` first.

If the task is primarily about linear/nonlinear solver API design or solver result handling,
load `references/lineax_optimistix_patterns.md` first.

If the task is primarily about custom derivatives, checkpointing, callbacks, or primitive
registration, load `references/ad_checkpointing_callbacks.md` first.

If the task is primarily about dtype policy or numerical guardrails, load
`references/numerics_dtype_stability.md` first.

## Scope note

Rules in the referenced files are part of this skill. This entrypoint is intentionally concise
to reduce instruction weight and improve retrieval quality.

## See also: project engineering

For project-level policy (API lifecycle, CLI contracts, docs standards, type/CI gates,
and serialization packaging), see `../jax-project-engineering/SKILL.md`.
