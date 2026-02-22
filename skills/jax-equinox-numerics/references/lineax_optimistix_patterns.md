# Lineax and Optimistix Solver Patterns

Detailed rules for linear and nonlinear solver APIs, structure hints, and failure handling semantics.

## Lineax solver patterns

### Rule: Model linear systems with Lineax operators and `linear_solve`
- Do: Represent systems as `AbstractLinearOperator` (`MatrixLinearOperator`, `FunctionLinearOperator`, `JacobianLinearOperator`) and call `lx.linear_solve`.
- Don’t: Materialize inverses (`jnp.linalg.inv(A) @ b`) in hot paths.
- Why: Preserves operator structure, improves numerical stability, and returns structured `Solution` + `RESULTS`.
- Example:
```python
import lineax as lx

op = lx.MatrixLinearOperator(matrix)
sol = lx.linear_solve(op, b, solver=lx.AutoLinearSolver(well_posed=True), throw=False)
```
- Allowed break: Tiny, one-off dense systems outside performance-critical code.

### Rule: Choose `AutoLinearSolver(well_posed=...)` intentionally
- Do: Keep `well_posed=True` for square nonsingular systems; set `well_posed=False` for least-squares/min-norm problems.
- Don’t: Depend on accidental behavior for under/overdetermined systems.
- Why: Solver selection and failure semantics depend on this contract.
- Example:
```python
solver = lx.AutoLinearSolver(well_posed=False)  # least-squares / min-norm settings
sol = lx.linear_solve(op, b, solver=solver, throw=False)
```
- Allowed break: Explicitly chosen concrete solvers when you already know matrix structure.

### Rule: Treat Lineax tags as trusted contracts
- Do: Attach tags (e.g. symmetric/PSD/triangular) only when guaranteed by construction.
- Don’t: Add tags speculatively to chase speed.
- Why: Incorrect tags can silently return wrong answers.
- Example:
```python
op = lx.MatrixLinearOperator(matrix, lx.positive_semidefinite_tag)
```
- Allowed break: None for production code; validate first in exploratory work.

### Rule: Use `throw`/`result` deliberately in linear solves
- Do: Use `throw=False` in recoverable or batched flows and branch on `sol.result`; use `throw=True` when fail-fast is required.
- Don’t: Ignore non-success result codes.
- Why: Keeps batch behavior and error handling predictable.
- Example:
```python
sol = lx.linear_solve(op, b, throw=False)
if sol.result != lx.RESULTS.successful:
    ...
```
- Allowed break: Strict scripts/tests where immediate failure is preferable.

## Optimistix nonlinear solve patterns

### Rule: Use Optimistix entry points for nonlinear solves
- Do: Express problems via `optx.root_find`, `optx.least_squares`, or `optx.minimise` with explicit solver objects.
- Don’t: Hand-roll nonlinear solver loops unless you are implementing a new method.
- Why: You get consistent `Solution` structure, adjoint integration, and failure reporting.
- Example:
```python
import optimistix as optx

sol = optx.root_find(fn, optx.Newton(rtol=1e-6, atol=1e-9), y0, throw=False)
```
- Allowed break: Novel research algorithms that are not covered by existing solvers.

### Rule: Pass problem structure through `has_aux`, `tags`, and options
- Do: Use `has_aux=True` for auxiliary outputs and provide Lineax tags/options when solver/adjoint can exploit Jacobian structure.
- Don’t: Hide structure in closures or ad-hoc global state.
- Why: Improves solver robustness and performance without changing API shape.
- Example:
```python
import lineax as lx
import optimistix as optx

sol = optx.root_find(fn, solver, y0, has_aux=True, tags=frozenset({lx.symmetric_tag}))
```
- Allowed break: Simple scalar problems where structure hints are irrelevant.

### Rule: Handle nonlinear failures with `throw` + `sol.result`
- Do: Use `throw=False` for recoverable failures and inspect `sol.result`; use `throw=True` for strict paths.
- Don’t: Assume convergence by default.
- Why: Nonlinear methods can legitimately fail; explicit handling avoids silent degradation.
- Example:
```python
sol = optx.least_squares(fn, solver, y0, throw=False)
if sol.result != optx.RESULTS.successful:
    ...
```
- Allowed break: Unit tests that intentionally require immediate failure on non-success.

### Rule: Reserve semi-public internals for library-level extensions
- Do: Use advanced internals (`eqxi.filter_primitive_*`, nontraceable checks, custom adjoint plumbing) only when building solver libraries.
- Don’t: Expose semi-public internals as stable end-user APIs.
- Why: Internal APIs are powerful but can change across versions.
- Allowed break: Controlled internal codebases with pinned versions and dedicated maintenance.
