# JIT / Static / PyTree Checklist

Use this before performance tuning or when encountering retracing.

## JIT boundaries
- [ ] JIT is applied once at the public API boundary.
- [ ] For multi-device sharding, prefer `eqx.filter_jit` + `eqx.filter_shard`; use `filter_pmap` only when pmap-specific semantics are required.
- [ ] No nested JITs inside inner loops or solver steps.
- [ ] Large subgraphs are staged explicitly if compile time dominates.

## Static vs dynamic
- [ ] All non-array config is static (fields or partitioned).
- [ ] `eqx.filter_jit` is preferred for mixed PyTrees/Modules; `jax.jit` is reserved for array-only functions.
- [ ] No Python objects or containers flow as dynamic inputs.
- [ ] Table/dataframe objects (Polars/Pandas) are converted to arrays at ingress; traced functions receive only arrays/PyTrees.
- [ ] `eqx.filter_closure_convert` is used for functions passed across JIT/AD boundaries.
- [ ] Closed-over JAX arrays are blocked at boundaries (`eqxi.nontraceable`) when closure conversion is not enough.

## PyTree stability
- [ ] State treedef and leaf shapes/dtypes are unchanged across iterations.
- [ ] Use `eqx.filter_eval_shape` for mixed PyTrees and `jax.eval_shape` for array-only structures.
- [ ] Structure checks avoid fabricated dummy arrays.
- [ ] `eqx.partition` + `eqx.combine` are used to keep static leaves fixed.

## Control flow
- [ ] No Python `if/for/while` branches depend on arrays inside JIT.
- [ ] `lax.cond` branches return identical PyTree structure.
- [ ] `lax.scan` carries only fixed-shape data.
