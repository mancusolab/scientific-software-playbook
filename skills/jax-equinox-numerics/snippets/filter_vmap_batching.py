import equinox as eqx
import jax.numpy as jnp


@eqx.filter_jit
def solve(x, scale: float):
    return x * scale


batched = eqx.filter_vmap(solve, in_axes=(eqx.if_array(0), None))
xs = jnp.ones((8, 3))
ys = batched(xs, 2.0)
