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
2. Run install:
- `bash scripts/install-codex-home.sh --force`
3. Verify required installed skill files:
- `${CODEX_HOME:-$HOME/.codex}/skills/scientific-software-architecture/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/bootstrap-scientific-software-playbook/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/new-design-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/validate-design-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/set-design-plan-status/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/start-scientific-implementation-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/execute-scientific-implementation-plan/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/scientific-internet-research-pass/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/simulation-for-inference-validation/SKILL.md`
4. Verify required installed bundle hook definition:
- `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/hooks/hooks.json`

## Output

Report:
1. Whether installation succeeded.
2. Installed `CODEX_HOME` path.
3. Next step:
- invoke `bootstrap-scientific-software-playbook` from the target project root.
