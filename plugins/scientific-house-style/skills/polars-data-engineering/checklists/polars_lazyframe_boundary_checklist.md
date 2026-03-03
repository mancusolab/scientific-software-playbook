# Polars LazyFrame Boundary Checklist

Use this checklist when Polars code loads, transforms, reconciles, or exports tabular data.

## Query Shape

- [ ] Multi-step filtering/join/aggregation work starts from `LazyFrame` unless there is a specific eager-only reason.
- [ ] Materialization boundaries are explicit and easy to locate in code.
- [ ] Hidden `collect()` calls are avoided in low-level helpers.

## Reconciliation

- [ ] Independent tabular inputs are joined by explicit keys before array export.
- [ ] Join type is documented.
- [ ] Join cardinality expectation is explicit and enforced with `validate=` where applicable.
- [ ] Duplicate-key policy is documented and tested.
- [ ] Missing-key policy is documented and tested.
- [ ] Null-key matching policy is explicit.
- [ ] Duplicate-column/coalescing policy is explicit.
- [ ] Reconciliation counts are checked or reported.
- [ ] Row-order policy is explicit, including `maintain_order=` when downstream consumers depend on order.

## Schema And Validation

- [ ] Required columns are validated before export.
- [ ] Feature, label, id, and metadata columns are separated explicitly.
- [ ] Null-handling policy is explicit.
- [ ] Numeric dtype policy is explicit.
- [ ] Boundary failures raise actionable errors close to the Polars adapter.

## Export Boundary

- [ ] `to_jax()` is used only on materialized `DataFrame` objects.
- [ ] `to_jax(dtype=...)` is preferred when one unified export dtype is part of the boundary contract.
- [ ] Polars objects do not cross into JAX-traced or numerical core layers.
- [ ] Exported arrays have deterministic column order and documented semantics.
- [ ] Any eager-only path is justified in code or design notes.
