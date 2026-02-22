import equinox as eqx
import jax.numpy as jnp


class State(eqx.Module):
    buffer: jnp.ndarray
    meta: int = eqx.field(static=True)


state = State(buffer=jnp.zeros((4,)), meta=3)
state_dyn, state_static = eqx.partition(state, eqx.is_array)

# Update dynamic only
new_buffer = state_dyn.buffer + 1.0
new_state = State(buffer=new_buffer, meta=state_static.meta)

new_dyn, new_static = eqx.partition(new_state, eqx.is_array)
assert eqx.tree_equal(state_static, new_static) is True
state = eqx.combine(new_static, new_dyn)
