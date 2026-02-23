# Compatibility and Migration Policy

## Plugin Compatibility Matrix

| `scientific-plan-execute` | `scientific-house-style` | Status | Notes |
|---|---|---|---|
| `0.1.x` | `0.1.x` | Supported | Recommended default (both installed). |
| `0.1.x` | not installed | Supported | Workflow runs; house-style skills are unavailable. |
| not installed | `0.1.x` | Supported | House-style skills only; no bootstrap/workflow commands. |

Notes:
1. `scientific-plan-execute` and `scientific-house-style` are independently installable.
2. Workflow orchestration requires `scientific-plan-execute`.
3. House-style skills are optional dependencies from a runtime perspective.

## Compatibility Shims Covered

The following are temporary migration shims:
1. Repository-root compatibility links: `agents/`, `commands/`, `hooks/`, and
   `skills/<name>` links to plugin-owned assets.
2. Repository-root script links: `scripts/bootstrap-scientific-software-playbook.sh`,
   `scripts/new-design-plan.sh`, `scripts/set-design-plan-status.sh`,
   `scripts/validate-design-plan-readiness.sh`, and `scripts/hooks`.
3. Legacy bundle paths in `CODEX_HOME`:
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/agents/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/commands/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/hooks/`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/`
4. Root `.claude-plugin/marketplace.json` catalog path.

## Deprecation Timeline

1. Two-plugin architecture introduced: February 23, 2026.
2. Compatibility shims are guaranteed through all `0.1.x` and `0.2.x` releases.
3. Earliest shim removal target: August 1, 2026, and only in `0.3.0` or later.
4. Any removal will be announced in release notes with migration steps.

## Migration Hardening Status

Verified on February 23, 2026:
1. Existing-user upgrade path (`--force` reinstall over legacy-style layout): pass.
2. New install path (clean `CODEX_HOME`): pass.
3. Plan-execute-only install: pass.
4. Both-plugins install (explicit selection): pass.

Verification artifact:
1. Phase 5 matrix log captured during migration hardening run (local CI/shell artifact).

## Migration Steps

1. Reinstall in Codex home:
```bash
bash scripts/install-codex-home.sh --force
```
2. For downstream projects, refresh bootstrap output:
```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh" --force
```
3. Prefer plugin-scoped paths in custom tooling:
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/...`
   - `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-house-style/...`
