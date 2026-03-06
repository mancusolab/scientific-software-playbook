# Installation and Usage Guide

This repository hosts four plugins in one codebase:

1. `scientific-plan-execute`
2. `scientific-research`
3. `scientific-house-style`
4. `scientific-agent-tools`

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
   - It includes numerics, module/package-design, and project-engineering house-style guidance used by plan-execute agents.
4. `scientific-agent-tools` is optional maintainer tooling for plugin authoring and context maintenance. It is not required for downstream scientific workflow execution.
5. Default install (`--force` with no `--plugin`) installs all plugins.
6. If only `scientific-house-style` is installed, workflow commands are not available.
7. Installing `scientific-plan-execute` via Codex installer auto-adds `scientific-research` and `scientific-house-style`.

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
5. Install maintainer-tools plugin when needed:
- `/plugin install scientific-agent-tools@scientific-software-playbook`
6. Reload plugin:
- `/plugin reload`

## Running Workflows (Claude Code)

Open Claude Code in your scientific project directory, then start:
- Default entrypoint: `/start-plan-and-execute`
- Main phase commands after routing: `/start-design-plan <slug>`, `/start-implementation-plan <design-plan-path>`, `/execute-implementation-plan <plan-dir> <working-dir>`
- Router-selected bootstrap for fresh/model-path/parity work: `/start-scientific-kickoff`

Manual utilities inside an active workflow:
- `/new-design-plan <slug>` for direct plan scaffolding
- `/validate-design-plan <plan-path> --phase <in-review|approval>`
- `/set-design-plan-status <plan-path> <draft|in-review|approved-for-implementation>`
- `/start-simulation-validation <plan-path>` when simulation-based inference checks are in scope
- `/how-to-customize` for installing project-specific guidance files

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
bash scripts/install-codex-home.sh --plugin scientific-agent-tools --force
```
3. Open the downstream target project root in Codex.
4. Invoke `using-plan-and-execute` to choose the correct entrypoint.
5. Follow the routed next step (`scientific-kickoff` for fresh/model-path bootstrap work, `starting-a-design-plan` for established design work).

What Codex install provides:
1. Skills in `${CODEX_HOME:-$HOME/.codex}/skills/`
2. Plugin bundles in `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/`
3. Runtime behavior:
- Plan-execute assets are resolved from the installed plugin bundle in `CODEX_HOME`.
- Workflow outputs (design plans, implementation plans, reviews) are written into the downstream project under `docs/`.
- `scientific-agent-tools` installs optional maintainer skills and the `project-claude-librarian` agent.

## Installed Skill Inventory

Canonical inventory is maintained in:
1. `AGENTS.md` (source-of-truth skill paths)
2. `plugins/scientific-plan-execute/scripts/plugin-catalog.sh` (installer catalog)

Core scientific workflow skills:
1. `asking-clarifying-questions`
2. `brainstorming`
3. `using-plan-and-execute`
4. `scientific-kickoff`
5. `starting-a-design-plan`
6. `new-design-plan`
7. `validate-design-plan`
8. `set-design-plan-status`
9. `starting-an-implementation-plan`
10. `executing-an-implementation-plan`

## Usage Example (Downstream Project)

Claude Code path:
1. Run `/start-plan-and-execute`.
2. If the router selects kickoff, complete `/start-scientific-kickoff`, then continue with `/start-design-plan <example-slug>` and ingest `.scientific/kickoff.md`.
3. If the router selects design planning directly, continue with `/start-design-plan <example-slug>`.
4. Use `asking-clarifying-questions` and `brainstorming` to refine scope and alternatives.
5. For fresh-project/model-path tracks, choose model path early: `provided-model`, `suggested-model`, or `existing-codebase-port`.
   - For `existing-codebase-port`, run `scientific-codebase-investigation-pass` before approval and capture file-level evidence.
   - Pass kickoff output (`.scientific/kickoff.md`) into the design flow.
6. `/start-simulation-validation <plan-path>` (when simulation-based inference checks are in scope)
7. `scientific-internet-research-pass` (external/scientific/API claims)
8. `/validate-design-plan <plan-path> --phase in-review`
9. `/set-design-plan-status <plan-path> approved-for-implementation`
10. `/start-implementation-plan <plan-path>`
11. Start a fresh session/context (recommended).
12. `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`

The normal Claude workflow is router -> design -> implementation plan -> execute. Validation, status changes, simulation setup, and direct plan scaffolding are manual utilities used within that flow when needed.

Codex path:
1. Invoke `using-plan-and-execute`.
2. If the router selects kickoff, invoke `scientific-kickoff` first, then continue to `starting-a-design-plan` and ingest `.scientific/kickoff.md`.
3. If the router selects design planning directly, invoke `starting-a-design-plan`.
4. Invoke `asking-clarifying-questions` and `brainstorming` during architecture kickoff.
5. For fresh-project/model-path tracks, choose model path early: `provided-model`, `suggested-model`, or `existing-codebase-port`.
   - For `existing-codebase-port`, run `scientific-codebase-investigation-pass` before approval and capture file-level evidence.
   - Pass kickoff output (`.scientific/kickoff.md`) into `starting-a-design-plan`.
6. Invoke `simulation-for-inference-validation` when simulation-based inference checks are in scope.
7. Invoke `new-design-plan` with slug `<example-slug>` when plan scaffolding is needed.
8. Invoke `scientific-internet-research-pass` when external claims need citations.
   - Delegate `internet-researcher` for general/API internet claims.
   - Delegate `scientific-literature-researcher` for paper-backed method/model support.
9. Invoke `validate-design-plan` with phase `in-review`.
10. Invoke `set-design-plan-status` with `approved-for-implementation`.
11. Invoke `starting-an-implementation-plan`.
12. Start a fresh session/context (recommended).
13. Invoke `executing-an-implementation-plan` with absolute implementation plan and working-directory paths.

The normal Codex workflow is router -> design -> implementation plan -> execute. `new-design-plan`, `validate-design-plan`, `set-design-plan-status`, and `simulation-for-inference-validation` are manual utilities used within an active plan.

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
   - `/plugin install scientific-agent-tools@scientific-software-playbook` (optional)
3. Run `/plugin reload`.
