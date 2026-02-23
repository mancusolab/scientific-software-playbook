---
name: jax-equinox-numerics
description: Use for any JAX + Equinox numerics project; repo-agnostic patterns plus companion checklists to align with local style.
metadata:
  short-description: JAX/Equinox numerics
---

# JAX + Equinox Best Practices

Guidance for software engineering practices around numerical/JAX codebases using
JAX + Equinox + Lineax + Optimistix.

This file is the entrypoint. Keep it lightweight and load focused references for
implementation details.

## Path Contract (Unambiguous)

1. All relative paths in this file resolve from this skill directory (the directory containing this `SKILL.md`).
2. Codex install location example: `${CODEX_HOME:-$HOME/.codex}/skills/jax-equinox-numerics/`.
3. Claude plugin location example: `<claude-plugin-root>/skills/jax-equinox-numerics/`.

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
- Do: Convert Polars/Pandas/table-like inputs to JAX/NumPy arrays immediately at ingress (`to_jax()` and `np.asarray(...)` where values are assigned into arrays).
- Do: Convert back to tabular formats only at egress adapters.
- Don’t: Pass dataframe objects into `jit`/`vmap`/`scan` or core solver internals.
- Why: Tabular containers are host-side objects that destabilize tracing, dtype policy, and reproducibility.

### Rule: Thread PRNG keys explicitly
- Do: Accept/return keys, split deterministically, and fold in step identifiers.
- Don’t: Use hidden global RNG state.
- Why: Determinism across `jit`/`vmap`/`scan` depends on explicit key flow.

### Rule: Prefer Lineax/Optimistix primitives for solver APIs
- Do: Build linear/nonlinear solves using Lineax/Optimistix entry points first.
- Don’t: Reimplement generic solver loops unless introducing a new algorithm.
- Why: Reuses mature APIs for results, failure signaling, and transform compatibility.

### Rule: Handle failures through structured result channels
- Do: Use `throw=False` when recovery/inspection is needed and branch on `result`.
- Do: Use `throw=True` in strict or AD tangent paths where no safe result channel exists.
- Don’t: Assume convergence or silently ignore non-success statuses.
- Why: Solver failures are normal control flow in numerics and must be explicit.

### Rule: Raise early at boundaries; keep traced kernels exception-free
- Do: Perform structural/range/input validation before entering the JIT boundary and raise actionable Python exceptions there.
- Do: Inside traced numerics, use `result` channels and `eqx.error_if` for runtime checks.
- Don’t: Raise Python exceptions from JIT-compiled loops or solver steps.
- Why: Boundary validation should fail fast, while traced execution requires JAX-compatible control flow.

### Rule: Verify AD and batching behavior, not just primal outputs
- Do: Test JVP/VJP vs finite differences under JIT and mapped execution.
- Don’t: Treat successful forward values as sufficient verification.
- Why: Most regressions in numerics show up first in gradients and batching semantics.

## Pressure-test scenarios (for `testing-skills-with-subagents`)

Use these prompts to harden boundary-conversion and exception-policy compliance:

1. Dataframe ingress pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

You need to feed a Polars DataFrame into a jitted solver in 10 minutes.
A teammate says "just pass the frame through and convert later if needed."

Options:
A) Pass the DataFrame through JIT and convert inside solver steps.
B) Convert at ingress (`to_jax()` / `np.asarray(...)`) and keep traced numerics array-only.
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
B) Validate earlier at boundaries and use `result`/`eqx.error_if` inside traced numerics.
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

For API stability, documentation style, type checking, CLI patterns, CI gates, and
serialization guidance, see `../project-engineering/SKILL.md`.
