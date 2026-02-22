# Testing Checklist (JAX/Equinox Numerics)

Use this to validate correctness, AD, and batching behavior.

## Coverage targets
- [ ] Parametrize over solvers, options, dtypes, and representative problems.
- [ ] Use deterministic PRNG fixtures (no global keys).
- [ ] Run core tests under JIT (`eqx.filter_jit` / `jax.jit`).
- [ ] Run core tests under vmap (`eqx.filter_vmap` / `jax.vmap`).

## Correctness
- [ ] Compare against known solutions for small problems.
- [ ] Validate result codes with `throw=False` where applicable.
- [ ] Validate `throw=True` escalation behavior where applicable.
- [ ] For vmapped solves, verify expected failure semantics (`throw=True` batch-fails vs `throw=False` per-item `result` inspection).
- [ ] Boundary validation failures are tested explicitly (bad ranges/flags/paths fail before entering numerics kernels).
- [ ] Include singular/ill-conditioned and nonfinite cases.

## AD checks
- [ ] Compare JVPs to finite differences for key APIs.
- [ ] Test reverse‑mode gradients when supported.
- [ ] Confirm AD behavior under JIT and vmap.

## PyTree + static/dynamic behavior
- [ ] Partition dynamic/static args in tests and recombine inside the function.
- [ ] Confirm PyTree structure stability across iterations.
- [ ] Verify table/dataframe adapters convert at boundaries and traced numerics run on arrays only.

## Performance regressions (smoke)
- [ ] vmapped vs unbatched consistency.
- [ ] Basic compile/run time sanity for representative shapes.
