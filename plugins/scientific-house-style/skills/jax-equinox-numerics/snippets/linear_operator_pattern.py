import equinox as eqx
import jax
import jax.numpy as jnp
import lineax as lx


def f(x, args):
    return jnp.sin(x) + args


x = jnp.ones((4,))
args = jnp.ones((4,))

# Closure-convert to avoid closed-over tracers
fn = eqx.filter_closure_convert(f, x, args)

# Jacobian as a linear operator; no explicit matrix materialization
op = lx.JacobianLinearOperator(fn, x, args)

# Apply operator (JVP) and its transpose (VJP)
v = jnp.ones_like(x)
Jv = op.mv(v)
JT = op.transpose().mv(v)
