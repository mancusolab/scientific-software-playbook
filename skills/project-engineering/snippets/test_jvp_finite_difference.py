import functools as ft

import equinox as eqx
import jax
import jax.numpy as jnp
import jax.random as jr
import jax.tree_util as jtu


def finite_difference_jvp(fn, primals, tangents, eps=1e-5, **kwargs):
    primals_plus = jtu.tree_map(lambda x, t: x + eps * t, primals, tangents)
    primals_minus = jtu.tree_map(lambda x, t: x - eps * t, primals, tangents)
    f_plus = fn(*primals_plus, **kwargs)
    f_minus = fn(*primals_minus, **kwargs)
    return jtu.tree_map(lambda a, b: (a - b) / (2 * eps), f_plus, f_minus)


def getkey(seed=0):
    key = jr.PRNGKey(seed)
    while True:
        key, subkey = jr.split(key)
        yield subkey


def test_jvp_matches_finite_difference():
    keygen = getkey(0)
    key = next(keygen)

    def f(x, y):
        return jnp.sin(x) + y

    x = jr.normal(key, (4,))
    y = jr.normal(next(keygen), (4,))
    tx = jr.normal(next(keygen), (4,))
    ty = jr.normal(next(keygen), (4,))

    def wrapped(x, y):
        return f(x, y)

    # JVP under JIT
    out, t_out = eqx.filter_jit(ft.partial(eqx.filter_jvp, wrapped))(
        (x, y), (tx, ty)
    )

    # Finite difference baseline
    t_expected = finite_difference_jvp(wrapped, (x, y), (tx, ty), eps=1e-5)

    assert jtu.tree_all(
        jtu.tree_map(lambda a, b: jnp.allclose(a, b, atol=1e-4, rtol=1e-4), t_out, t_expected)
    )
