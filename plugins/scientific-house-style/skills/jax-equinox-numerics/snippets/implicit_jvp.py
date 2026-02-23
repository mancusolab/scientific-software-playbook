import jax
import jax.numpy as jnp
import lineax as lx
import optimistix as optx


# Global functions only: no closed-over JAX arrays.

def fn_primal(inputs):
    y, a = inputs
    # Example: solve y^2 = a for y (pick positive branch)
    root = jnp.sqrt(a)
    residual = root * root - a
    return root, residual


def fn_rewrite(root, residual, inputs):
    # Rewrite whose Jacobian w.r.t. root is used by implicit JVP
    y, a = inputs
    return root * root - a


inputs = (jnp.array(1.0), jnp.array(4.0))
root, residual = optx.implicit_jvp(
    fn_primal,
    fn_rewrite,
    inputs,
    tags=frozenset(),
    linear_solver=lx.AutoLinearSolver(well_posed=True),
)
