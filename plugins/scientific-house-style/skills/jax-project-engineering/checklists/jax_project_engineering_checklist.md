# Project Engineering Checklist

Use this for general software engineering hygiene around numerical/JAX projects.

## API stability
- [ ] Public API signatures and return structures are stable and documented.
- [ ] Core numerics/solver APIs use one explicit failure contract per surface (status-channel or exception-first), documented and tested.
- [ ] User/product-facing APIs translate internal solver containers to domain-specific outputs when solver internals are not needed.
- [ ] Solver APIs prefer mature Lineax/Optimistix entry points before introducing bespoke solver kernels.
- [ ] If `RESULTS` enums are part of public API, members have actionable messages and compatibility is preserved across deprecation windows.
- [ ] Any breaking change includes a deprecation period or migration guide.
- [ ] Error semantics are consistent and tested for the chosen contract.
- [ ] `throw=True`/`result.error_if` escalation paths are explicit when used.
- [ ] Each workflow exposes one canonical entrypoint; special cases are expressed by config/options instead of new one-off APIs.
- [ ] Wrapper functions add contract value (validation/normalization/compatibility/instrumentation), not trivial pass-through layers.
- [ ] Boundary layers raise validation exceptions early; JITable kernels avoid Python `raise`.

## Documentation
- [ ] Public APIs and Modules have docstrings.
- [ ] Docstring format is consistent with repo style (e.g., `**Arguments:**` / `**Returns:**`).
- [ ] Determinism limits and failure modes are documented.
- [ ] `throw` behavior is documented for batching (`vmap`) and backend-specific runtime error caveats where relevant.
- [ ] Examples cover common usage patterns and failure modes.

## Dependencies
- [ ] Project metadata and tool configuration are centralized in `pyproject.toml` unless there is a documented exception.
- [ ] Core dependency constraints include minimum versions and explicit exclusions for known-bad releases when needed.

## CI / Quality gates
- [ ] Format/lint/typecheck/tests run in CI.
- [ ] New features include tests (including JIT/AD/vmap where relevant).
- [ ] Bug fixes include regression tests.

## Reproducibility
- [ ] PRNGKeys are explicit and deterministic in tests/examples.
- [ ] Device/backend nondeterminism is documented if it affects results.

## Serialization / checkpoints
- [ ] Persisted state is versioned.
- [ ] Load paths validate version compatibility or provide migration notes.

## CLI
- [ ] CLI architecture matches declared profile (`compact-workflow` may include glue; `modular-domain` keeps orchestration separated) and avoids import-time side effects.
- [ ] CLI exposes reproducibility controls where relevant (seed/dtype/device and version reporting).
- [ ] Multi-workflow CLIs use subcommand handler binding (`set_defaults(func=...)`) and a single `args.func(args)` dispatch.

## Logging / diagnostics
- [ ] Diagnostic output is gated behind flags.
- [ ] Diagnostics use logging/callbacks rather than ad-hoc `print(...)`.
- [ ] No `print` in traced/JIT paths; use `jax.debug.print` sparingly.
- [ ] Machine-readable CLI output remains isolated to the documented stdout/stderr contract.
