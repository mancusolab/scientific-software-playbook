---
name: jax-equinox-core-numerics-shell
description: Use when enforcing local numerics gates in plan-execute execution; this thin adapter applies jax-equinox-numerics guidance when available plus required local gates.
---

# JAX/Equinox Core Numerics Shell

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

This skill is a thin adapter for numerics execution in this playbook.
It prefers `jax-equinox-numerics` for broad guidance and always enforces the required local gates below.

## Path Contract (Unambiguous)

1. Skill references in this adapter are skill IDs, not repository-relative paths.
2. Preferred upstream guidance skill:
- `jax-equinox-numerics`
3. Installation-local resolution examples for `jax-equinox-numerics`:
- Codex: `${CODEX_HOME:-$HOME/.codex}/skills/jax-equinox-numerics/SKILL.md`
- Claude plugin: `<claude-plugin-root>/skills/jax-equinox-numerics/SKILL.md`
4. This adapter has no required installation-local file dependencies beyond skill availability checks.

## Adapter Workflow

1. Try to apply `jax-equinox-numerics` first.
2. If `jax-equinox-numerics` is unavailable, continue with this adapter's required local gates.
3. House-style absence must not block plan-execute workflows.
4. Always enforce local gates before completion claims.

## Required Local Gates

1. Numerics APIs accept canonical arrays/PyTrees only.
2. Numerics modules do not parse files, handle tabular containers, or run CLI validation.
3. Public numerics APIs define explicit transformation boundaries (`eqx.filter_jit`/`jax.jit`).
4. Solver failures use explicit status/result channels (no silent non-success handling).
5. Runtime-state control inside traced kernels uses JAX-compatible checks/result channels, not Python exceptions.
6. Custom solver logic requires documented rationale versus feasible Optimistix/Lineax mapping.
7. Completion claims require fresh verification evidence.

## Minimum Verification

1. JIT behavior tests.
2. VMAP consistency tests.
3. AD checks (for example JVP/VJP against finite-difference where feasible).
4. Failure-mode tests (non-finite, non-convergence, ill-conditioned inputs as relevant).
5. Result/status contract tests for success and non-success paths.
6. Solver-mapping evidence (or infeasibility note) when custom updates are selected.

## TDD Requirements

1. Behavior changes start with failing tests.
2. Bug fixes include failing regression tests before implementation.
3. Completion requires fresh command evidence from relevant verification runs.

## Severity Guidance

1. Raw path/container inputs in numerics APIs: `critical`.
2. Runtime-state Python exceptions in traced kernels: at least `high`.
3. Missing structured result/status semantics: at least `high`.
4. Missing custom-solver rationale against existing solver mapping: at least `medium`.
5. Missing fresh verification evidence for claimed fixes: at least `high`.

## Hard Stops

1. Stop if numerics APIs accept raw paths or host-side containers.
2. Stop if traced kernels use Python exceptions for runtime-state control flow.
3. Stop if solver failures are not represented through explicit status/result channels.
4. Stop if custom solver work is selected without translation-feasibility rationale.
5. Stop if behavior changes lack failing-test-first and fresh verification evidence.

## Output Contract

1. Decision: `pass` | `blocked`.
2. Findings include `severity`, `location`, `gate violated`, `impact`, and `fix`.
3. Verification summary lists commands run and key outcomes.
