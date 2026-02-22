import jax
import jax.random as jr
import jax.tree_util as jtu
import jax.numpy as jnp


def split_by_tree(key, tree):
    treedef = jtu.tree_structure(tree)
    return jtu.tree_unflatten(treedef, jr.split(key, treedef.num_leaves))


shape_tree = {"a": jax.ShapeDtypeStruct((2, 3), jnp.float32), "b": jax.ShapeDtypeStruct((4,), jnp.float32)}
key = jr.PRNGKey(0)
keys = split_by_tree(key, shape_tree)

samples = jtu.tree_map(lambda k, s: jr.normal(k, s.shape, s.dtype), keys, shape_tree)
