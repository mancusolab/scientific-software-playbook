# Polars Patterns

Detailed rules for lazy file ingress, join contracts, materialization boundaries,
JAX export, pandas/Arrow bridges, compressed CSV output, and functional-core
adapter boundaries.

## Lazy readers and materialization

### Rule: Use `scan_*` readers for lazy file-backed workflows
- Do: Start file-backed lazy pipelines with `scan_csv`, `scan_parquet`, `scan_ipc`, or another matching `scan_*` reader.
- Don’t: Use `read_*().lazy()` when a native `scan_*` reader exists.
- Why: Reader-level optimization and pushdown only help if the lazy plan starts at the reader.
- Example:
```python
import polars as pl

lf = (
    pl.scan_parquet("inputs/*.parquet")
    .filter(pl.col("status") == "ok")
    .select("sample_id", "feature_a", "feature_b", "target")
)
```
- Allowed break: Small inputs that genuinely need an immediate in-memory `DataFrame`.

### Rule: Materialize once near the export boundary
- Do: Keep transformations in `LazyFrame` and `collect()` close to validation or export.
- Don’t: Scatter intermediate materialization through helper layers.
- Why: One explicit materialization boundary is easier to reason about for memory, performance, and debugging.
- Example:
```python
materialized = (
    lf
    .drop_nulls(["feature_a", "feature_b", "target"])
    .sort("sample_id")
    .collect()
)
```
- Allowed break: Debugging sessions or tiny exploratory scripts.

## Join and reconciliation patterns

### Rule: Keep join contracts explicit in code
- Do: State `how=`, `validate=`, `nulls_equal=`, `coalesce=`, and `maintain_order=` intentionally when they matter.
- Don’t: Rely on incidental defaults for join semantics or row order.
- Why: Join configuration defines dataset meaning; silent cardinality or ordering drift is a data bug.
- Example:
```python
aligned = left.join(
    right,
    on="sample_id",
    how="inner",
    validate="1:1",
    nulls_equal=False,
    coalesce=True,
    maintain_order="left",
)
```
- Allowed break: One-off exploratory work where the join is not part of a stable workflow contract.

### Rule: Reconcile all tabular sources before numerics export
- Do: Join on explicit keys, validate expected cardinality, decide null-key handling, and freeze row order before array export.
- Don’t: Convert independent tables separately and assume positional alignment later.
- Why: Provenance and row-matching errors become harder to detect after array conversion.
- Example:
```python
aligned = (
    phenotypes
    .join(covariates, on="sample_id", how="inner", validate="1:1")
    .sort("sample_id")
)
```
- Allowed break: Single-table workflows with no cross-source reconciliation.

## Export to JAX

### Rule: Set dtype at the `to_jax(...)` boundary when possible
- Do: Use `to_jax(dtype=pl.Float32)` or another explicit Polars dtype when one unified export dtype is part of the contract.
- Do: Use `label=` and `features=` when the export boundary should define the supervised-learning split directly.
- Don’t: Add a second downstream cast when `to_jax(dtype=...)` already captures the intended dtype policy.
- Why: Boundary-time dtype selection is clearer than exporting first and coercing later.
- Example:
```python
arrays = materialized.to_jax(
    return_type="dict",
    label="target",
    features=["feature_a", "feature_b"],
    dtype=pl.Float32,
)
```
- Allowed break: Mixed-dtype exports where a single `dtype=` would be incorrect.

### Rule: Keep Polars out of numerics internals
- Do: Convert in adapters, then pass arrays or typed records into the core.
- Don’t: Let `DataFrame` or `LazyFrame` objects cross into JAX-traced functions.
- Why: Traced numerics should receive array-native data structures, not host-side table containers.
- Example:
```python
def load_training_arrays(path: str) -> dict[str, object]:
    df = (
        pl.scan_parquet(path)
        .select("target", "feature_a", "feature_b")
        .collect()
    )
    return df.to_jax(
        return_type="dict",
        label="target",
        features=["feature_a", "feature_b"],
        dtype=pl.Float32,
    )
```
- Allowed break: None for JAX-traced core code.

## Pandas and Arrow bridges

### Rule: Use `from_pandas(...)` only as an explicit ingress bridge
- Do: Isolate `pl.from_pandas(...)` to adapters and set `schema_overrides=`, `nan_to_null=`, and `include_index=` intentionally when needed.
- Don’t: Bounce between pandas and Polars repeatedly inside the same pipeline.
- Why: The bridge is useful, but implicit dtype/null/index semantics make it a poor general-purpose internal representation.
- Example:
```python
polars_df = pl.from_pandas(
    pandas_df.reset_index(),
    include_index=False,
    nan_to_null=True,
    schema_overrides={"target": pl.Float64},
)
```
- Allowed break: None in production pipelines; repeated conversion is usually a design smell.

### Rule: Use `to_pandas(...)` only as an explicit egress bridge
- Do: Keep `to_pandas(...)` at the output boundary and choose `use_pyarrow_extension_array=True` intentionally when null preservation matters.
- Don’t: Convert to pandas casually mid-pipeline.
- Why: Default conversion copies and may change null behavior for numeric data.
- Example:
```python
pandas_df = polars_df.to_pandas(use_pyarrow_extension_array=True)
```
- Allowed break: Downstream tools that only speak pandas.

### Rule: Use Arrow rather than pandas when both sides support it
- Do: Use `pl.from_arrow(...)` and `to_arrow()` for Arrow-native interchange.
- Don’t: Route through pandas if the producer and consumer already support Arrow.
- Why: Arrow preserves columnar semantics better and is often lower-copy than pandas bridging.
- Example:
```python
polars_df = pl.from_arrow(arrow_table, rechunk=True)
arrow_table = polars_df.to_arrow()
```
- Allowed break: Consumers that specifically require pandas objects.

## CSV output and sinks

### Rule: Keep CSV compression explicit
- Do: Set `compression=` and `compression_level=` intentionally and align the file extension with the chosen compression mode.
- Don’t: Write compressed CSV with an ambiguous filename or rely on unspoken defaults.
- Why: Output format is part of the boundary contract with downstream tools.
- Example:
```python
materialized.write_csv(
    "outputs/data.csv.zst",
    compression="zstd",
    compression_level=7,
)
```
- Allowed break: Temporary local scratch output.

### Rule: Use sink-based CSV export for large lazy outputs
- Do: Use `sink_csv(...)` when the result should be streamed directly from a lazy pipeline.
- Don’t: `collect()` a large lazy result just to write it immediately.
- Why: Sink-based export avoids unnecessary materialization for larger-than-RAM or streaming-friendly outputs.
- Example:
```python
lf.sink_csv(
    "outputs/data.csv.gz",
    compression="gzip",
    compression_level=6,
)
```
- Allowed break: Small outputs where materialization is already required for validation or reuse.
