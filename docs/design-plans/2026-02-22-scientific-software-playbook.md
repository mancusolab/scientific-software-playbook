# Scientific Software Playbook Design

> Note: This file is a conversational snapshot, not a strict readiness-template example.

## Status
In Review

## Summary
This design defines a plugin-style scaffold for scientific software teams that prefer a command-line entrypoint, a thin orchestration API, and JAX/Equinox numerics kernels. The core contract is strict boundary control: all tabular and domain-specific on-disk scientific formats are parsed at ingress and converted directly into canonical JAX-friendly objects as early as possible. The pipeline layer never accepts raw container formats, and numerics code stays array/PyTree-only with explicit result channels. This structure minimizes duplicate host-side representations, keeps validation failures close to user input, and preserves stable transformation behavior for `jit`, `vmap`, and AD.

## Definition of Done
1. Provide reusable skill definitions and agent definitions that enforce a scientific software architecture with clear layers and contracts.
2. Enforce immediate ingress conversion from tabular and domain-specific scientific formats into canonical JAX/PyTree core objects when feasible.
3. Enforce that pipeline and numerics layers reject raw format containers and only operate on canonical core objects.
4. Require validation-first execution: boundary validation fails before orchestration and numerics execution.
5. Encode reproducibility and structured failure semantics as default rules for public scientific workflows.

## Model Specification Sources
- To be supplied per project: LaTeX files, equation snapshots/images, and inferential-rule documents.

## Mathematical Sanity Checks
- To be completed per project before implementation:
1. Symbol/notation consistency.
2. Objective and inference-rule coherence.
3. Support/domain and shape/dimensional consistency.
4. Identifiability or degeneracy risk notes.
5. Unresolved mathematical questions tracked as explicit risks.

## Solver Strategy Decision
- To be selected per project when explicit update rules are provided:
1. Custom solver updates.
2. Translation to existing solver frameworks (for example Optimistix/Lineax).
3. Comparative evaluation before final choice.

## Solver Translation Feasibility
- To be documented before implementation:
1. Mapping to root-finding/least-squares/minimization APIs where possible.
2. Derivative and constraint compatibility with candidate existing solvers.
3. Rationale when custom solver updates are chosen over existing solver paths.

## Acceptance Criteria
1. No `DataFrame` or domain-format container crosses the ingress boundary.
2. Pipeline entrypoints accept only canonical core objects and reject raw containers via type/contract checks.
3. Every ingress adapter declares and tests copy behavior (`zero-copy`, `mmap`, or `single-copy fallback` with rationale).
4. Validation failures are surfaced before pipeline orchestration and before core numerics execution.
5. Numerics APIs expose structured status/results and remain free of raw I/O and container parsing.
6. CLI behavior is stable and automation-friendly (`stdout/stderr` contract, reproducibility options, deterministic error semantics).

## Glossary
- Canonical core objects: JAX array/PyTree-oriented domain objects accepted by pipeline and numerics code.
- Ingress boundary: the only layer where external files/formats are parsed and converted.
- Single-copy fallback: one documented copy at ingress when zero-copy/mmap cannot be made safe.
- Validation-first pipeline: orchestration layer that performs schema/range/shape checks before numerical routines are called.
