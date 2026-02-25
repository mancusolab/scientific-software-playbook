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

1. `scientific-plan-execute` is required for workflow orchestration.
2. `scientific-research` is required for external-fact validation gates.
3. `scientific-house-style` is required for workflow execution and review gates.
4. Default install (`--force` with no `--plugin`) installs all plugins.
5. If only `scientific-house-style` is installed, workflow commands are not available.
6. Installing `scientific-plan-execute` via Codex installer auto-adds `scientific-research` and `scientific-house-style`.

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
4. Install house-style plugin:
- `/plugin install scientific-house-style@scientific-software-playbook`
5. Reload plugin:
- `/plugin reload`

## Running Workflows (Claude Code)

Open Claude Code in your scientific project directory, then start:
- `/start-design-plan <slug>`

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
4. Invoke `starting-a-design-plan`.

What Codex install provides:
1. Skills in `${CODEX_HOME:-$HOME/.codex}/skills/`
2. Plugin bundles in `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/`
3. Runtime behavior:
- Plan-execute assets are resolved from the installed plugin bundle in `CODEX_HOME`.
- Workflow outputs (design plans, implementation plans, reviews) are written into the downstream project under `docs/`.

## Installed Skill Inventory

Canonical inventory is maintained in:
1. `AGENTS.md` (source-of-truth skill paths)
2. `plugins/scientific-plan-execute/scripts/plugin-catalog.sh` (installer catalog)

Core scientific workflow skills:
1. `asking-clarifying-questions`
2. `brainstorming`
3. `scientific-kickoff`
4. `starting-a-design-plan`
5. `new-design-plan`
6. `validate-design-plan`
7. `set-design-plan-status`
8. `starting-an-implementation-plan`
9. `executing-an-implementation-plan`

## Usage Example (Downstream Project)

Claude Code path:
1. `/start-design-plan <example-slug>`
2. Use `asking-clarifying-questions` and `brainstorming` to refine scope and alternatives.
3. Choose model path early: `provided-model`, `suggested-model`, or `existing-codebase-port`.
   - For `existing-codebase-port`, run `scientific-codebase-investigation-pass` before approval and capture file-level evidence.
4. `/start-simulation-validation <plan-path>` (when simulation-based inference checks are in scope)
5. `scientific-internet-research-pass` (external/scientific/API claims)
6. `/validate-design-plan <plan-path> --phase in-review`
7. `/set-design-plan-status <plan-path> approved-for-implementation`
8. `/start-implementation-plan <plan-path>`
9. Start a fresh session/context (recommended).
10. `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`

Codex path:
1. Invoke `starting-a-design-plan`.
2. Invoke `asking-clarifying-questions` and `brainstorming` during architecture kickoff.
3. Choose model path early: `provided-model`, `suggested-model`, or `existing-codebase-port`.
   - For `existing-codebase-port`, run `scientific-codebase-investigation-pass` before approval and capture file-level evidence.
4. Invoke `simulation-for-inference-validation` when simulation-based inference checks are in scope.
5. Invoke `new-design-plan` with slug `<example-slug>` when plan scaffolding is needed.
6. Invoke `scientific-internet-research-pass` when external claims need citations.
   - Delegate `internet-researcher` for general/API internet claims.
   - Delegate `scientific-literature-researcher` for paper-backed method/model support.
7. Invoke `validate-design-plan` with phase `in-review`.
8. Invoke `set-design-plan-status` with `approved-for-implementation`.
9. Invoke `starting-an-implementation-plan`.
10. Start a fresh session/context (recommended).
11. Invoke `executing-an-implementation-plan` with absolute implementation plan and working-directory paths.

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

Claude Code:
1. Re-add marketplace if needed:
   - `/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git`
2. Re-install required plugin(s):
   - `/plugin install scientific-plan-execute@scientific-software-playbook`
   - `/plugin install scientific-research@scientific-software-playbook`
   - `/plugin install scientific-house-style@scientific-software-playbook`
3. Run `/plugin reload`.
