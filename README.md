# Scientific Software Playbook

Scientific Software Playbook adds a structured workflow to Codex and Claude Code for scientific teams building software from explicit models or existing implementations. It helps teams choose the right model path, validate design decisions before coding, and ship implementation work with review and verification evidence.

It is designed for scientific software that performs inference from a defined model or matches an existing scientific implementation. It is optimized for Python and JAX workflows.

## Why this exists

Scientific software projects often break down before the code does. Teams start implementing before the model path is clear. Ports drift from the reference implementation. Validation assumptions stay implicit. Work gets marked complete without fresh evidence.

This repository is designed to prevent those failures by making the critical decisions explicit:
- what model or source implementation the project is based on
- what design has been approved
- what implementation tasks follow from that design
- what tests, reviews, and verification steps support completion

## What this helps scientific teams do

Use this repository to:

- turn model equations into tested scientific software
- choose a model family before implementation starts
- port an existing NumPy or SciPy implementation to JAX with parity targets
- add design, testing, review, and verification gates to an existing inference workflow

## Who this is for

### Good fit

- scientific teams building inference software from explicit models
- research teams turning prototypes into maintainable software
- teams porting scientific implementations to JAX
- projects where model assumptions and validation strategy must be documented

### Not a good fit

- exploratory notebooks
- one-off analyses
- general-purpose software projects
- workflows without a model or implementation contract

## How the workflow works

The workflow has four stages:

1. `kickoff`
   Decide where the model comes from, or what existing implementation you are matching.

2. `design plan`
   Define the architecture before coding starts.

3. `implementation plan`
   Break approved work into phases.

4. `execution`
   Implement with tests, review, and verification.

## Choose your entrypoint

### `provided-model`

Use this when your team already has equations, model structure, or update rules.

### `suggested-model`

Use this when your team knows the scientific problem but has not yet chosen a model family.

### `existing-codebase-port`

Use this when your team already has a reference implementation and wants to port it or match its behavior.

### Skip kickoff and start with design planning when:

- the model and software contract are already established
- the work is a scoped feature or iteration on an existing project

## Example use cases

### Implement an existing model

> "We already have the model equations for our assay and want a tested JAX implementation."

Recommended entrypoint:
- `provided-model`

### Choose a model family before building

> "We need a Bayesian model for longitudinal biomarker data, but we have not chosen a model family yet."

Recommended entrypoint:
- `suggested-model`

### Port an existing implementation

> "We have a NumPy prototype and want a JAX port with parity checks before switching over."

Recommended entrypoint:
- `existing-codebase-port`

### Add a scoped feature to an existing workflow

> "Add simulation-based calibration checks to the current inference workflow and keep CLI behavior stable."

Recommended entrypoint:
- start with design planning directly

## Quick start

For full setup and troubleshooting, see `docs/INSTALLATION.md`.

### Codex

Install:

```bash
git clone https://github.com/mancusolab/scientific-software-playbook.git
cd scientific-software-playbook
bash scripts/install-codex-home.sh --force
```

Then open your scientific software project in Codex and start with:

```text
$using-plan-and-execute
```

### Claude Code

Install:

```text
/plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git
/plugin install scientific-plan-execute@scientific-software-playbook
/plugin install scientific-research@scientific-software-playbook
/plugin install scientific-house-style@scientific-software-playbook
/plugin reload
```

Then open your scientific software project and start with:

```text
/use-skill using-plan-and-execute
```

## What gets installed

This repository ships three plugins:

- `scientific-plan-execute`
  The main workflow plugin. Most scientific teams start here.
- `scientific-research`
  Adds internet, literature, and codebase investigation workflows.
- `scientific-house-style`
  Adds engineering guidance for JAX/Equinox numerics, Polars data-engineering boundaries, and project quality.

## What the workflow produces

A typical run produces artifacts such as:

- `.scientific/kickoff.md`
- design plan documents
- implementation phase plans
- review findings and follow-up fixes
- fresh verification evidence before completion

## Where to go next

- Day-1 workflow guide: `docs/ONBOARDING.md`
- Installation and troubleshooting: `docs/INSTALLATION.md`

## For contributors and maintainers

Contributor-facing workflow contracts and internal implementation guidance live in `AGENTS.md`.

## License and attribution

This repository is heavily inspired by [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) and builds directly on that ecosystem's workflow patterns.

1. Repository and plugin content license: `LICENSE`
2. Upstream lineage license: `LICENSE.superpowers`
3. Provenance details: `NOTICE`
