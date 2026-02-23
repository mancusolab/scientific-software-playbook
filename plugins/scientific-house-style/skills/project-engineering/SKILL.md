---
name: project-engineering
description: Engineering rules for JAX/Equinox scientific computing; API stability, docs, CI, serialization.
metadata:
  short-description: Project engineering
---

# Project Engineering (JAX/Equinox Scientific Computing)

Guidance for software engineering practices around numerical/JAX codebases.
In this plugin, prefer the vendored local paths under `skills/project-engineering/`.

## Companion checklists

Apply these checklists when using this skill.

### Repo-local paths
- `checklists/project_engineering_checklist.md`
- `checklists/testing_checklist.md`

## Checklist workflow
- Before implementation: open the relevant companion checklist(s) and scope the work against them.
- During implementation: keep checklist items aligned with code/design decisions.
- Before completion: re-run the checklist and explicitly document any intentionally unchecked item.

## Companion snippets

Use these snippets as implementation starters when they match the task.

### Repo-local paths
- `snippets/cli_skeleton.py`
- `snippets/pyproject_minimal.toml`
- `snippets/test_jvp_finite_difference.py`

## Snippet workflow
- Before implementation: start from the closest snippet and align it with repository conventions.
- During implementation: keep public API shape, docs style, and error semantics consistent with this skill.
- Before completion: remove placeholders and verify snippet-derived code is fully integrated.

## Public API stability

### Rule: Keep API structure stable and explicit
- Do: Preserve return shapes/fields and document result codes/statuses.
- Don’t: Change return structures or error semantics without deprecation.
- Why: Scientific workflows rely on stable interfaces.
- Example:
```python
# Return a structured result: value + result + stats/state
return Solution(value=out, result=result, stats=stats, state=state)
```
- Allowed break: Major version bump with migration guide.

### Rule: Use structured results with a `RESULTS` enum and `Solution` container in core numerics APIs
- Do: Define a `RESULTS` enum with human-readable messages and return a typed `Solution` from solver/core numerics entrypoints.
- Do: Translate `Solution` into domain-specific outputs at user/product boundaries (for example CLI summaries or workflow-specific return objects).
- Don’t: Expose `Solution` as the default UX for non-numerics public helpers that do not need solver-style status channels.
- Why: Core numerics need deterministic failure channels, while user-facing surfaces should stay task-oriented.
- Example:
```python
class RESULTS(eqxi.Enumeration):
    successful = ""
    max_steps_reached = "The maximum number of steps was reached."

class Solution(eqx.Module):
    value: PyTree[Array]
    result: RESULTS
    stats: dict[str, PyTree[ArrayLike]]
    state: PyTree[Any]
```
- Allowed break: Tiny internal helpers that are not part of the public API.

### Rule: Keep one canonical entrypoint per workflow
- Do: Route each workflow through one stable entrypoint and express variants through typed options/config.
- Don’t: Add one-off public functions for special cases that should be flags or config on the canonical entrypoint.
- Why: Extra entrypoints fragment behavior, docs, and compatibility guarantees.

### Rule: Avoid trivial pass-through wrappers
- Do: Add wrappers only when they add contract value (validation, normalization, compatibility, instrumentation, caching, or deprecation shims).
- Don’t: Add one-line wrappers around core functionality with unchanged semantics.
- Why: Thin wrappers increase API surface and maintenance cost without improving behavior.

### Rule: Treat `RESULTS` messages as the canonical error UX
- Do: Write actionable, user-facing messages on each non-success result.
- Don’t: Leave messages empty or force users to decode numeric codes.
- Why: Users rely on `RESULTS[...]` for guidance without digging into code.

### Rule: Prefer composition over subclassing for concrete Modules
- Do: Wrap and delegate when customizing behavior.
- Don’t: Subclass or override concrete modules.
- Why: Aligns with Equinox abstract‑or‑final pattern and avoids override ambiguity.

### Rule: Prefer Lineax/Optimistix primitives over bespoke solver kernels
- Do: Build linear/nonlinear solver APIs on top of `lineax.linear_solve` and `optimistix` entry points (`root_find`, `least_squares`, `minimise`) when they fit.
- Don’t: Reimplement generic solver loops unless introducing a genuinely new algorithm.
- Why: Reuses mature result semantics (`Solution`, `RESULTS`, `throw`) and reduces maintenance risk.

## Documentation

### Rule: Match repository docstring style
- Do: Use markdown sections like `**Arguments:**` / `**Returns:**` when the repo uses that style.
- Don’t: Mix multiple docstring styles in the same module.
- Why: Consistency improves usability and tooling.
- Example:
```python
def solve(...):
    """**Arguments:**
    - `x`: input

    **Returns:**
    - solution
    """
```
- Allowed break: Internal‑only helpers.

### Rule: Document determinism and failure modes
- Do: Explain nondeterminism across devices/backends and list expected failure results.
- Don’t: Leave runtime behavior implicit.
- Why: Reproducibility depends on clear constraints.

### Rule: Document `throw` behavior across transforms and backends
- Do: Document how `throw=True` behaves under batching (`vmap`) and any backend caveats for runtime errors.
- Don’t: Assume identical exception behavior on CPU/GPU/TPU or per-batch isolation.
- Why: Error propagation can differ by backend, and `vmap` can fail the whole batch.

### Rule: Preserve enum compatibility with deprecations
- Do: Keep deprecated `RESULTS` members with warnings on access and a removal plan; prefer compatibility aliases over silent removal.
- Do: Extend enums compatibly (e.g., subclassing and promotion) when adding domain-specific result codes.
- Don’t: Remove or rename enum members without a deprecation window.
- Why: Result enums are part of the public API contract.

### Rule: [Local policy] Keep companion assets co-located with this vendored skill
- Do: Use local checklists/snippets in `skills/project-engineering/checklists/` and `skills/project-engineering/snippets/`.
- Don’t: Add references to external-only asset paths when editing this plugin.
- Why: Users can apply this project directly even without separately installed global skills.
- Note: If this skill is exported elsewhere, package companion checklists/snippets alongside it.

## pyproject.toml (project configuration)

### Rule: Centralize project metadata and tooling in `pyproject.toml`
- Do: Declare Python version, dependencies, optional extras, and tool configs in one place.
- Don’t: Scatter configuration across multiple files without justification.
- Why: Single source of truth reduces drift.
- Example (minimal structure):
```toml
[project]
name = "my-lib"
requires-python = ">=3.10"

[project.optional-dependencies]
test = ["pytest", "pytest-xdist"]

[tool.ruff]
line-length = 88

[tool.pyright]
typeCheckingMode = "strict"
```
- Allowed break: Legacy repos that already standardize on separate config files.

### Rule: Pin minimum versions for core scientific deps
- Do: Set lower bounds for JAX/Equinox/jaxtyping and note compatibility.
- Do: Add explicit exclusions for known-bad versions when needed (e.g., `jax>=...,!=x.y.z`).
- Don’t: Allow unconstrained upgrades that silently change semantics.
- Why: Numerical stability and API behavior change across versions.

## Type checking

### Rule: Enforce type checks in CI
- Do: Use pyright/mypy and keep annotations on public APIs.
- Don’t: Ship untyped public functions or ignore type checker errors.
- Why: Prevents misuse of PyTrees, shapes, and configs.
- Example:
```python
from jaxtyping import Array, PyTree

def f(x: PyTree[Array]) -> PyTree[Array]:
    ...
```
- Allowed break: Small private helpers where typing adds no value.

### Rule: Model solver state with generics when it varies
- Do: Use `TypeVar`/`Generic` in ABCs for solver state.
- Don’t: Use `Any` for state in public interfaces.

## CLI building

### Rule: Keep CLI thin and side‑effect free
- Do: Parse args in `main()`, call into library functions, and return exit codes.
- Don’t: Execute JAX code at import time or use global state.
- Why: Keeps CLI deterministic and testable.
- Example:
```python
import argparse

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args(argv)
    return run(seed=args.seed)

if __name__ == "__main__":
    raise SystemExit(main())
```
- Allowed break: Tiny scripts not shipped as part of the library.

### Rule: Validate early at boundaries; keep JITable kernels exception-free
- Do: Validate ranges, enums, shape contracts, and file/path assumptions at boundary layers (CLI/public adapters) and raise actionable exceptions there.
- Do: Inside traced numerics, use structured status channels (`RESULTS`, `throw` + `result.error_if`, `eqx.error_if`) instead of Python `raise`.
- Don’t: Defer basic user-input validation to deep solver internals or raise Python exceptions inside JIT-compiled loops.
- Why: Boundary failures should be immediate and clear; traced kernels require JAX-compatible error signaling.

### Rule: Validate and normalize boundary inputs in `main()`
- Do: Validate numeric ranges, enum-like flags (`dtype`, `device`), and path existence before calling numerics code.
- Don’t: Let deep solver code surface basic user input errors.
- Why: CLI is an external boundary; fail fast with actionable messages.
- Example:
```python
def main(argv=None):
    ...
    args = parser.parse_args(argv)
    if args.max_steps < 1:
        parser.error("--max-steps must be >= 1")
    return run(...)
```
- Allowed break: Internal scripts where all inputs are controlled by trusted code.

### Rule: Define stable stdout/stderr and exit-code contracts
- Do: Reserve `stdout` for primary results (plain text or `--json`) and route diagnostics/errors to `stderr`.
- Do: Document exit-code semantics (for example: `0` success, `2` usage errors, `1` runtime/result failures).
- Don’t: Mix logs with machine-readable output or rely on Python tracebacks as user-facing error UX.
- Why: Scientific CLIs are often used in automation and shell pipelines.
- Example:
```python
import json
import sys

if sol.result == RESULTS.successful:
    sys.stdout.write(json.dumps({"value": sol.value}) + "\n")
    return 0
sys.stderr.write(f"error: {RESULTS[sol.result]}\n")
return 1
```
- Allowed break: Purely interactive demos not intended for scripting.

### Rule: Route diagnostics through logging/callbacks, not ad-hoc prints
- Do: Use structured logging and callback hooks for progress/diagnostics.
- Do: Keep CLI-facing result/error emission aligned with the documented stdout/stderr contract.
- Don’t: Use ad-hoc `print(...)` for diagnostics in library or CLI paths.
- Why: Logging/callbacks are testable, filterable, and do not corrupt machine-readable output.

### Rule: Make CLI outputs reproducible
- Do: Expose seed/dtype/device flags, report package versions, and make the effective config inspectable.
- Don’t: Hide randomness/backend choices or silently coerce dtype/device without visibility.

### Rule: Keep configuration precedence explicit
- Do: Define and document precedence (`defaults < config file < env vars < CLI flags`).
- Don’t: Merge config sources implicitly or mutate process-global environment from command handlers.
- Why: Deterministic config resolution is required for reproducible experiments.
- Allowed break: Single-file tools with no config/env integration.

### Rule: Prefer subcommands for distinct workflows
- Do: Use subcommands (`solve`, `benchmark`, `check`) for distinct actions and keep each handler small.
- Subrule: Use `argparse` argument groups inside each subcommand to cluster related options (for example: reproducibility, solver controls, output formatting).
- Subrule: Bind each subcommand with `set_defaults(func=...)` and dispatch once via `args.func(args)`.
- Don’t: Put unrelated workflows behind one command with large flag matrices.
- Why: Improves discoverability and avoids invalid flag combinations.
- Example:
```python
sub = parser.add_subparsers(dest="cmd", required=True)
solve = sub.add_parser("solve")
solve.set_defaults(func=run_solve)
bench = sub.add_parser("benchmark")
bench.set_defaults(func=run_benchmark)
repro = solve.add_argument_group("Reproducibility")
repro.add_argument("--seed", type=int, default=0)
args = parser.parse_args(argv)
return args.func(args)
```
- Allowed break: Single-purpose commands with one stable action.

### Rule: Test CLI contracts directly
- Do: Add tests for parse failures, `--help`, stdout/stderr separation, and exit-code mapping for success/failure paths.
- Don’t: Assume library-level tests alone cover CLI behavior.
- Why: CLI regressions are usually contract regressions, not numerical regressions.

## CI / Quality gates

### Rule: Enforce formatting, linting, type checks, and tests
- Do: Run format/lint/typecheck/tests in CI.
- Don’t: Merge changes with failing checks.
- Why: Numerical regressions are subtle and expensive.

### Rule: Add regression tests for bug fixes
- Do: Write a failing test first, then fix.
- Don’t: Merge fixes without test coverage.

## Pressure-test scenarios (for `testing-skills-with-subagents`)

Use these prompts to validate compliance under pressure:

1. Logging vs `print`
```markdown
IMPORTANT: This is a real scenario. Choose and act.

Production logs are noisy. A teammate asks for a quick `print("step", i)` in solver code
to debug a flaky issue before today's release.

Options:
A) Add `print(...)` in the solver loop.
B) Add structured logging/callback diagnostics at boundaries and keep traced kernels print-free.
C) Add `print(...)` now and remove it later.

Choose A, B, or C.
```

2. Subcommand dispatch contract
```markdown
IMPORTANT: This is a real scenario. Choose and act.

You are adding `benchmark` and `check` subcommands. A reviewer says direct `if args.cmd == ...`
branches are faster to write than per-command handlers.

Options:
A) Keep one large `if/elif` dispatch block.
B) Bind handlers with `set_defaults(func=...)` and dispatch with `args.func(args)`.
C) Mix both patterns for now.

Choose A, B, or C.
```

3. One-off API surface pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

A stakeholder requests `solve_fast_for_team_x()` with slightly different defaults.
Release is in 2 hours.

Options:
A) Add the one-off public function.
B) Extend the canonical entrypoint with explicit options/config and keep a single workflow entrypoint.
C) Add one-off now and deprecate later.

Choose A, B, or C.
```

4. Boundary validation vs traced exceptions
```markdown
IMPORTANT: This is a real scenario. Choose and act.

Invalid `max_steps` sometimes reaches a jitted solver. A teammate suggests raising
`ValueError` from inside the traced step function for simplicity.

Options:
A) Raise Python exceptions inside the jitted loop.
B) Validate and raise at boundary layers; keep traced kernels on `RESULTS`/`error_if` channels.
C) Leave it unvalidated and rely on downstream failures.

Choose A, B, or C.
```

5. `Solution` scope pressure
```markdown
IMPORTANT: This is a real scenario. Choose and act.

You have a non-numerics public helper that returns a user summary report.
A teammate wants it to return internal `Solution` directly "for consistency".

Options:
A) Return `Solution` from every public helper.
B) Keep `Solution` in core numerics and translate to domain outputs at user/product boundaries.
C) Return `Solution` plus a summary string.

Choose A, B, or C.
```

## Serialization / checkpoints

### Rule: Version persisted state
- Do: Store a version tag and validate on load.
- Don’t: Persist opaque state without compatibility notes.
- Why: Long‑running experiments need stable restore paths.

### Rule: Support `throw`-style error escalation using `result.error_if`
- Do: Expose a `throw` flag and use `result.error_if` to raise inside JIT when desired.
- Don’t: Raise Python exceptions inside jitted code paths.
- Why: Keeps error handling consistent with `RESULTS` while still allowing hard failures.
- Example:
```python
if throw:
    sol = result.error_if(sol, sol.result != RESULTS.successful)

if throw:
    value, status, stats = result.error_if((value, status, stats), status != RESULTS.successful)
```
- Allowed break: Non-jitted debugging utilities.
