# Scientific Software Playbook (Claude Code + Codex)

Scientific Software Playbook is a plugin collection for scientific labs and research teams building software that performs inference for explicit scientific models.

The goal is simple: make scientific software development more reliable by adding structure where it matters most.
- decide model path and assumptions early
- validate design before implementation
- execute in phases with explicit test and review evidence

It is optimized for turning a scientific model or existing scientific implementation into robust software with explicit design decisions, staged implementation, and evidence-backed review.
It is not a general workflow for exploratory analysis, one-off notebooks, or every kind of scientific computing task.
It is also heavily tuned for Python/JAX implementations; additional implementation languages are currently out of scope,
but will be carefully included after additional testing and validation.

## What you get

This repository ships three plugins that work together:

1. `scientific-plan-execute`, Orchestrates kickoff, design planning, readiness validation, approval, implementation planning, and execution.

2. `scientific-research`, Adds research workflows for internet, literature, and codebase evidence.

3. `scientific-house-style`, Adds reusable engineering guidance for JAX/Equinox numerics and project-quality practices.

In practice, this helps scientific teams reduce avoidable rework: fewer ambiguous requirements, fewer hidden model assumptions, and clearer completion evidence.

- Architecture-first planning with explicit approval before implementation.
- Built-in clarification and brainstorming stages before architecture lock-in.
- Reusable skills, commands, and agents for phased execution.
- Specialized reviewer delegates for architecture, numerics, CLI/API contracts, and inference algorithm behavior.
- Templates for design plans, implementation plans, and review artifacts.
- A separate house-style plugin for JAX/Equinox numerics for differentiable computing and project engineering guidance.

## Workflow at a glance

```text
Rough idea
    │
    ▼
Design planning  ───────────────► Design document (committed to git)
    │
    ▼
Implementation planning  ───────► Implementation plan (phase files)
    │
    ▼
Phase execution loop  ──────────► Working code (reviewed & committed)
```

## Kickoff: when model provenance or parity still needs to be decided

### What kickoff does

`/start-scientific-kickoff` (Claude Code) and `$scientific-kickoff` (Codex) select exactly one scientific delivery path before design planning continues.

Use kickoff when you still need to decide where the model comes from or what existing implementation you are matching.
If the model and software contract are already established and you are working on a scoped feature, start with design planning instead.

Kickoff forces a single mode:
1. `provided-model`: you already have model equations/artifacts and (optionally) update rules.
2. `suggested-model`: the system proposes model-family options with citations, and you explicitly select one.
3. `existing-codebase-port`: you provide an existing source implementation and define behavior/parity targets.

Kickoff writes `.scientific/kickoff.md` with required readiness state (`model_path_decided`, codebase-investigation state for ports, and synthetic-data-validation-contract state when synthetic-data validation is in scope). Handover instructions for the next phase are provided by kickoff itself.

### Example 1: choosing a model path before implementation

> "We need a Bayesian model for longitudinal biomarker data. I have partial equations, but I’m not sure whether we should reuse an existing model family."

Recommended kickoff option:
- `provided-model`

### Example 2: porting an existing scientific codebase

> "We already have a NumPy prototype. We want a JAX implementation with parity checks before switching over."

Recommended kickoff option:
- `existing-codebase-port`

### Example 3: existing project feature iteration

> "Add simulation-based calibration checks to the current inference workflow and keep existing CLI behavior stable."

Recommended entrypoint:
- Start with design planning directly; kickoff is not required

## Installation
For full setup and troubleshooting, use `docs/INSTALLATION.md`.

### Codex

```bash
git clone https://github.com/mancusolab/scientific-software-playbook.git
cd scientific-software-playbook
bash scripts/install-codex-home.sh --force
```

### Claude Code

```text
/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git
/plugin install scientific-plan-execute@scientific-software-playbook
/plugin install scientific-research@scientific-software-playbook
/plugin install scientific-house-style@scientific-software-playbook
/plugin reload
```


## Where to go next

1. Day-1 workflow guide: `docs/ONBOARDING.md`
2. Tutorial — kickoff and design plan (LDSC port example): `docs/tutorial-kickoff-and-design-plan.md`
3. Installation and troubleshooting: `docs/INSTALLATION.md`
4. Internal contracts and hard stops: `AGENTS.md`

## License and attribution

This repository is heavily inspired by [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) and builds directly on
that ecosystem's workflow patterns.

1. Repository and plugin content license: `LICENSE`
2. Upstream lineage license: `LICENSE.superpowers`
3. Provenance details: `NOTICE`
