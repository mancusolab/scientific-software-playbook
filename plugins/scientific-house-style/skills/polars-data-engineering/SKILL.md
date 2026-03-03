---
name: polars-data-engineering
description: Use for Polars DataFrame and LazyFrame workflows; enforces lazy-first query design, explicit materialization boundaries, deterministic joins, and correct conversion to NumPy/JAX arrays.
metadata:
  short-description: Polars data engineering
---

# Polars Data Engineering

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

Guidance for engineering workflows that use Polars `DataFrame` and `LazyFrame`,
especially when tabular preparation feeds JAX or other numerical code.

This file is the entrypoint. Keep it lightweight and load focused companions only
when they apply.

## Scope boundary (authoritative split)

This skill is authoritative for Polars tabular workflow semantics:
- `LazyFrame` vs `DataFrame` boundary decisions
- query planning, materialization, and collection boundaries
- deterministic join/reconciliation rules before downstream numerics
- column selection, row-order freezing, and null-handling at tabular boundaries
- `DataFrame.to_jax()` as an adapter boundary

This skill is not the source of truth for:
- JAX tracing, PyTree, or numerics-runtime semantics
- public API lifecycle, CLI contracts, or packaging policy
- general functional-core layering outside Polars-specific adapters

For those concerns use:
- `../jax-equinox-numerics/SKILL.md`
- `../jax-project-engineering/SKILL.md`
- `../howto-functional-vs-imperative/SKILL.md`

## Path Contract (Unambiguous)

1. All relative paths in this file resolve from this skill directory (the directory containing this `SKILL.md`).
2. Companion checklist paths are installation-local paths relative to this directory.

## Companion checklists

Apply these checklists when using this skill.

### Installation-local paths (relative to this `SKILL.md`)
- `checklists/polars_lazyframe_boundary_checklist.md`
- `checklists/polars_sources_sinks_interchange_checklist.md`

## Checklist workflow
- Before implementation: open the relevant checklist(s) and scope the work against them.
- During implementation: keep lazy/eager boundaries, reconciliation, and interchange policy aligned with the chosen checklist(s).
- Before completion: re-run the checklist(s) and explicitly document any intentionally unchecked item.

## Definitions (strict)
- Lazy query: a `pl.LazyFrame` expression graph that has not been materialized.
- Materialization boundary: the point where a lazy plan is executed with `collect()` or equivalent sink.
- Tabular adapter: code that loads, validates, reconciles, and converts Polars objects for downstream consumers.
- Row-order freeze: the explicit point where row order becomes part of the downstream contract.
- JAX adapter boundary: conversion from a materialized `DataFrame` into JAX-ready arrays via `to_jax()` and/or `jnp.asarray(...)`.

## Core defaults

### Rule: Use lazy query construction for multi-step data preparation
- Do: Start with `LazyFrame` when filtering, selecting, joining, aggregating, or deriving columns across multiple steps.
- Do: Keep transformations in the lazy plan until you reach a clear boundary that needs concrete values.
- Don’t: Materialize intermediate `DataFrame`s after every operation out of habit.
- Why: Polars can optimize the lazy plan before execution, which reduces unnecessary work and centralizes the dataflow contract.

### Rule: Materialize once at explicit boundaries
- Do: Call `collect()` only when a consumer actually needs materialized data.
- Do: Name the boundary clearly in code and keep materialization near validation or downstream conversion.
- Don’t: Scatter hidden `collect()` calls through helper layers.
- Why: Hidden eager transitions make memory use, execution timing, and failure surfaces hard to reason about.

### Rule: Use `scan_*` readers for file-backed lazy workflows
- Do: Start file-backed lazy pipelines with `scan_csv`, `scan_parquet`, `scan_ipc`, or another `scan_*` reader when the workflow will filter, select, join, or aggregate before materialization.
- Do: Use scan-based ingress when predicate pushdown, projection pushdown, or streaming execution can reduce IO and memory pressure.
- Do: Use eager `read_*` readers only when you truly need an in-memory `DataFrame` immediately.
- Don’t: `read_*().lazy()` by default when a matching `scan_*` reader exists.
- Don’t: give up reader-level optimization by materializing the file before the lazy plan is even formed.
- Why: The Polars user guide explicitly recommends favoring `scan_*` over `read_*` for `LazyFrame` pipelines because the optimizer can push work into the reader and support streaming execution.

### Rule: Treat `pl.from_pandas(...)` as an explicit ingress bridge
- Do: Use `pl.from_pandas(...)` only at clear adapter boundaries when data genuinely originates in pandas.
- Do: Use direct Polars-native readers or producers when you control the upstream path.
- Do: Set `schema_overrides=`, `nan_to_null=`, and `include_index=` intentionally when those semantics matter.
- Do: Reset the pandas index first if row identifiers must become explicit columns and the index would otherwise be implicit.
- Don’t: shuttle data back and forth between pandas and Polars as a routine pipeline pattern.
- Don’t: assume this is a zero-copy conversion.
- Why: The official Polars docs describe `from_pandas` as a pandas bridge that may clone data; leaving dtype, null, and index semantics implicit creates avoidable boundary ambiguity.
- Note: As of March 3, 2026, the stable Polars docs list `schema_overrides`, `rechunk`, `nan_to_null`, and `include_index` on `polars.from_pandas`, and note that the conversion requires both `pandas` and `pyarrow`.

### Rule: Treat `DataFrame.to_pandas(...)` as an explicit egress bridge
- Do: Use `DataFrame.to_pandas(...)` only at a clear output boundary when a downstream consumer specifically requires pandas.
- Do: Stay in Polars when the next step can consume Polars directly.
- Do: Set `use_pyarrow_extension_array=True` intentionally when null preservation and reduced copying matter.
- Do: Pass through only the `pyarrow.Table.to_pandas()` keyword arguments you actually need, and document any non-default behavior that changes downstream dtype semantics.
- Don’t: convert to pandas casually in the middle of a Polars pipeline.
- Don’t: assume `to_pandas()` is zero-copy by default.
- Why: The official Polars docs state that `to_pandas()` copies unless `use_pyarrow_extension_array=True`, and default conversion can turn numeric nulls into `NaN`.
- Note: As of March 3, 2026, the stable Polars docs list `use_pyarrow_extension_array` plus passthrough `**kwargs`, and note that `pandas` and `pyarrow` must both be installed.

### Rule: `to_jax()` belongs on materialized `DataFrame` adapters
- Do: Treat `DataFrame.to_jax()` as a boundary adapter from tabular preparation into array-based numerics.
- Do: Build the query lazily first, then `collect()`, then convert.
- Do: Use `df.to_jax(dtype=pl.Float32)` or another explicit Polars dtype when one unified exported dtype is part of the adapter contract.
- Do: Use `label=` and `features=` selectors when feature/label boundaries should be expressed directly in the export call.
- Don’t: Design around a `LazyFrame.to_jax()` path.
- Don’t: add a separate downstream cast such as `jnp.asarray(df.to_jax(), dtype=...)` when `to_jax(dtype=...)` already expresses the intended boundary dtype.
- Don’t: Pass Polars objects into JAX-traced internals.
- Why: Official Polars docs expose `to_jax()` on `DataFrame`, not `LazyFrame`, and include a `dtype` parameter that sets export dtype at conversion time. That is a clearer boundary contract than a second coercion step downstream.
- Note: As of March 3, 2026, the stable docs list `return_type`, `device`, `label`, `features`, `dtype`, and `order` on `DataFrame.to_jax()`. Polars marks this API as unstable.

### Rule: Treat Arrow as the interchange bridge when a downstream consumer already speaks Arrow
- Do: Use `pl.from_arrow(...)` at ingress when upstream data is already in `pyarrow.Table`, `RecordBatch`, `Array`, or `ChunkedArray` form.
- Do: Use `DataFrame.to_arrow()` at egress when the next system can consume Arrow directly.
- Do: Use Arrow rather than pandas as the interchange layer when you want to preserve columnar semantics and minimize copying.
- Do: Set `schema_overrides=` and `rechunk=` intentionally on `pl.from_arrow(...)` when schema control or contiguous memory matters.
- Do: Set `compat_level=` intentionally on `DataFrame.to_arrow()` when compatibility requirements for the consumer are known.
- Don’t: assume Arrow interchange is universally zero-copy for every dtype.
- Don’t: route through pandas first if the producer and consumer already support Arrow.
- Why: The official Polars docs describe `pl.from_arrow(...)` as zero-copy for the most part and `DataFrame.to_arrow()` as mostly zero-copy, which makes Arrow the cleanest bridge when both sides understand it.
- Note: As of March 3, 2026, the stable docs say `pl.from_arrow(...)` is zero-copy for the most part and may cast unsupported types to the closest supported type. The stable `DataFrame.to_arrow()` docs say the export is mostly zero-copy and call out `CategoricalType` as a copying case.

### Rule: Reconcile tabular sources by explicit keys before array conversion
- Do: Join independently loaded tables by explicit entity keys before conversion.
- Do: Document join type, duplicate-key handling, missing-key handling, overlap expectations, and dropped-row accounting.
- Do: Freeze row order after reconciliation and before `to_jax()`.
- Don’t: Assume independent sources are positionally aligned.
- Why: Array conversion hides provenance; reconciliation bugs become much harder to detect after the tabular boundary.

### Rule: Make join contracts explicit
- Do: Choose `how=` intentionally and document why the workflow needs `inner`, `left`, `full`, `semi`, `anti`, or `cross`.
- Do: Use `validate=` when cardinality is part of the contract (`1:1`, `1:m`, `m:1`) instead of silently accepting `m:m`.
- Do: Set `nulls_equal=` intentionally; never leave null-key matching behavior implicit.
- Do: Set `coalesce=` intentionally when overlapping join keys or duplicate-name handling matters.
- Do: Set `maintain_order=` when downstream logic depends on deterministic row order.
- Don’t: rely on observed default join ordering or incidental duplicate-column behavior.
- Why: Join semantics define dataset meaning. Hidden cardinality expansion, null-key surprises, and unstable row order are high-impact data bugs.
- Note: Current Polars stable docs expose `validate`, `nulls_equal`, `coalesce`, and `maintain_order` on `DataFrame.join` and `LazyFrame.join`; the docs also warn not to rely on ordering without explicitly setting `maintain_order`.

### Rule: Make feature/label splits explicit
- Do: Define which columns are features, labels, identifiers, weights, or metadata before conversion.
- Do: Use a stable column order for feature matrices and document it as part of the contract.
- Don’t: Let incidental schema order determine model input layout unless that order is explicitly frozen and tested.
- Why: JAX and NumPy consumers depend on deterministic shape and column semantics.

### Rule: Normalize null and dtype policy before export
- Do: Decide how nulls are handled before `collect()` or before `to_jax()`: reject, fill, or split them into explicit masks.
- Do: Normalize numeric dtypes intentionally before array export.
- Don’t: Rely on implicit downstream coercion to clean up tabular ambiguity.
- Why: Null and dtype surprises at the adapter boundary usually turn into harder-to-debug numerical failures later.

### Rule: Keep Polars in adapters, not in core domain code
- Do: Isolate Polars-specific loading, joins, sorting, and schema checks in imperative shell adapters.
- Do: Pass canonical arrays, typed records, or small immutable config objects into the functional core.
- Don’t: Thread `DataFrame` or `LazyFrame` objects through unrelated business logic.
- Why: This keeps core logic easier to test and prevents data-engine choices from leaking across the system.

### Rule: Validate schemas and assumptions before conversion
- Do: Validate required columns, uniqueness assumptions, expected row counts, and key coverage before exporting arrays.
- Do: Fail with actionable boundary errors when schema or reconciliation assumptions are violated.
- Don’t: Depend on late shape errors from numerical code to reveal tabular mistakes.
- Why: Boundary validation preserves the debugging context that numerical layers do not have.

### Rule: Keep eager Polars usage intentional
- Do: Use eager `DataFrame` workflows when the dataset is already materialized, the operation is local and simple, or the consumer requires immediate values.
- Do: State why eager mode is acceptable when bypassing lazy planning.
- Don’t: treat eager mode as the default for multi-stage pipeline code.
- Why: Eager mode is valid, but the choice should be deliberate rather than accidental.

### Rule: Make CSV egress compression-aware
- Do: Use `DataFrame.write_csv(..., compression=...)` intentionally when CSV export needs compressed output.
- Do: Keep filename extensions aligned with the chosen compression mode when writing to a path.
- Do: Treat `compression`, `compression_level`, and extension checks as boundary policy, not incidental call-site details.
- Don’t: assume uncompressed `.csv` is the only supported CSV egress path.
- Why: Current Polars stable docs support CSV compression on `write_csv`, and explicit policy avoids mismatched filenames and ambiguous downstream expectations.
- Note: As of March 3, 2026, the official stable docs list `compression='uncompressed'|'gzip'|'zstd'` for `DataFrame.write_csv`, along with `compression_level` and `check_extension`. Polars marks this functionality as unstable in the API docs.

### Rule: Use streaming CSV sinks for larger-than-RAM lazy exports
- Do: Consider `LazyFrame.sink_csv(..., compression=...)` when the result should be written directly from a lazy pipeline and full materialization is unnecessary or risky.
- Do: Keep sink-based export in the egress layer and treat it as an output boundary, not as reusable domain logic.
- Don’t: collect a large lazy result just to write CSV if a native sink matches the workflow.
- Why: Polars provides a native lazy CSV sink specifically for streaming output larger than RAM.
- Note: As of March 3, 2026, Polars documents `LazyFrame.sink_csv(..., compression=..., compression_level=..., check_extension=...)` and marks the sink API unstable.

## Pressure-test scenarios (for `testing-skills-with-subagents`)

Use these prompts to harden lazy-boundary and adapter-boundary compliance:

1. Lazy-vs-eager pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

You need to clean, join, and aggregate three parquet-backed tables before
feeding the result into a model training step.

Options:
A) Read each table eagerly, mutate step by step, and materialize after every join.
B) Build one lazy query pipeline, validate at the adapter boundary, then collect once near export.
C) Mix lazy and eager opportunistically with no stated boundary.

Choose A, B, or C.
```

2. `to_jax()` pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

A teammate wants to call `to_jax()` "somewhere later" after data prep already
crossed into numerics code.

Options:
A) Let Polars objects cross the numerics boundary and convert when convenient.
B) Keep Polars in the adapter layer, collect to `DataFrame`, then convert once at the boundary.
C) Skip `to_jax()` and rely on implicit downstream coercion.

Choose A, B, or C.
```

## Reference map (load on demand)

Load only the files relevant to your task.

- `checklists/polars_lazyframe_boundary_checklist.md`
  Covers lazy/eager boundary choice, reconciliation rules, schema validation,
  and export-to-array checks.

- `checklists/polars_sources_sinks_interchange_checklist.md`
  Covers `scan_*` vs `read_*` ingress choice, pandas/Arrow bridges, and sink/export boundaries.

- `references/polars_patterns.md`
  Concrete examples for lazy readers, joins, `to_jax(dtype=...)`, Arrow/pandas bridges,
  and compressed CSV/sink export.

## Working notes

- For version-sensitive Polars API details, use primary Polars documentation and `scientific-internet-research-pass` when current syntax or behavior needs confirmation.
- When JAX conversion or traced numerics are in scope, pair this skill with `jax-equinox-numerics`.
