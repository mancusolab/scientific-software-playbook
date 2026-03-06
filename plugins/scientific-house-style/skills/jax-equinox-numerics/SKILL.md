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

This skill is authoritative for numerics runtime semantics and Equinox module
rules that affect traced execution:
- JIT boundaries and static/dynamic partitioning
- PyTree and dtype stability in traced execution
- `eqx.Module` inheritance/composition rules for numerics code
- `eqx.Module` field semantics that affect tracing (`converter`, `static=True`,
  `AbstractVar`, `AbstractClassVar`)
- init-time invariant checks for numerics modules (`__check_init__`)
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
- Abstract class attribute: `eqx.AbstractClassVar[...]` declared on an abstract module.
- Final module: concrete `eqx.Module` with no further overrides or subclassing.
- Converter field: `eqx.field(converter=...)` used to normalize constructor inputs into a canonical runtime representation.
- Static field: `eqx.field(static=True)` field stored in PyTree structure, not as a traced leaf.
- Invariant check: `__check_init__`, used to validate module invariants after initialization without mutating fields.

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

## `eqx.Module` Field And Init Rules (Required)

Apply these rules whenever a numerics design introduces or edits an `eqx.Module`.

### Rule: Keep fields and initialization in one concrete class
- Do: declare concrete fields on the concrete module that owns runtime behavior.
- Do: use abstract modules only for interface requirements (`abc.abstractmethod`,
  `eqx.AbstractVar`, `eqx.AbstractClassVar`).
- Don't: split concrete dataclass fields, initialization responsibilities, or
  concrete method behavior across a subclass hierarchy.
- Why: Equinox module initialization is clearer and safer when concrete state
  lives in one class.

### Rule: Use converters to normalize constructor inputs into canonical runtime values
- Do: use `eqx.field(converter=...)` when callers may provide Python scalars or
  similar host values but the module should store a canonical representation.
- Do: keep the converter side-effect-free and deterministic.
- Don't: scatter ad hoc coercion logic across call sites or traced functions.
- Why: input normalization belongs at construction time, not inside hot numerics
  paths.
- Example use cases:
  - `eqx.field(converter=jnp.asarray)` for numeric scalars that should become arrays
  - dtype or enum normalization for configuration fields consumed at boundaries

### Rule: Use `static=True` sparingly and only for true non-array metadata
- Do: mark a field static only when it is genuinely part of module structure and
  should never participate in JAX transforms.
- Do: prefer `eqx.partition`/`eqx.combine` when you just need to separate array
  from non-array content at a boundary.
- Don't: mark JAX arrays static.
- Don't: treat `static=True` as the default way to keep configuration out of a transform.
- Why: static fields become part of PyTree structure; overuse increases trace
  fragility and can hide incorrect runtime contracts.

### Rule: Use `__check_init__` for invariants, not mutation
- Do: validate shape, dtype, range, and cross-field invariants in `__check_init__`
  when they are intrinsic module properties.
- Do: rely on `__check_init__` instead of `__post_init__` when subclassing or
  custom `__init__` behavior could bypass checks.
- Don't: mutate fields in `__check_init__`.
- Don't: defer invariant validation until the first traced call when the module
  can reject invalid state earlier.
- Why: module invariants should fail fast at construction, and `__check_init__`
  is designed for safe invariant enforcement across inheritance.

### Rule: Use abstract attributes deliberately
- Do: use `eqx.AbstractVar[...]` for required instance attributes and
  `eqx.AbstractClassVar[...]` for required class-level constants on abstract modules.
- Do: document whether a requirement is per-instance state or class-level metadata.
- Don't: use `hasattr`-style probing to simulate abstract contracts.
- Why: explicit abstract attributes make module contracts readable and checkable.

## `eqx.Module` vs `typing.NamedTuple` (Decision Rule)

Use `eqx.Module` when:
- the state is coupled to behavior/methods that should travel with that state
- you need abstract/final module interfaces or composition patterns across model components
- you need Equinox field features such as converters, static fields, or `__check_init__`
- explicit module-level extension points/contracts are part of the design

Use `typing.NamedTuple` when:
- the object is a lightweight immutable container (parameters, result bundle, metadata, config snapshot)
- fields are fixed and behavior-free
- no module inheritance/composition contract is required
- no field conversion or invariant-check hook is required
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

### Rule: Choose the right numerical engine family for the task
- Do: distinguish among linear solves, deterministic nonlinear/optimization routines, and sampling-based inference before selecting libraries or API shapes.
- Do: treat variational inference and other objective-minimizing approximations as deterministic optimization work, not as sampling.
- Don't: use generic "solver" language when the implementation contract is actually posterior sampling.
- Why: linear algebra, optimization, and sampling have different state models, diagnostics, and output contracts.

### Rule: Prefer Lineax for linear solves
- Do: use Lineax first for linear systems, operator-based regression subproblems, and linear steps inside larger algorithms.
- Don't: hand-roll generic linear solve code unless the algorithm is genuinely novel.
- Why: Lineax gives operator-centric APIs, explicit result handling, and structure-aware solver choices.

### Rule: Prefer Optimistix or custom methods for deterministic optimization/nonlinear solves
- Do: use Optimistix entry points first for root finding, least squares, minimization, and other deterministic update loops.
- Do: place variational inference and similar objective-driven approximations in this bucket unless there is a clear reason not to.
- Don’t: reimplement generic nonlinear solver loops unless introducing a new algorithm.
- Why: deterministic optimization needs mature failure signaling, adjoint support, and explicit termination behavior.

### Rule: Prefer BlackJAX for sampling-based inference workflows
- Do: treat MCMC/HMC/NUTS-style workflows as sampling engines with posterior-draw outputs and sampler diagnostics.
- Do: use BlackJAX first when the primary contract is posterior sampling rather than point estimation.
- Do: make chain count, warmup/adaptation, sampling length, PRNG splitting, and diagnostics part of the public contract.
- Don’t: describe sampling workflows as mere "solver" calls or collapse them into optimization terminology.
- Why: samplers have different correctness signals: diagnostics, adaptation behavior, and posterior sample contracts rather than convergence to a single optimum.

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

### Rule: Treat sampler state and sampler outputs as first-class contracts
- Do: specify sampler inputs/outputs explicitly: initial state, warmup/adaptation state, posterior draws, diagnostics, and reproducibility metadata.
- Do: document what constitutes a warning versus a hard failure (for example, divergences, invalid log density, or adaptation breakdown).
- Don’t: return unlabeled arrays of samples without chain/draw/parameter semantics and diagnostic context.
- Why: inference users need interpretable posterior artifacts, not just raw tensors.

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

- `references/blackjax_sampling_patterns.md`
  Covers chain-axis structure, warmup/adaptation contracts, PRNG splitting, diagnostics,
  and posterior-sample output conventions for sampling-based inference.

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

If the task is primarily about sampling-based inference, chain management, warmup/adaptation,
or posterior-sample contracts, load `references/blackjax_sampling_patterns.md` first.

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
