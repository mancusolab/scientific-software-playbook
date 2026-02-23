# JIT, PyTree, and Control-Flow Patterns

Detailed rules for JIT boundaries, module design, PyTree stability, mapped control flow, and PRNG discipline.

## JIT boundaries and static vs dynamic arguments

### Rule: JIT at the public boundary and keep configuration static
- Do: Apply `eqx.filter_jit` at the API boundary and mark non-array config as static.
- Don’t: JIT inside hot loops or pass config as dynamic arrays.
- Why: Prevents retracing and keeps compile graphs stable.
- Example:
```python
import equinox as eqx
import jax.numpy as jnp

class Solver(eqx.Module):
    rtol: float = eqx.field(static=True)
    max_steps: int = eqx.field(static=True)

@eqx.filter_jit
def solve(fn, y0, args, solver: Solver):
    return fn(y0, args)
```
- Allowed break: Debug/prototype code or Python-only inputs.

### Rule: Prefer `eqx.filter_jit` for mixed PyTrees and Modules
- Do: Use `eqx.filter_jit` when inputs include Modules or PyTrees with static leaves.
- Don’t: Use raw `jax.jit` and manually manage `static_argnums` for complex PyTrees.
- Why: Equinox automatically treats non-arrays as static at the leaf level.
- Example:
```python
import equinox as eqx

@eqx.filter_jit
def step(model, x):
    return model(x)
```
- Allowed break: Pure array-only functions.

### Rule: Guard against closed-over JAX arrays with `eqxi.nontraceable`
- Do: Use `eqxi.nontraceable` when you must ensure no closed-over tracers leak across boundaries.
- Don’t: Allow implicit captures of JAX arrays in closures passed into solvers/operators.
- Why: Prevents subtle tracer leaks and undefined behavior under JIT/AD.
- Example:
```python
import equinox.internal as eqxi

out = eqxi.nontraceable(out, name="solve w.r.t. closed-over value")
```
- Allowed break: Pure-Python closures with no JAX arrays.
- Note: This is an internal API; use sparingly and avoid exposing it in public APIs.

### Rule: Closure-convert functions that cross JIT/AD boundaries
- Do: Use `eqx.filter_closure_convert` for functions passed into operators/solvers.
- Don’t: Capture model parameters in a closure while passing only `y` to the solver.
- Why: Avoids closed-over tracers and keeps metadata in the PyTree.
- Example:
```python
import equinox as eqx
import lineax as lx

fn = eqx.filter_closure_convert(fn, x, args)
operator = lx.JacobianLinearOperator(fn, x, args)
```
- Allowed break: Pure Python closures with no JAX arrays (e.g., constants).

## Equinox Modules, ABCs, and generics

### Rule: Use `eqx.Module` for ABCs and follow abstract-or-final
- Do: Define abstract methods/attributes on `eqx.Module` with `abc.abstractmethod` and `eqx.AbstractVar`.
- Don’t: Override concrete methods or split fields across a class hierarchy.
- Why: Enforces readable initialization and eliminates override ambiguity.
- Example:
```python
import abc
import equinox as eqx
from jaxtyping import Array, PyTree

class AbstractSolver(eqx.Module):
    rtol: eqx.AbstractVar[float]

    @abc.abstractmethod
    def step(self, y: PyTree[Array], state): ...

class MySolver(AbstractSolver):
    rtol: float

    def step(self, y, state):
        ...
```
- Allowed break: Non-Equinox code or one-off prototypes.

### Rule: Mark control-flow metadata as static
- Do: Use `eqx.field(static=True)` for non-array metadata that influences control flow.
- Don’t: Pass control flags/dtypes as dynamic arrays.
- Why: Prevents retracing and keeps control flow stable under JIT.
- Example:
```python
import equinox as eqx
import jax.numpy as jnp

class Config(eqx.Module):
    dtype: jnp.dtype = eqx.field(static=True)
    max_steps: int = eqx.field(static=True)
```
- Allowed break: Prototypes where retracing is acceptable.

### Rule: Use `TypeVar`/`Generic` to express state types when needed
- Do: Parameterize solver ABCs with `Generic[_State]` if state differs by solver.
- Don’t: Use `Any` for state or change state structure across iterations.
- Why: Makes state shape explicit and improves type checking.
- Example:
```python
import abc
from typing import Generic, TypeVar
import equinox as eqx
from jaxtyping import PyTree, Array

_State = TypeVar("_State")

class AbstractIterativeSolver(eqx.Module, Generic[_State]):
    @abc.abstractmethod
    def init(self, y: PyTree[Array]) -> _State: ...

    @abc.abstractmethod
    def step(self, y: PyTree[Array], state: _State) -> tuple[PyTree[Array], _State]: ...
```
- Allowed break: Single-solver scripts where state is fixed and local.

## PyTree stability and recompilation avoidance

### Rule: Partition dynamic vs static state and keep static unchanged
- Do: `eqx.partition` state, update dynamic leaves, and assert static stability.
- Don’t: Replace buffers with different shapes or change treedef mid-loop.
- Why: JIT assumes stable structure; changes trigger recompilation or errors.
- Example:
```python
import equinox as eqx

state = solver.init(...)
state_dyn, state_static = eqx.partition(state, eqx.is_array)

new_state = solver.step(...)
new_dyn, new_static = eqx.partition(new_state, eqx.is_array)
assert eqx.tree_equal(state_static, new_static) is True
state = eqx.combine(state_static, new_dyn)
```
- Allowed break: Only outside JIT with an explicit re-jit boundary.

### Rule: Use the right shape-eval tool for structure checks
- Do: Use `eqx.filter_eval_shape` for mixed PyTrees (arrays + non-arrays), and `jax.eval_shape` for array-only structures.
- Don’t: Infer structure from runtime values inside JIT.
- Why: Structure checks must not execute numerics.
- Example:
```python
import equinox as eqx
import jax
import jax.tree_util as jtu

struct = eqx.filter_eval_shape(lambda: (y, {"meta": "x"}))
arr_struct = jax.eval_shape(lambda: y)
assert jtu.tree_structure(struct) == jtu.tree_structure(expected_struct)
```
- Allowed break: Small non-jitted utilities.

### Rule: Avoid dummy arrays for structure checks
- Do: Use shape-eval (`eqx.filter_eval_shape` or `jax.eval_shape`) instead of fabricated inputs.
- Don’t: Construct fake arrays just to discover shapes/dtypes.
- Why: Avoids accidental device work and keeps structure checks pure.
- Allowed break: Tiny scripts outside JIT.

### Rule: Preserve static outputs in control flow
- Do: Wrap static outputs with `eqxi.Static` (or helper) inside `lax.cond`.
- Don’t: Return Python objects from one branch and arrays from another.
- Why: `lax.cond` requires consistent output structure.
- Example:
```python
import equinox as eqx
import equinox.internal as eqxi
import jax.lax as lax

def filter_cond(pred, true_fun, false_fun, *ops):
    dyn, stat = eqx.partition(ops, eqx.is_array)
    def _wrap(fn):
        def inner(dyn_ops):
            out = fn(*eqx.combine(dyn_ops, stat))
            dyn_out, stat_out = eqx.partition(out, eqx.is_array)
            return dyn_out, eqxi.Static(stat_out)
        return inner
    dyn_out, stat_out = lax.cond(pred, _wrap(true_fun), _wrap(false_fun), dyn)
    return eqx.combine(dyn_out, stat_out.value)
```
- Allowed break: Non-jitted control flow.

## vmap / scan / lax usage patterns

### Rule: Use `lax.scan` for fixed-length loops and `lax.while_loop` for data-dependent loops
- Do: Replace Python loops under JIT with `lax.scan`/`lax.while_loop`.
- Don’t: Use Python `for/while` when loop bounds depend on arrays.
- Why: Preserves traceability and avoids repeated tracing.
- Example:
```python
import jax.lax as lax

carry, ys = lax.scan(body_fn, init_carry, xs)
final = lax.while_loop(cond_fn, body_fn, init_state)
```
- Allowed break: Small loops outside JIT.

### Rule: Use `eqx.filter_vmap` with explicit `in_axes`
- Do: Batch solvers with explicit `in_axes` that keep static args static, e.g. `eqx.if_array(0)`.
- Don’t: Accidentally batch config/static fields.
- Why: Prevents wrong broadcasting and retracing.
- Example:
```python
import equinox as eqx

batched_solve = eqx.filter_vmap(solve, in_axes=(None, eqx.if_array(0), None))
```
- Allowed break: When the entire module is intentionally batched.

### Rule: Prefer `eqx.filter_jit` + `eqx.filter_shard` over `filter_pmap`
- Do: Use sharded inputs/constraints with `eqx.filter_jit` and `eqx.filter_shard` for most parallelism.
- Don’t: Reach for `filter_pmap` unless you need pmap-specific behavior.
- Why: Equinox now recommends JIT + sharding for most cases.
- Example:
```python
import equinox as eqx
import jax
import jax.sharding as jshard

mesh = jax.make_mesh((num_devices,), ("batch",))
data_sharding = jshard.NamedSharding(mesh, jshard.PartitionSpec("batch"))

@eqx.filter_jit
def step(state, batch):
    batch = eqx.filter_shard(batch, data_sharding)
    ...
```
- Allowed break: Existing `pmap`-based code or explicit `axis_name` collectives.

### Rule: Avoid compiling heavy functions twice inside branches
- Do: Use `lax.scan` or a shared subroutine when evaluating heavy functions multiple times.
- Don’t: Duplicate large calls in separate branches of `lax.cond`.
- Why: Reduces compile time and graph size.
- Example:
```python
import jax.lax as lax
import jax.numpy as jnp

(init_out, _), _ = lax.scan(step_fn, init_carry, jnp.arange(2))
```
- Allowed break: Trivial functions where clarity dominates.

## PRNG discipline

### Rule: Thread keys explicitly; split and fold_in deterministically
- Do: Accept and return PRNGKeys; use `split` and `fold_in` for steps/times.
- Don’t: Create keys inside jitted code or rely on global RNG state.
- Why: Ensures determinism under JIT/vmap/scan.
- Example:
```python
import jax.random as jr

key = jr.PRNGKey(0)
key, subkey = jr.split(key)
key = jr.fold_in(key, step_index)
```
- Allowed break: Standalone scripts/benchmarks (still prefer explicit keys).

### Rule: Split keys by PyTree structure when sampling PyTree outputs
- Do: `split_by_tree(key, shape_tree)` and map over leaves.
- Don’t: Use `split(key, n)` with implicit leaf ordering.
- Why: Keeps randomness aligned with structure and stable under refactors.
- Example:
```python
keys = split_by_tree(key, output_shape_tree)
out = jax.tree_util.tree_map(sample_leaf, keys, output_shape_tree)
```
- Allowed break: Flat arrays with stable leaf ordering.
