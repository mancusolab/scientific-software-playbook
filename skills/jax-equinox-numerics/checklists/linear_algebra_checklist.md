# Linear Algebra Checklist

Use this for linear solves, least squares, Jacobian operators, and preconditioning.

## Operator vs matrix
- [ ] Use operator-based representations when matrices are large or implicit.
- [ ] Materialize matrices only when necessary and justified by performance.
- [ ] Keep operator tags accurate (e.g., symmetric/PSD); incorrect tags are unsafe.

## Shape/structure
- [ ] Vector and operator structures match (PyTree shape/dtype compatible).
- [ ] Use `eqx.filter_eval_shape` for mixed PyTrees and `jax.eval_shape` for array-only structures.
- [ ] Keep operator input/output structures static.

## Solver configuration
- [ ] Choose solver based on conditioning and matrix structure.
- [ ] Handle under/overdetermined systems explicitly (least-squares/min-norm).
- [ ] Expose tolerances (`rtol`, `atol`) and max-iteration controls.

## Lineax linear solves
- [ ] Model systems as `lineax.AbstractLinearOperator` and solve with `lineax.linear_solve`.
- [ ] Choose `AutoLinearSolver(well_posed=...)` intentionally (or document explicit concrete solver choice).
- [ ] Treat operator tags as contracts and only apply tags guaranteed by construction.
- [ ] Handle solver outcomes explicitly (`throw=False` + `sol.result` for recoverable flows; `throw=True` for fail-fast paths).

## Optimistix nonlinear solves
- [ ] Use `optimistix` entry points (`root_find`, `least_squares`, `minimise`) with explicit solver objects.
- [ ] Pass problem structure via `has_aux`, `tags`, and solver options instead of hidden closure state.
- [ ] Handle nonlinear failures explicitly (`throw=False` + `sol.result` in recoverable flows; `throw=True` in strict flows).

## Numerical stability
- [ ] Guard ill-conditioned solves with scaling or regularization.
- [ ] Prefer stable norm/conditioning checks over raw inverse operations.
- [ ] Detect nonfinite outputs and propagate result codes.

## AD considerations
- [ ] Use custom JVP/VJP when default gradients are unstable.
- [ ] Mark solver state/options as nondifferentiable.
- [ ] Ensure transpose/adjoint operations are implemented where required.

## Testing
- [ ] Compare against known solutions for small systems.
- [ ] Test singular/ill-conditioned cases and failure paths.
- [ ] Validate JVPs for linear solves when AD is supported.
