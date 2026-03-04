# Installed Path Resolution

Use this contract to avoid duplicating Codex/Claude install-path logic.

## Rule 1: Reference Skills/Agents/Commands By ID

Prefer logical IDs over filesystem paths whenever runtime tools support them:
- Skills: `using-plan-and-execute`, `starting-a-design-plan`, `new-design-plan`, `scientific-kickoff`, `starting-an-implementation-plan`, `executing-an-implementation-plan`
- Agents: `scientific-architecture-reviewer`, `scientific-code-reviewer`
- Commands: `start-plan-and-execute`, `start-design-plan`, `start-implementation-plan`, `execute-implementation-plan`

Do not encode repository-relative skill/agent paths in workflow logic.

## Rule 2: Resolve Filesystem Assets Through Shared Resolver

When a script or template file path is required, use:
- `plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`
- `plugins/scientific-plan-execute/scripts/lib/runtime-paths.sh`

Resolver precedence:
1. `CLAUDE_PLUGIN_ROOT` (Claude plugin runtime)
2. `CODEX_HOME` install bundle (Codex runtime)
3. local sibling fallback (repo/dev execution)

## Standard Snippet

```bash
RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"
SCRIPT_PATH="$(bash "$RESOLVER_PATH" --plan-execute-script "<script-name>.sh")"
```

This keeps runtime differences in one maintained resolver implementation.

## Preflight Wrapper

When workflow steps need house-style dependency checks, call the shared wrapper:

```bash
RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"
PREFLIGHT_PATH="$(bash "$RESOLVER_PATH" --plan-execute-script "run-required-house-style-preflight.sh")"
bash "$PREFLIGHT_PATH"
```

Do not reimplement checker-resolution logic per skill or command.
