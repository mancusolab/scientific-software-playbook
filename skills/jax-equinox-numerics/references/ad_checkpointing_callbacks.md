# AD, Checkpointing, and Callback Patterns

Detailed rules for AD wrappers, tangent-failure behavior, nondifferentiable metadata, checkpointing, custom primitives, callbacks, and AD testing.

## AD and checkpointing

### Rule: Use Equinox AD wrappers for custom JVP/VJP
- Do: Prefer `eqx.filter_custom_jvp`/`eqx.filter_custom_vjp` for custom AD on PyTrees.
- Don’t: Use raw `jax.custom_*` and then manually manage static/dynamic leaves.
- Why: Keeps PyTree filtering consistent with Equinox transformations.
- Example:
```python
import equinox as eqx

@eqx.filter_custom_jvp
def f(x):
    ...
```
- Allowed break: Non-Equinox functions that only accept plain arrays.

### Rule: Prefer `eqx.filter_jvp`/`eqx.filter_vjp` for PyTrees
- Do: Use Equinox AD wrappers for JVP/VJP on Module or PyTree inputs.
- Don’t: Use raw `jax.jvp`/`jax.vjp` and then stitch static leaves by hand.
- Why: Keeps static/dynamic partitioning aligned through AD transforms.
- Example:
```python
import equinox as eqx

def f(x):
    ...

value, tangents = eqx.filter_jvp(f, (x,), (tx,))
```
- Allowed break: Plain array functions.

### Rule: Use `throw=True` in tangent solves when errors can't be routed
- Do: Force `throw=True` inside tangent/JVP/VJP solves to avoid silent failures.
- Don’t: Ignore solver failures in AD paths that have no result channel.
- Why: There is no result channel for tangent failures.
- Example:
```python
import lineax as lx

sol = lx.linear_solve(op, b, throw=True)
```
- Allowed break: Explicitly tested research prototypes.

### Rule: Mark solver metadata as nondifferentiable
- Do: Use `eqxi.nondifferentiable` for solver state/options and `eqxi.nondifferentiable_backward` for stats/metadata outputs.
- Don’t: Let AD flow through control metadata unless that is intentional.
- Why: Prevents invalid cotangents and unstable gradients through non-optimization state.
- Example:
```python
import equinox.internal as eqxi

state = eqxi.nondifferentiable(state, name="solver state")
stats = eqxi.nondifferentiable_backward(stats)
```
- Allowed break: Research code intentionally differentiating through metadata.

### Rule: Use `eqx.filter_checkpoint` for long iterative pipelines
- Do: Add `eqx.filter_checkpoint` in long iterative pipelines (e.g., scans) to trade compute for memory.
- Don’t: Let large scans blow memory without a checkpointing strategy.
- Why: Reduces peak memory in long sequence models or solvers.
- Example:
```python
import equinox as eqx

@eqx.filter_checkpoint
def body(carry, x):
    ...
```
- Allowed break: Short loops where memory is not a concern.

### Rule: Use `jax.ensure_compile_time_eval` for enum logic
- Do: Wrap tiny enum/predicate logic that must be static.
- Don’t: Let dynamic enums leak into trace-only paths.
- Why: Keeps control-flow predicates consistent under JIT.
- Example:
```python
import jax

with jax.ensure_compile_time_eval():
    pred = is_successful(result)
```
- Allowed break: Non-jitted code paths.

### Rule: Prefer `eqx.filter_pure_callback` for host callbacks
- Do: Use `eqx.filter_pure_callback` for safe host callbacks with PyTrees, when callbacks are pure and JIT-compatible.
- Don’t: Use raw `jax.pure_callback` with mixed static/dynamic leaves.
- Why: Keeps callback inputs/outputs aligned with Equinox filtering.
- Example:
```python
import equinox as eqx

out = eqx.filter_pure_callback(fn, arg, result_shape_dtypes=result_shape)
```
- Allowed break: Pure JAX array-only callbacks.

## Custom JVP/VJP patterns

### Rule: Use custom JVP/VJP for implicit or iterative methods
- Do: Implement custom JVP/VJP (preferably with Equinox wrappers) when autodiff is unstable or too costly.
- Don’t: Rely on default AD for ill-conditioned solves.
- Why: Improves stability and performance.
- Example:
```python
import equinox as eqx
import jax.numpy as jnp

@eqx.filter_custom_jvp
def stable_norm(x):
    return jnp.sqrt(jnp.sum(x * x))

@stable_norm.def_jvp
def _jvp(primals, tangents):
    (x,), (tx,) = primals, tangents
    y = stable_norm(x)
    return y, jnp.where(y == 0, 0.0, jnp.vdot(x, tx) / y)
```
- Allowed break: Array-only functions can use `jax.custom_jvp`/`jax.custom_vjp`.

### Rule: For custom primitives, implement abstract_eval + JVP + transpose
- Do: Provide full AD rules and guard nondiff data.
- Don’t: Register a primitive without transpose/JVP or with leaked tracers.
- Why: Missing rules break AD and batching.
- Example:
```python
# Pseudocode: define impl, abstract_eval, jvp, transpose
# and use materialised zeros for missing tangents.
```
- Allowed break: Research prototypes that intentionally skip AD.

### Rule: Prefer Equinox primitive helpers when defining primitives
- Do: Use `eqxi.filter_primitive_def`/`filter_primitive_jvp`/`filter_primitive_transpose`.
- Don’t: Reimplement primitive registration without filtering static leaves.
- Why: Keeps static/dynamic leaves consistent for AD and batching.
- Example:
```python
import equinox.internal as eqxi

@eqxi.filter_primitive_def
def abstract_eval(...):
    ...
```
- Allowed break: Pure array primitives with no static leaves.
- Note: Advanced/internal usage only. These APIs may change; avoid depending on them in public libraries.

## Performance instrumentation and testing

### Rule: Test JVP/VJP and batching under JIT with finite differences
- Do: Validate AD using finite differences and test vmapped solves.
- Don’t: Only test primal outputs for iterative solvers.
- Why: Catches AD regressions and batching bugs early.
- Example:
```python
out, t_out = eqx.filter_jit(eqx.filter_jvp(f))((x,), (tx,))
# compare with finite_difference_jvp(...)
```
- Allowed break: Minimal smoke tests for early prototypes.

### Rule: Use debug hooks and structured errors for diagnostics
- Do: Use `eqx.error_if`, `jax.debug.print`, and `EQX_ON_ERROR=breakpoint`.
- Don’t: Use Python `print` inside jitted code.
- Why: JIT debugging requires structured error points.
- Example:
```python
jax.debug.print("residual: {}", res)
```
- Allowed break: Non-jitted scripts.

### Rule: Reduce compile-time cost with static choices when possible
- Do: Use static flags or staged subroutines to keep compile graphs small.
- Don’t: Leave everything dynamic when compile time dominates.
- Why: Reduces compilation overhead for large graphs.
- Example:
```python
import equinox as eqx

class Config(eqx.Module):
    use_fast_path: bool = eqx.field(static=True)

@eqx.filter_jit
def run(x, cfg: Config):
    return x if cfg.use_fast_path else x + 1
```
- Allowed break: When adaptive behavior is essential and compile time is acceptable.
