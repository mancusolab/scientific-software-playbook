# Installation and Usage Guide

This repository hosts three plugins in one codebase:

1. `scientific-plan-execute`
2. `scientific-research`
3. `scientific-house-style`

Day-to-day usage is command/skill driven inside Claude Code or Codex. The only
user-facing shell command is the Codex install step (`install-codex-home.sh`).
All other scripts are internal and invoked by commands, skills, hooks, or agents.

Audience and scope:
1. This document is user-facing installation/usage guidance.
2. For repository-development contracts and agent-facing implementation rules, use `AGENTS.md`.
3. For high-level plugin overview on GitHub, use `README.md`.

## Plugin Selection and Dependency Contract

1. `scientific-plan-execute` is required for bootstrap and workflow orchestration.
2. `scientific-research` is required for external-fact validation gates.
3. `scientific-house-style` is optional and provides reusable numerics/project
   engineering guidance.
4. Default install (`--force` with no `--plugin`) installs all plugins.
5. If only `scientific-house-style` is installed, workflow/bootstrap commands are not available.
6. Installing `scientific-plan-execute` via Codex installer auto-adds `scientific-research`.

## Prerequisites

1. `git`
2. Codex and/or Claude Code

## Claude Code Installation (Native)

Installation can be done from any directory:

1. Add this repository as a marketplace directly from GitHub:
- `/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git`
2. Install workflow plugin:
- `/plugin install scientific-plan-execute@scientific-software-playbook`
3. Install research plugin:
- `/plugin install scientific-research@scientific-software-playbook`
4. Optional: install house-style plugin:
- `/plugin install scientific-house-style@scientific-software-playbook`
5. Reload plugin:
- `/plugin reload`

## Running Workflows (Claude Code)

Open Claude Code in your scientific project directory, then start:
- `/start-scientific-architecture <slug>`

## Codex Installation (Native)

1. Clone the repository:
```bash
git clone https://github.com/mancusolab/scientific-software-playbook.git
cd scientific-software-playbook
```
2. Run installation from repository root:
```bash
bash scripts/install-codex-home.sh --force
```
Optional selective installs:
```bash
bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force
bash scripts/install-codex-home.sh --plugin scientific-research --force
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
1. `bootstrap-scientific-software-playbook`
2. `new-design-plan`
3. `validate-design-plan`
4. `set-design-plan-status`
5. `start-scientific-implementation-plan`
6. `execute-scientific-implementation-plan`
7. `scientific-software-architecture`
8. `simulation-for-inference-validation`
9. `validation-first-pipeline-api`
10. `scientific-cli-thin-shell`

`scientific-research` installs:
1. `scientific-internet-research-pass`
2. `scientific-codebase-investigation-pass`

`scientific-house-style` installs:
1. `jax-equinox-numerics`
2. `project-engineering`
3. `coding-effectively`
4. `functional-core-imperative-shell` (installed at `howto-functional-vs-imperative`)
5. `property-based-testing`
6. `writing-for-a-technical-audience`
7. `writing-good-tests`

## Usage Example (Downstream Project)

Claude Code path:
1. `/start-scientific-architecture <example-slug>`
2. Choose model path early: `provided-model` or `suggested-model`.
3. `/start-simulation-validation <plan-path>` (when simulation-based inference checks are in scope)
4. `scientific-internet-research-pass` (external/scientific/API claims)
5. `/validate-design-plan <plan-path> --phase in-review`
6. `/set-design-plan-status <plan-path> approved-for-implementation`
7. `/start-scientific-implementation-plan <plan-path> <example-slug>`
8. Start a fresh session/context (recommended).
9. `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`

Codex path:
1. Invoke `scientific-software-architecture`.
2. Choose model path early: `provided-model` or `suggested-model`.
3. Invoke `simulation-for-inference-validation` when simulation-based inference checks are in scope.
4. Invoke `new-design-plan` with slug `<example-slug>` when plan scaffolding is needed.
5. Invoke `scientific-internet-research-pass` when external claims need citations.
   - Delegate `internet-researcher` for general/API internet claims.
   - Delegate `scientific-literature-researcher` for paper-backed method/model support.
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

Claude Code:
1. Re-add marketplace if needed:
   - `/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git`
2. Re-install required plugin(s):
   - `/plugin install scientific-plan-execute@scientific-software-playbook`
   - `/plugin install scientific-research@scientific-software-playbook`
   - `/plugin install scientific-house-style@scientific-software-playbook`
3. Run `/plugin reload`.
