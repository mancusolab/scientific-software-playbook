# Scientific Software Playbook (Claude + Codex)

Audience and intent:
1. This README is for users visiting the GitHub repository to understand, install, and use these plugins.
2. For agent/developer contracts used when developing this repository itself, use `AGENTS.md`.

Scientific Software Playbook is an opinionated workflow for building scientific
software with explicit design gates before implementation. It is aimed at teams
that want traceable decisions, review artifacts, and consistent execution from
architecture through delivery.

This repository hosts two plugins in one codebase:

1. `scientific-plan-execute`
2. `scientific-house-style`

## Plugin Boundaries

1. `scientific-plan-execute`
- Workflow orchestration for architecture, planning, status gates, and phase execution.
- Owns agents, commands, hooks, and playbook scripts/templates.
2. `scientific-house-style`
- Reusable JAX/Equinox house-style skills (`jax-equinox-numerics`, `project-engineering`).
- Can be installed independently.

Dependency contract:
1. `scientific-plan-execute` is required for bootstrap and workflow commands.
2. `scientific-house-style` is optional but recommended when numerics and project
   engineering constraints are in scope.
3. If `scientific-house-style` is not installed, core workflow still runs.

## Who This Is For

- Teams building modeling, simulation, or inference-heavy systems.
- Projects that need architecture and model assumptions reviewed before coding.
- Contributors using Claude and/or Codex in a plan-and-execute workflow.

## What You Get

- Architecture-first planning with explicit approval before implementation.
- Reusable skills, commands, and agents for phased execution.
- Templates for design plans, implementation plans, and review artifacts.
- A Codex bootstrap path for applying this playbook to downstream repos.
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
# bash scripts/install-codex-home.sh --plugin scientific-house-style --force
```

Then:

1. Open your target project in Codex.
2. Run `bootstrap-scientific-software-playbook` once in that project (writes `AGENTS.md` only).
3. Start with `scientific-software-architecture`.

### Claude

1. Add this repository as a local marketplace:
   - `/plugin marketplace add file:///absolute/path/to/scientific-software-playbook`
2. Install the workflow plugin:
   - `/plugin install scientific-plan-execute@scientific-software-playbook`
3. Optional: install house-style plugin:
   - `/plugin install scientific-house-style@scientific-software-playbook`
4. Reload:
   - `/plugin reload`
5. Start architecture:
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
3. Readiness check: `validate-design-plan` or `/validate-design-plan --phase in-review`
4. Approval transition: `set-design-plan-status` or `/set-design-plan-status`
5. Implementation planning: `start-scientific-implementation-plan`
6. Execution: `execute-scientific-implementation-plan`

## Documentation Map

- Installation and setup: `docs/INSTALLATION.md`
- Day-1 onboarding flow: `docs/ONBOARDING.md`
- Compatibility and breaking-change policy: `docs/COMPATIBILITY.md`
- Release notes (two-plugin migration): `docs/releases/2026-02-23-two-plugin-migration.md`
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
├── plugins/
│   ├── scientific-plan-execute/
│   └── scientific-house-style/
├── AGENTS.md
├── docs/
├── scripts/
└── .claude-plugin/  (marketplace manifest)
```

## Script Usage Policy

Direct user-facing script usage is limited to:

- `scripts/install-codex-home.sh`

All other scripts are internal and invoked by commands, skills, hooks, or
agents.
