---
name: scientific-cli-thin-shell
description: Use when building command-line interfaces for scientific workflows - keeps CLI logic thin, reproducible, and aligned with canonical pipeline and numerics contracts with integrated CLI engineering rules.
---

# Scientific CLI Thin Shell

The CLI should be a boundary adapter, not a business-logic layer.
This skill includes all CLI engineering rules needed for this playbook (no companion skill required).

## Input Contract

Required inputs:
1. CLI command/subcommand surface definition.
2. Pipeline entrypoint contracts.
3. Output/exit-code expectations for users and automation.

## Output Contract

Required outputs:
1. Thin CLI handlers that parse/validate/dispatch/report only.
2. Stable stdout/stderr and exit-code contracts.
3. CLI contract tests for parsing, output channels, and exit-code mapping.

## CLI Rules

1. Parse args and environment.
2. Run boundary validation and ingress conversion.
3. Dispatch into pipeline entrypoints.
4. Emit stable output and exit codes.
5. Avoid numerics or format-specific logic in CLI command handlers.
6. Keep one canonical command entrypoint per workflow; avoid one-off command wrappers.

## Do/Don't Examples

1. Dispatch model
- Do: use subcommands with `set_defaults(func=...)` and a single `args.func(args)` dispatch.
- Don't: build large `if/elif` blocks for unrelated workflows.

2. Boundary validation
- Do: validate `seed`, `dtype`, `device`, and path contracts in CLI handlers before pipeline/numerics calls.
- Don't: let deep numerics code surface basic argument errors.

3. Diagnostics
- Do: use logging/callbacks for diagnostics to preserve machine-readable output.
- Don't: use ad-hoc `print(...)` logs that corrupt `--json` output streams.

4. API sprawl control
- Do: add CLI wrappers only when they add clear contract value (validation, normalization, compatibility).
- Don't: add duplicate one-line command variants with slightly different defaults.

## Channel Contract

1. `stdout`: primary result payload (human-readable or `--json`).
2. `stderr`: diagnostics and failures.
3. Exit code semantics are documented and stable.

## Exit-Code Mapping

1. `0`: success.
2. `2`: usage/argument/config validation errors.
3. `1`: runtime/result failures after valid invocation.

## Configuration Precedence

Use explicit precedence and document it:
`defaults < config file < environment variables < CLI flags`.

## Reproducibility Contract

1. Expose flags for reproducibility controls (`seed`, dtype/device where relevant).
2. Emit effective configuration in debug or metadata output modes.
3. Avoid hidden global state in command execution.
4. Keep dependency/version reporting available for automation or audit outputs when relevant.

## CLI Test Requirements

1. TDD for CLI behavior changes: start with failing tests for parse and contract behavior.
2. Add tests for:
- `--help` and parse failures.
- `stdout`/`stderr` separation.
- exit-code mapping for success/failure paths.
- subcommand dispatch behavior.
- reproducibility/config precedence behavior.
3. Verify CLI contract tests before claiming completion.

## Hard Stops

1. If CLI handlers include numerics or parser business logic, block completion.
2. If machine-readable output can be polluted by diagnostics, block completion.
3. If CLI contracts (stdout/stderr/exit codes) are undocumented or unstable across equivalent paths, block completion.
