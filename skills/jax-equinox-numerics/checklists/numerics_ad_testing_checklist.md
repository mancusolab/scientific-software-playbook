# Numerics / AD / Testing Checklist

Use this for solver implementation and verification.

## Dtype and stability
- [ ] Inputs are cast once to an inexact dtype at the boundary.
- [ ] External tabular inputs (for example Polars/Pandas frames) are converted to JAX/NumPy arrays at ingress (`to_jax()`, `np.asarray(...)` at assignment boundaries).
- [ ] Tabular/frame reconstruction happens only at egress adapters, never inside core numerics.
- [ ] Dtype policy (x32/x64) is explicit and documented.
- [ ] Divisions and norms are guarded against zero/inf.
- [ ] Nonfinite values are detected early and surfaced predictably.

## PRNG discipline
- [ ] PRNGKeys are explicit inputs/outputs to stochastic functions.
- [ ] Keys are split/folded deterministically (step/time included).
- [ ] PyTree-shaped randomness uses split-by-tree helpers.

## Custom AD
- [ ] For mixed PyTrees/Modules, custom AD uses `eqx.filter_custom_jvp`/`eqx.filter_custom_vjp`.
- [ ] JVP/VJP calls on PyTree inputs use `eqx.filter_jvp`/`eqx.filter_vjp`.
- [ ] Tangent-path solves use `throw=True` when failures cannot be returned through a result channel.
- [ ] Custom primitives include abstract_eval + JVP + transpose.
- [ ] Nondifferentiable state/options/metadata are guarded (`eqxi.nondifferentiable` / `eqxi.nondifferentiable_backward`).

## Memory and callbacks
- [ ] Long iterative pipelines consider `eqx.filter_checkpoint` when memory-bound.
- [ ] Host callbacks on mixed PyTrees use `eqx.filter_pure_callback`.

## Testing
- [ ] JIT + vmap + grad are exercised in tests.
- [ ] JVPs are checked against finite differences where feasible.
- [ ] Batching invariants hold (vmapped vs unbatched consistency).
- [ ] Failure modes (max_steps, nonfinite, ill-conditioned) are tested.

## Debugging
- [ ] `eqx.error_if` is used for runtime errors inside JIT.
- [ ] `jax.debug.print` is used for traced diagnostics.
- [ ] Python exceptions are raised at boundary validation layers, not from traced solver kernels.
- [ ] `EQX_ON_ERROR=breakpoint` is documented for runtime failures.
