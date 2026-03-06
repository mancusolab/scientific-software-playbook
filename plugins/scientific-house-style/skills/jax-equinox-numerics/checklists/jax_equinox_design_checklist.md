# JAX/Equinox Design Checklist

Use this when defining APIs, Modules, and solver structure.

## Architecture
- [ ] Public APIs are the only JIT boundaries (`eqx.filter_jit` / `jax.jit`).
- [ ] Static configuration is separated from traced dynamic data at the API/runtime boundary.
- [ ] Dynamic inputs are arrays (or PyTrees of arrays) and are the only traced data.
- [ ] PyTree structure and shapes are stable across iterations and calls.

## Modules and ABCs
- [ ] Abstract classes are `eqx.Module` and contain `abc.abstractmethod` or `eqx.AbstractVar`.
- [ ] Use `eqx.AbstractClassVar[...]` when a class-level contract is required.
- [ ] All fields and `__init__` live in a single class (no split initialization).
- [ ] Concrete modules are final (no overriding concrete methods, no subclassing).
- [ ] Constructor-time normalization uses `eqx.field(converter=...)` when canonical runtime values should be enforced.
- [ ] `static=True` is used only for true non-array metadata; arrays are never marked static.
- [ ] Optional attributes are declared on ABCs (no `hasattr` checks).
- [ ] If state types vary, use `TypeVar`/`Generic[...]` for solver state.
- [ ] `__check_init__` enforces invariants where appropriate.
- [ ] `__check_init__` validates invariants only and does not mutate fields.

## Control Flow
- [ ] Looping uses `lax.scan` (fixed length) or `lax.while_loop` (data-dependent).
- [ ] Branching uses `lax.cond` with consistent output structure.
- [ ] Static outputs in branches are wrapped (e.g., `eqxi.Static`).
