# Installation and Usage Guide

This repository is a single playbook plugin installation target (plan-and-execute
style), not a plugin catalog.

Day-to-day usage is command/skill driven inside Claude or Codex. The only
user-facing shell command is the Codex install step (`install-codex-home.sh`).
All other scripts are internal and invoked by commands, skills, hooks, or agents.

## Prerequisites

1. `git`
2. Codex and/or Claude

## Clone

```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

## Claude Installation (Native)

1. Install plugin from inside Claude:
- `/plugin install file:///absolute/path/to/<your-repo-directory>`
2. Reload plugin:
- `/plugin reload`
3. Start workflow:
- `/start-scientific-architecture <slug>`

## Codex Installation (Native)

1. Open this repository in Codex.
2. Run installation from repository root:
```bash
bash scripts/install-codex-home.sh --force
```
3. Open the downstream target project root in Codex.
4. Invoke `bootstrap-scientific-software-playbook`.

What Codex install/bootstrap provides:
1. Skills in `${CODEX_HOME:-$HOME/.codex}/skills/`
2. Bundle assets in `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/`
3. Downstream project assets:
- `AGENTS.md`
- `agents/`
- `commands/`
- `hooks/`
- `scripts/` (internal utilities)
- `docs/design-plans/templates/`
- `docs/implementation-plans/templates/`

## Usage Example (Downstream Project)

Claude path:
1. `/start-scientific-architecture genetics-infer`
2. Choose model path early: `provided-model` or `suggested-model`.
3. `/start-simulation-validation <plan-path>` (when simulation-based inference checks are in scope)
4. `scientific-internet-research-pass` (when external facts are uncertain or model suggestions need citations)
5. `/validate-design-plan <plan-path> --phase in-review`
6. `/set-design-plan-status <plan-path> approved-for-implementation`
7. `/start-scientific-implementation-plan <plan-path> genetics-infer`
8. Start a fresh session/context (recommended).
9. `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`

Codex path:
1. Invoke `scientific-software-architecture`.
2. Choose model path early: `provided-model` or `suggested-model`.
3. Invoke `simulation-for-inference-validation` when simulation-based inference checks are in scope.
4. Invoke `new-design-plan` with slug `genetics-infer` when plan scaffolding is needed.
5. Invoke `scientific-internet-research-pass` when external facts are uncertain or model suggestions need citations.
6. Invoke `validate-design-plan` with phase `in-review`.
7. Invoke `set-design-plan-status` with `approved-for-implementation`.
8. Invoke `start-scientific-implementation-plan`.
9. Start a fresh session/context (recommended).
10. Invoke `execute-scientific-implementation-plan` with the absolute implementation plan directory path.

## Upgrade / Reinstall

Codex:
1. Re-open latest repository checkout in Codex.
2. Re-run:
```bash
bash scripts/install-codex-home.sh --force
```
3. Re-run `bootstrap-scientific-software-playbook` in any downstream project that should receive updates.

Claude:
1. Re-install plugin from the updated checkout (`/plugin install ...`) if needed.
2. Run `/plugin reload`.
