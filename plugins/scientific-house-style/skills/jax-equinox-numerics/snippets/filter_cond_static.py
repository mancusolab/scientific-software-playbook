import equinox as eqx
import equinox.internal as eqxi
import jax.lax as lax


def filter_cond(pred, true_fun, false_fun, *operands):
    dyn, stat = eqx.partition(operands, eqx.is_array)

    def _wrap(fn):
        def inner(dyn_ops):
            out = fn(*eqx.combine(dyn_ops, stat))
            dyn_out, stat_out = eqx.partition(out, eqx.is_array)
            return dyn_out, eqxi.Static(stat_out)
        return inner

    dyn_out, stat_out = lax.cond(pred, _wrap(true_fun), _wrap(false_fun), dyn)
    return eqx.combine(dyn_out, stat_out.value)
