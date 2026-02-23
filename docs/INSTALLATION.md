# Installation and Usage Guide

This repository hosts two plugins in one codebase:

1. `scientific-plan-execute`
2. `scientific-house-style`

Day-to-day usage is command/skill driven inside Claude or Codex. The only
user-facing shell command is the Codex install step (`install-codex-home.sh`).
All other scripts are internal and invoked by commands, skills, hooks, or agents.

## Plugin Selection and Dependency Contract

1. `scientific-plan-execute` is required for bootstrap and workflow orchestration.
2. `scientific-house-style` is optional and provides reusable numerics/project
   engineering guidance.
3. Default install (`--force` with no `--plugin`) installs both plugins.
4. If only `scientific-house-style` is installed, workflow/bootstrap commands are not available.
5. If only `scientific-plan-execute` is installed, workflow remains fully usable
   and house-style guidance is simply absent.

## Prerequisites

1. `git`
2. Codex and/or Claude

## Clone

```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

## Claude Installation (Native)

1. Add this repository as a marketplace from inside Claude:
- `/plugin marketplace add file:///absolute/path/to/<your-repo-directory>`
2. Install workflow plugin:
- `/plugin install scientific-plan-execute@scientific-software-playbook`
3. Optional: install house-style plugin:
- `/plugin install scientific-house-style@scientific-software-playbook`
4. Reload plugin:
- `/plugin reload`
5. Start workflow:
- `/start-scientific-architecture <slug>`

## Codex Installation (Native)

1. Open this repository in Codex.
2. Run installation from repository root:
```bash
bash scripts/install-codex-home.sh --force
```
Optional selective installs:
```bash
bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force
bash scripts/install-codex-home.sh --plugin scientific-house-style --force
```
3. Open the downstream target project root in Codex.
4. Invoke `bootstrap-scientific-software-playbook`.

What Codex install/bootstrap provides:
1. Skills in `${CODEX_HOME:-$HOME/.codex}/skills/`
2. Plugin bundles in `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/`
3. Downstream project footprint after bootstrap:
- `AGENTS.md` (only)
4. Runtime behavior:
- Plan-execute assets are resolved from the installed plugin bundle in `CODEX_HOME`.
- Workflow outputs (design plans, implementation plans, reviews) are written into the downstream project under `docs/`.

## Installed Skill Inventory (Exact)

`scientific-plan-execute` installs:
1. `install-scientific-software-playbook-home`
2. `bootstrap-scientific-software-playbook`
3. `new-design-plan`
4. `validate-design-plan`
5. `set-design-plan-status`
6. `start-scientific-implementation-plan`
7. `execute-scientific-implementation-plan`
8. `scientific-internet-research-pass`
9. `scientific-software-architecture`
10. `simulation-for-inference-validation`
11. `ingress-to-canonical-jax`
12. `validation-first-pipeline-api`
13. `jax-equinox-core-numerics-shell`
14. `scientific-cli-thin-shell`

`scientific-house-style` installs:
1. `jax-equinox-numerics`
2. `project-engineering`

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

## Compatibility Policy

For plugin compatibility and current breaking-change path contracts, see:

- `docs/COMPATIBILITY.md`

## Upgrade / Reinstall

Codex:
1. Re-open latest repository checkout in Codex.
2. Re-run:
```bash
bash scripts/install-codex-home.sh --force
```
3. Re-run `bootstrap-scientific-software-playbook` in any downstream project that should receive updates.
   - In minimal mode this refreshes `AGENTS.md` only.

Claude:
1. Re-add marketplace from the updated checkout (`/plugin marketplace add ...`) if needed.
2. Re-install required plugin(s):
   - `/plugin install scientific-plan-execute@scientific-software-playbook`
   - `/plugin install scientific-house-style@scientific-software-playbook`
3. Run `/plugin reload`.
