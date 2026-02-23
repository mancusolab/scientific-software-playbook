---
name: ingress-to-canonical-jax
description: Use when implementing file/data ingestion for scientific software - converts tabular and domain-specific formats directly into canonical JAX/PyTree objects with explicit copy policy.
---

# Ingress To Canonical JAX

This skill enforces immediate conversion at ingress and blocks raw containers from entering pipeline code.

## Path Contract (Unambiguous)

1. This skill has no installation-local playbook file dependencies.
2. Any file paths discussed here are user/data input paths handled by ingress adapters, not plugin asset paths.

## Input Contract

Required inputs:
1. Source format description (tabular or domain-specific).
2. Canonical output object schema expected by pipeline.
3. Copy-mode expectation (`zero-copy`, `mmap`, or `single-copy fallback`).

## Output Contract

Required outputs:
1. Adapter contract with declared copy mode and validation checks.
2. Tests proving conversion correctness and boundary rejection.
3. Explicit statement that raw source containers do not cross ingress.

## Ingress Rules

1. Parse external format at ingress only.
2. Convert parsed values to canonical JAX/PyTree objects immediately when feasible.
3. Prefer `zero-copy` or `mmap` paths where safe.
4. If copying is required, allow one boundary copy only and document why.
5. Do not keep long-lived duplicate representations (container + array) after conversion.

## Do/Don't Examples

1. Tabular ingress
- Do: convert `DataFrame` columns to canonical arrays at ingress and drop the source container from downstream flow.
- Don't: forward `DataFrame` values into pipeline/numerics and convert later.

2. Domain-specific scientific formats
- Do: parse genomics or instrument-native on-disk formats directly into canonical JAX-oriented objects when feasible.
- Don't: wrap domain records in intermediate host-side containers that persist past ingress.

3. Copy policy
- Do: use memory-mapped or zero-copy paths when safe and stable for downstream compute.
- Don't: duplicate full datasets during parse and then duplicate again during pipeline normalization.

## Adapter Contract

Each adapter should declare:
- Format name.
- Canonical output object type.
- Copy mode (`zero-copy`, `mmap`, `single-copy fallback`).
- Validation checks performed before output.

## Validation Minimum

1. Required fields/columns.
2. Dtype compatibility and normalization.
3. Shape/index alignment and constraints.
4. Domain invariants needed for downstream numerics.

## TDD Requirements

1. Write failing tests first for:
- Container rejection at pipeline boundary.
- Adapter conversion correctness.
- Copy-mode contract behavior (`zero-copy`, `mmap`, or `single-copy fallback`).

2. Implement minimal adapter changes to pass tests.

3. Re-run full relevant test scope before claiming completion.

## Exit Condition

The adapter is complete only when:
1. Pipeline can operate without any knowledge of source format internals.
2. Tests verify copy behavior and rejection of malformed source data.

## Hard Stops

1. If adapter forwards raw containers to pipeline/numerics, stop and redesign boundary.
2. If copy mode is undefined or untested, do not mark adapter complete.
