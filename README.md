# Scientific Software Playbook (Claude Code + Codex)

Scientific Software Playbook is an opinionated workflow for building scientific
software with explicit design gates before implementation. It is aimed at
research teams that want traceable decisions, review artifacts, and consistent
execution from architecture through delivery.


This repository hosts three plugins in one codebase:

1. `scientific-plan-execute`, workflow orchestration for architecture, planning, status gates, and phase execution.
2. `scientific-research`, eeusable research workflows and delegates:
3. `scientific-house-style`, reusable JAX/Equinox house-style skills

Recommended entrypoints (in Claude Code or Codex environment):

1. New project: `scientific-kickoff` (or `/start-scientific-kickoff`)
   1. Implement (inferential) software based on local document, online reference.
   2. Implement (inferential) software based on AGENT-based suggestion after questioning user.
   3. Port existing codebase to JAX-based backend.
2. Existing project/iteration: `new-design-plan` (or `/new-design-plan <slug>`)


   [**Who This Is For**](#who-this-is-for)
   | [**What You Get**](#what-you-get)
   | [**Quickstart**](#quickstart)
   | [**Workflow At A Glance**](#workflow-at-a-glance)
   | [**Documentation Map**](#documentation-map)
   | [**Repository Layout**](#repository-layout)


## Who This Is For

- Research teams building modeling, simulation, or inference-heavy systems.
- Projects that need architecture and model assumptions reviewed before coding.
- Contributors using Claude Code and/or Codex in a plan-and-execute workflow.

## What You Get

- Architecture-first planning with explicit approval before implementation.
- Built-in clarification and brainstorming stages before architecture lock-in.
- Reusable skills, commands, and agents for phased execution.
- Specialized reviewer delegates for architecture, numerics, CLI/API contracts, and inference algorithm behavior.
- Templates for design plans, implementation plans, and review artifacts.
- A dedicated research plugin with ed3d-style research agent layout for local and internet investigation.
- A separate house-style plugin for JAX/Equinox numerics and project
  engineering guidance.

## Quickstart
Here is a quickstart on installation and usage. Please see [Installation Guide](docs/INSTALLATION.md) for details.

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
2. New project entrypoint: run `scientific-kickoff` first.
3. Continue with `starting-a-design-plan` so kickoff output is ingested.
4. Existing project/iteration entrypoint: run `new-design-plan` first.

### Claude Code

Install from any directory:

1. `/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git`
2. `/plugin install scientific-plan-execute@scientific-software-playbook`
3. `/plugin install scientific-research@scientific-software-playbook`
4. `/plugin install scientific-house-style@scientific-software-playbook`
5. `/plugin reload`

Then open your project directory and run:

- New project: `/start-scientific-kickoff` then `/start-design-plan <slug>`
- Existing project/iteration: `/new-design-plan <slug>`

## Workflow At A Glance

```text
Architecture plan
  -> Review + validation
  -> Explicit approval
  -> Implementation plan (phase files)
  -> Phase execution with tests and review evidence
```

Typical entry points:

1. New projects: `scientific-kickoff` or `/start-scientific-kickoff`
2. Design orchestration after kickoff: `starting-a-design-plan` or `/start-design-plan`
3. Existing project/iteration design path: `new-design-plan` or `/new-design-plan`
4. Workflow router (optional): `using-plan-and-execute`
5. Clarification and option exploration: `asking-clarifying-questions`, `brainstorming`
6. Research passes: `scientific-internet-research-pass`, `scientific-codebase-investigation-pass`
7. Readiness check: `validate-design-plan` or `/validate-design-plan --phase in-review`
8. Approval transition: `set-design-plan-status` or `/set-design-plan-status`
9. Implementation planning: `starting-an-implementation-plan` or `/start-implementation-plan`
10. Execution: `executing-an-implementation-plan` or `/execute-implementation-plan`
11. Idea refinement/customization helpers: `flesh-it-out`, `how-to-customize`

## Documentation Map

- Installation and setup: `docs/INSTALLATION.md`
- Day-1 onboarding flow: `docs/ONBOARDING.md`
- Compatibility and breaking-change policy: `docs/COMPATIBILITY.md`
- Runtime compatibility source block: `docs/runtime-compatibility.md`
- Runtime installed-path contract: `docs/installed-path-resolution.md`
- Repository attribution notice: `NOTICE`
- Repository and upstream lineage licenses: `LICENSE`, `LICENSE.superpowers`
- Release notes (three-plugin research split): `docs/releases/2026-02-23-research-plugin-split.md`
- Historical release notes (two-plugin migration): `docs/releases/2026-02-23-two-plugin-migration.md`
- Design plan templates: `plugins/scientific-plan-execute/docs/design-plans/templates/`
- Implementation plan templates: `plugins/scientific-plan-execute/docs/implementation-plans/templates/`
- Review template: `plugins/scientific-plan-execute/docs/reviews/review-template.md`
- Skill/agent IO checklist: `plugins/scientific-plan-execute/docs/checklists/skill-agent-io-checklist.md`
- Runtime compatibility sync tool: `plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py`
- Runtime path resolver: `plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`

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
