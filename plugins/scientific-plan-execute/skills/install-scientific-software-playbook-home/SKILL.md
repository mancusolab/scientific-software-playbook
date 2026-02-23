---
name: install-scientific-software-playbook-home
description: Use when installing or upgrading this repository's scientific software playbook into CODEX_HOME from within Codex, without requiring users to run shell scripts directly.
---

# Install Scientific Software Playbook Home

Use this skill to install this playbook into `${CODEX_HOME:-$HOME/.codex}`.

## Preconditions

1. Current directory is the repository root.
2. `scripts/install-codex-home.sh` exists.

## Workflow

1. Verify install script exists:
- `scripts/install-codex-home.sh`
2. Run install (default installs both plugins):
- `bash scripts/install-codex-home.sh --force`
3. Optional selective installs when requested:
- `bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force`
- `bash scripts/install-codex-home.sh --plugin scientific-house-style --force`
4. Verify installed skill files based on selected install mode:
- Default install (`--force`, no `--plugin`) should include:
- `${CODEX_HOME:-$HOME/.codex}/skills/scientific-software-architecture/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/bootstrap-scientific-software-playbook/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/new-design-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/validate-design-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/set-design-plan-status/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/start-scientific-implementation-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/execute-scientific-implementation-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/scientific-internet-research-pass/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/simulation-for-inference-validation/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/jax-equinox-numerics/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/project-engineering/SKILL.md`
- `--plugin scientific-plan-execute` should include plan-execute skills and may omit:
  - `${CODEX_HOME:-$HOME/.codex}/skills/jax-equinox-numerics/SKILL.md`
  - `${CODEX_HOME:-$HOME/.codex}/skills/project-engineering/SKILL.md`
- `--plugin scientific-house-style` should include:
  - `${CODEX_HOME:-$HOME/.codex}/skills/jax-equinox-numerics/SKILL.md`
  - `${CODEX_HOME:-$HOME/.codex}/skills/project-engineering/SKILL.md`
5. Verify required installed plugin bundle hook definition:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/hooks/hooks.json` (when plan-execute is installed)

Dependency contract:
1. `scientific-plan-execute` is required for bootstrap and workflow orchestration.
2. `scientific-house-style` is optional, but included by default install.

## Output

Report:
1. Whether installation succeeded.
2. Installed `CODEX_HOME` path.
3. Next step:
- invoke `bootstrap-scientific-software-playbook` from the target project root.
