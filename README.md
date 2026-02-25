# Scientific Software Playbook (Claude Code + Codex)

Audience and intent:
1. This README is for users visiting the GitHub repository to understand, install, and use these plugins.
2. For agent/developer contracts used when developing this repository itself, use `AGENTS.md`.

Scientific Software Playbook is an opinionated workflow for building scientific
software with explicit design gates before implementation. It is aimed at teams
that want traceable decisions, review artifacts, and consistent execution from
architecture through delivery.

This repository hosts three plugins in one codebase:

1. `scientific-plan-execute`
2. `scientific-research`
3. `scientific-house-style`

## Plugin Boundaries

1. `scientific-plan-execute`
- Workflow orchestration for architecture, planning, status gates, and phase execution.
- Owns agents, commands, hooks, and playbook scripts/templates.
2. `scientific-research`
- Reusable research workflows and delegates:
  - `scientific-internet-research-pass`
  - `scientific-codebase-investigation-pass`
  - `codebase-investigator`, `internet-researcher`, `remote-code-researcher`, `combined-researcher`, `scientific-literature-researcher`
3. `scientific-house-style`
- Reusable JAX/Equinox house-style skills (`jax-equinox-numerics`, `project-engineering`).
- Can be installed independently.

Dependency contract:
1. `scientific-plan-execute` is required for bootstrap and workflow commands.
2. `scientific-research` is required for external-fact validation gates in workflow planning.
3. Codex installer auto-adds `scientific-research` when `scientific-plan-execute` is selected.
4. `scientific-house-style` is optional but recommended when numerics and project
   engineering constraints are in scope.
5. If `scientific-house-style` is not installed, core workflow still runs.

## Who This Is For

- Teams building modeling, simulation, or inference-heavy systems.
- Projects that need architecture and model assumptions reviewed before coding.
- Contributors using Claude Code and/or Codex in a plan-and-execute workflow.

## What You Get

- Architecture-first planning with explicit approval before implementation.
- Reusable skills, commands, and agents for phased execution.
- Templates for design plans, implementation plans, and review artifacts.
- A Codex bootstrap path for applying this playbook to downstream repos.
- A dedicated research plugin with ed3d-style research agent layout for local and internet investigation.
- A separate house-style plugin for JAX/Equinox numerics and project
  engineering guidance.

## Quickstart

### Codex

```bash
git clone <repo-url>
cd scientific-software-playbook
bash scripts/install-codex-home.sh --force
# Optional selective install:
# bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force
# bash scripts/install-codex-home.sh --plugin scientific-research --force
# bash scripts/install-codex-home.sh --plugin scientific-house-style --force
```

Then:

1. Open your target project in Codex.
2. Run `bootstrap-scientific-software-playbook` once in that project (writes `AGENTS.md` only).
3. Start with `scientific-software-architecture`.

### Claude Code

Install from any directory:

1. `/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git`
2. `/plugin install scientific-plan-execute@scientific-software-playbook`
3. `/plugin install scientific-research@scientific-software-playbook`
4. `/plugin install scientific-house-style@scientific-software-playbook`
5. `/plugin reload`

Then open your project directory and run:

- `/start-scientific-architecture <slug>`

## Workflow At A Glance

```text
Architecture plan
  -> Review + validation
  -> Explicit approval
  -> Implementation plan (phase files)
  -> Phase execution with tests and review evidence
```

Typical entry points:

1. Architecture: `scientific-software-architecture` or `/start-scientific-architecture`
2. Plan scaffolding: `new-design-plan` or `/new-design-plan`
3. Research passes: `scientific-internet-research-pass`, `scientific-codebase-investigation-pass`
4. Readiness check: `validate-design-plan` or `/validate-design-plan --phase in-review`
5. Approval transition: `set-design-plan-status` or `/set-design-plan-status`
6. Implementation planning: `start-scientific-implementation-plan`
7. Execution: `execute-scientific-implementation-plan`

## Documentation Map

- Installation and setup: `docs/INSTALLATION.md`
- Day-1 onboarding flow: `docs/ONBOARDING.md`
- Compatibility and breaking-change policy: `docs/COMPATIBILITY.md`
- Repository attribution notice: `NOTICE`
- Repository and upstream lineage licenses: `LICENSE`, `LICENSE.superpowers`
- Release notes (three-plugin research split): `docs/releases/2026-02-23-research-plugin-split.md`
- Historical release notes (two-plugin migration): `docs/releases/2026-02-23-two-plugin-migration.md`
- Design plan templates: `plugins/scientific-plan-execute/docs/design-plans/templates/`
- Implementation plan templates: `plugins/scientific-plan-execute/docs/implementation-plans/templates/`
- Review template: `plugins/scientific-plan-execute/docs/reviews/review-template.md`
- Skill/agent IO checklist: `plugins/scientific-plan-execute/docs/checklists/skill-agent-io-checklist.md`

## Agent-Focused Policy And Internals

This README is intentionally human-focused. For strict operational rules and
full internals, use:

- `AGENTS.md`

`AGENTS.md` contains hard stops, delegate details, full skill inventory, and
runtime constraints.

## Repository Layout

```text
scientific-software-playbook/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── scientific-plan-execute/
│   ├── scientific-research/
│   ├── scientific-house-style/
│   └── README.md
├── docs/
├── scripts/
├── AGENTS.md
└── README.md
```

## Script Usage Policy

Direct user-facing script usage is limited to:

- `scripts/install-codex-home.sh`

All other scripts are internal and invoked by commands, skills, hooks, or
agents.

## Attribution

This repository is derived in part from [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins):

1. `scientific-plan-execute` derives from `ed3d-plan-and-execute`.
2. `scientific-research` derives from `ed3d-research-agents`.
3. `scientific-house-style` incorporates patterns from `ed3d-house-style` with project-specific guidance.

Upstream lineage includes material derived from [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent via `ed3d-plan-and-execute`.

## License

1. Repository and plugin content is licensed under Creative Commons Attribution-ShareAlike 4.0 International (`LICENSE` and `plugins/*/LICENSE`).
2. Upstream `obra/superpowers` material in the derivation chain is MIT-licensed (`LICENSE.superpowers` and `plugins/scientific-plan-execute/LICENSE.superpowers`).
3. Attribution and provenance details are recorded in `NOTICE`.
