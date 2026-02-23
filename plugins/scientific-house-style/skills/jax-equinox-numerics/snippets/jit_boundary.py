import equinox as eqx
import jax.numpy as jnp


class Config(eqx.Module):
    rtol: float = eqx.field(static=True)
    max_steps: int = eqx.field(static=True)


@eqx.filter_jit
def solve(fn, y0, args, cfg: Config):
    """Public JIT boundary: static config, dynamic arrays."""
    return fn(y0, args)


def fn(y, args):
    return y + args


y0 = jnp.ones((3,))
args = jnp.ones((3,))
_cfg = Config(rtol=1e-6, max_steps=128)
solve(fn, y0, args, _cfg)
