# Numerical Stability and Dtype Policy

Detailed rules for dtype normalization, divide/norm guards, and nonfinite handling.

## Numerical stability and dtype policy

### Rule: Cast once to an inexact dtype and follow a clear dtype policy
- Do: Normalize dtype at the boundary and keep it consistent.
- Don’t: Mix Python scalars or ints into hot loops.
- Why: Prevents accidental integer math and dtype promotion surprises.
- Example:
```python
import jax.numpy as jnp

x = jnp.asarray(x)
if not jnp.issubdtype(x.dtype, jnp.inexact):
    x = x.astype(jnp.float32)
```
- Allowed break: Safe scalar literals in trivial helpers.

### Rule: Convert dataframe/tabular inputs at ingress
- Do: Convert external table-like inputs (Polars/Pandas/DataFrame columns) to arrays before numerics (`to_jax()` if available, or `jnp.asarray(df.to_numpy())` where assignment into arrays happens).
- Do: Keep internal numerics state as array/PyTree values only.
- Don’t: Carry dataframe objects through traced functions or solver state.
- Why: Host-side table containers are not stable traced values and often hide dtype/object conversions.
- Example:
```python
# Boundary adapter
x = df["x"].to_jax()
y = df["y"].to_jax()
```
- Allowed break: Non-jitted reporting/IO layers.

### Rule: Guard divisions and norms; define stable JVPs
- Do: Use `jnp.where` to avoid divide-by-zero; define stable custom JVPs for norms.
- Don’t: Divide by quantities that can be zero or near-zero without guards.
- Why: Avoids NaNs and unstable gradients.
- Example:
```python
den = jnp.where(den == 0, 1.0, den)
out = num / den
```
- Allowed break: When invariants guarantee nonzero denominators (and you validate them).

### Rule: Validate and surface nonfinite values early
- Do: Use `eqx.error_if` or explicit result codes for nonfinite outputs.
- Don’t: Let NaNs/inf silently propagate.
- Why: Makes failures debuggable and reproducible.
- Example:
```python
import equinox as eqx
import jax.numpy as jnp

x = eqx.error_if(x, ~jnp.isfinite(x), "nonfinite")
```
- Allowed break: Exploratory runs where failures are intentionally ignored.

### Rule: Raise Python exceptions at boundaries, not inside traced kernels
- Do: Validate user/config input in boundary layers and raise actionable exceptions there.
- Do: Use `eqx.error_if` or result-code channels inside traced numerics.
- Don’t: Raise Python exceptions from JIT-compiled loops/steps.
- Why: Boundary validation needs clear UX, while traced kernels need JAX-compatible control flow.

### Rule: Prefer stability-aware primitives over naive chained formulas
- Do: Use primitives with numerically stable implementations for cancellation/overflow-prone expressions.
- Don’t: Build sensitive expressions from raw `exp`/`log`/`sqrt` compositions when a stable primitive exists.
- Why: These primitives use scaling, branching, or fused kernels to reduce overflow/underflow and precision loss.
- Common mappings:

| Prefer | Instead of | Typical use |
| --- | --- | --- |
| `jax.scipy.special.xlogy(x, y)` | `x * jnp.log(y)` | Cross-entropy and KL terms with `x == 0` cases |
| `jax.scipy.special.xlog1py(x, y)` | `x * jnp.log1p(y)` | Stable `x * log(1 + y)` for small `y` |
| `jnp.log1p(x)` | `jnp.log(1 + x)` | Small `x` near zero |
| `jnp.expm1(x)` | `jnp.exp(x) - 1` | Small `x` near zero |
| `jnp.logaddexp(a, b)` | `jnp.log(jnp.exp(a) + jnp.exp(b))` | Pairwise log-domain sums |
| `jax.scipy.special.logsumexp(xs, axis=...)` | `jnp.log(jnp.sum(jnp.exp(xs), axis=...))` | Batched log-domain reductions |
| `jax.nn.softplus(x)` | `jnp.log1p(jnp.exp(x))` | Stable smooth ReLU/logistic link |
| `jax.nn.log_softmax(x, axis=...)` | `jnp.log(jax.nn.softmax(x, axis=...))` | Stable normalized log-probabilities |
| `jax.nn.log_sigmoid(x)` | `jnp.log(jax.nn.sigmoid(x))` | Stable log-probabilities for Bernoulli/logit models |
| `jax.scipy.special.entr(x)` | `-x * jnp.log(x)` | Entropy terms with `x -> 0` behavior |
| `jax.scipy.special.rel_entr(x, y)` | `x * jnp.log(x / y)` | Relative entropy / KL terms |
| `jax.scipy.special.gammaln(x)` | `jnp.log(jax.scipy.special.gamma(x))` | Log-gamma without overflow |
| `jax.scipy.special.betaln(a, b)` | `jnp.log(jax.scipy.special.beta(a, b))` | Log-beta without overflow |
| `jax.scipy.special.log_ndtr(x)` | `jnp.log(jax.scipy.special.ndtr(x))` | Stable Gaussian log-CDF in tail regions |
