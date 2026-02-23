---
name: jax-equinox-core-numerics-shell
description: Use when implementing scientific inference kernels with JAX and Equinox - keeps numerics array/PyTree-only, transform-safe, and independent from ingress and orchestration concerns, with integrated solver/API engineering guidance.
---

# JAX/Equinox Core Numerics Shell

This skill governs the numerics layer after boundary conversion and validation are complete.
It includes the JAX/Equinox and solver-engineering rules previously split across companion skills.

## Input Contract

Required inputs:
1. Canonical arrays/PyTrees only.
2. Explicit numerics API surface and result/status schema.
3. Transform requirements (`jit`, `vmap`, AD expectations).

## Output Contract

Required outputs:
1. Transform-safe numerics APIs with structured result/status channels.
2. No parsing/ingress or CLI validation logic inside numerics modules.
3. Test evidence for JIT, VMAP, AD, and failure-mode behavior.

## Numerics Rules

1. Inputs are canonical arrays/PyTrees only.
2. No file parsing, dataframe handling, or domain-format logic.
3. Public numerics APIs define explicit transformation boundaries.
4. Return structured result/status objects rather than ad-hoc mixed outputs.
5. Treat solver failures as explicit control flow through result channels.
6. Keep one canonical entrypoint per numerics workflow; model variants via typed config/options.
7. Avoid trivial pass-through wrappers that add no contract value.

## Integrated JAX/Equinox + Solver Rules

1. Keep JIT boundaries explicit:
- Do: wrap public numerics APIs with `eqx.filter_jit`/`jax.jit`.
- Don't: hide boundary conversion/parsing inside traced kernels.

2. Keep PyTree, shape, and dtype policy stable:
- Do: keep treedef and inexact dtype policy stable across calls.
- Don't: mutate structure/dtype implicitly in iterative hot paths.

3. Thread PRNG keys explicitly:
- Do: pass and return keys; split deterministically.
- Don't: rely on hidden global RNG state.

4. Prefer Lineax/Optimistix primitives for generic solver classes:
- Do: map work to root finding, least squares, minimization, or linear solve when feasible.
- Don't: reimplement generic solver loops unless introducing genuinely new algorithms.

5. Use structured solver result semantics:
- Do: expose deterministic status/result channels (for example `RESULTS` + solution container patterns).
- Do: use `throw=False` paths when recovery/inspection is needed; escalate with throw-style behavior only where strict failure is required.
- Don't: silently ignore non-success states.

6. Raise early at boundaries, not inside traced kernels:
- Do: perform structural/range checks at ingress/pipeline boundaries.
- Do: use JAX-compatible runtime checks/result channels inside traced loops.
- Don't: raise Python exceptions for runtime-state control flow from jitted internals.

## Do/Don't Examples

1. Transformation boundaries
- Do: apply `eqx.filter_jit`/`jax.jit` at public numerics boundaries.
- Don't: push dynamic container parsing into jitted internals.

2. Failure semantics
- Do: use structured `result`/status channels for expected solver failure paths.
- Don't: raise Python exceptions from traced loops for runtime-state failures.

3. Input contracts
- Do: accept canonical arrays/PyTrees produced by ingress/pipeline validation.
- Don't: accept file paths, domain parser outputs, or raw tabular containers.

4. Solver mapping
- Do: evaluate whether explicit update rules can map to Optimistix/Lineax before custom solver work.
- Don't: assume custom solver updates without documenting why existing solvers are insufficient.

## Execution Safety

1. Keep static and dynamic leaves stable.
2. Keep PRNG flow explicit for deterministic behavior.
3. Keep traced kernels free of Python exceptions.
4. Validate external input earlier at boundaries.
5. Keep status/error semantics deterministic and machine-checkable.

## Solver Mapping Quick Checks

1. Can update rules be represented as root finding, least squares, minimization, or linear solve?
2. Are derivative requirements tractable for selected methods?
3. Are constraints/projections expressible with available solver hooks?
4. Can stopping/error semantics map cleanly to the chosen result/status contract?
5. If any answer is no, document a minimal custom-solver scope and benchmark baseline.

## Verification Minimum

1. JIT behavior tests.
2. VMAP consistency tests.
3. AD checks (JVP/VJP vs finite-difference where feasible).
4. Failure-mode tests (`nonfinite`, non-convergence, ill-conditioned inputs).
5. Status/result contract tests for success and non-success paths.
6. Solver mapping tests (or explicit infeasibility documentation) when custom updates are selected.

## TDD Requirements

1. New numerics behavior starts with failing tests for intended contract and transform behavior.
2. Bug fixes require failing regression tests before implementation.
3. Completion requires fresh evidence from relevant test commands.

## Hard Stops

1. If numerics APIs accept raw paths/containers, block handoff.
2. If traced kernels raise Python exceptions for runtime-state control flow, block approval.
3. If solver failures are not represented through explicit status/result channels, block approval.
4. If custom solver work is selected without translation-feasibility rationale, block approval.
