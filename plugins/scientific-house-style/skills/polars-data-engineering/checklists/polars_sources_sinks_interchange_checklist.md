# Polars Sources / Sinks / Interchange Checklist

Use this checklist when Polars code reads from files, bridges to other table ecosystems, or writes outputs.

## Ingress

- [ ] File-backed lazy workflows use `scan_*` readers when a matching lazy reader exists.
- [ ] Any choice of eager `read_*` over `scan_*` is intentional and justified.
- [ ] Predicate/projection pushdown opportunities are preserved by delaying materialization.
- [ ] If pandas is an input source, `pl.from_pandas(...)` is isolated to an ingress adapter.
- [ ] If Arrow is an input source, `pl.from_arrow(...)` is isolated to an ingress adapter.
- [ ] `schema_overrides=`, `include_index=`, `nan_to_null=`, and `rechunk=` choices are explicit when they matter.

## Interchange

- [ ] Bridges to pandas or Arrow happen only at explicit boundaries.
- [ ] Arrow is preferred over pandas when both the producer and consumer already support Arrow.
- [ ] Copy expectations are explicit; zero-copy is not assumed blindly.
- [ ] Null and dtype semantics across the boundary are documented when they can change.

## Egress

- [ ] `DataFrame.to_jax()` is used only on materialized `DataFrame` objects.
- [ ] `to_jax(dtype=...)` is preferred when unified export dtype is part of the contract.
- [ ] If pandas output is required, `DataFrame.to_pandas(...)` is isolated to egress and `use_pyarrow_extension_array=` is chosen intentionally.
- [ ] If Arrow output is required, `DataFrame.to_arrow()` is isolated to egress and any `compat_level=` choice is explicit.
- [ ] If CSV output is required, `write_csv(..., compression=...)` policy and filename-extension policy are explicit.
- [ ] If a large lazy result is written directly, sink APIs such as `sink_csv(...)` are considered before forcing a full collect.
