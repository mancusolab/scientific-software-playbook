# Compatibility Policy

## Plugin Compatibility Matrix

| `scientific-plan-execute` | `scientific-research` | `scientific-house-style` | Status | Notes |
|---|---|---|---|---|
| `0.1.x` | `0.1.x` | `0.1.x` | Supported | Recommended default (all installed). |
| `0.1.x` | `0.1.x` | not installed | Supported | Workflow runs; house-style skills are unavailable. |
| `0.1.x` | not installed | `0.1.x` | Unsupported | Research-gated workflow steps will fail. |
| not installed | `0.1.x` | any | Supported | Research skills only; no bootstrap/workflow commands. |
| not installed | not installed | `0.1.x` | Supported | House-style skills only; no bootstrap/workflow commands. |

Notes:
1. `scientific-plan-execute`, `scientific-research`, and `scientific-house-style` are independently installable.
2. Workflow orchestration requires `scientific-plan-execute`.
3. Workflow research gates require `scientific-research`.
4. House-style skills are optional dependencies from a runtime perspective.

## Breaking Change (Applied)

Effective February 23, 2026:
1. Repository-root compatibility links were removed:
   - `agents/`
   - `commands/`
   - `hooks/`
   - `skills/`
   - wrapper script links under `scripts/` except `scripts/install-codex-home.sh`
2. Installed legacy root bundle paths are no longer populated under:
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/agents/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/commands/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/hooks/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/`
3. Plugin-scoped paths are now the only supported contract:
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/...`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-research/...`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-house-style/...`

## Migration Steps

1. Reinstall in Codex home:
```bash
bash scripts/install-codex-home.sh --force
```
2. For downstream projects, refresh bootstrap output:
```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh" --force
```
3. Update custom tooling to use plugin-scoped paths only.
