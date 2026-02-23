---
name: validation-first-pipeline-api
description: Use when implementing orchestration APIs for scientific workflows - requires upfront validation on canonical core objects and rejects raw source containers.
---

# Validation-First Pipeline API

This skill structures task-level APIs such as `fit`, `infer`, and `simulate`.

## Input Contract

Required inputs:
1. Canonical request/response object definitions.
2. Validation invariants (type, shape, range, cross-field checks).
3. Numerics entrypoint contract.

## Output Contract

Required outputs:
1. Pipeline entrypoint signatures that accept canonical objects only.
2. Validation order definition and failure semantics.
3. Tests for rejection path + successful dispatch path.

## Pipeline Rules

1. Accept canonical core objects only.
2. Reject raw container formats at the type/contract boundary.
3. Validate before dispatch to numerics.
4. Keep orchestration thin and side-effect-aware.
5. Return structured status/results for reliable automation and CLI integration.
6. Keep one canonical entrypoint per workflow (`fit`, `infer`, `simulate`) and express variants via typed options.
7. Avoid pass-through wrappers that duplicate pipeline surface without adding validation or compatibility value.

## Do/Don't Examples

1. API shape
- Do: `infer(request: CanonicalInferenceRequest) -> InferenceResult`.
- Don't: `infer(df: DataFrame)` or `infer(path: str)` as core pipeline APIs.

2. Validation location
- Do: reject bad ranges, shapes, and enum values before numerics dispatch.
- Don't: rely on deep numerics exceptions for user-facing validation failures.

3. Data ownership
- Do: consume canonical objects produced by ingress.
- Don't: parse files or rehydrate domain-format containers in pipeline orchestration.

## Validation Order

1. Type contract checks (canonical object types).
2. Shape and dimensionality checks.
3. Value/range checks.
4. Cross-field/domain consistency checks.
5. Numerics dispatch only after all checks pass.

## TDD and Regression Requirements

1. For new pipeline behavior, write failing tests first (boundary rejection + successful canonical path).
2. For bug fixes, add a regression test that fails before the fix.
3. Keep orchestration changes minimal until tests pass.
4. Run targeted and integration test scopes before completion claims.

## Anti-Pattern Checks

Reject the design if any are true:
1. Pipeline reparses files or domain-specific source formats.
2. Pipeline reconstructs host-side container duplicates for convenience.
3. Validation failures surface from deep numerics internals instead of boundary layers.
4. Pipeline surface adds one-off workflow variants that bypass canonical request types.

## Hard Stops

1. If pipeline accepts raw file/container input, block merge/approval.
2. If validation can be skipped before numerics dispatch, block merge/approval.
3. If pipeline lacks explicit structured status/result semantics for downstream CLI/reporting, block merge/approval.
