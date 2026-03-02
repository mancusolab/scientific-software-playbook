# Scientific Software Playbook ![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=flat-square&logo=claude&logoColor=white) ![Codex CLI](https://img.shields.io/badge/Codex_CLI-000000?style=flat-square&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTIyLjI4MiA5LjgyMWE2IDYgMCAwIDAtLjUxNi00LjkxYTYuMDUgNi4wNSAwIDAgMC02LjUxLTIuOUE2LjA2NSA2LjA2NSAwIDAgMCA0Ljk4MSA0LjE4YTYgNiAwIDAgMC0zLjk5OCAyLjlhNi4wNSA2LjA1IDAgMCAwIC43NDMgNy4wOTdhNS45OCA1Ljk4IDAgMCAwIC41MSA0LjkxMWE2LjA1IDYuMDUgMCAwIDAgNi41MTUgMi45QTYgNiAwIDAgMCAxMy4yNiAyNGE2LjA2IDYuMDYgMCAwIDAgNS43NzItNC4yMDZhNiA2IDAgMCAwIDMuOTk3LTIuOWE2LjA2IDYuMDYgMCAwIDAtLjc0Ny03LjA3M00xMy4yNiAyMi40M2E0LjQ4IDQuNDggMCAwIDEtMi44NzYtMS4wNGwuMTQxLS4wODFsNC43NzktMi43NThhLjguOCAwIDAgMCAuMzkyLS42ODF2LTYuNzM3bDIuMDIgMS4xNjhhLjA3LjA3IDAgMCAxIC4wMzguMDUydjUuNTgzYTQuNTA0IDQuNTA0IDAgMCAxLTQuNDk0IDQuNDk0TTMuNiAxOC4zMDRhNC40NyA0LjQ3IDAgMCAxLS41MzUtMy4wMTRsLjE0Mi4wODVsNC43ODMgMi43NTlhLjc3Ljc3IDAgMCAwIC43OCAwbDUuODQzLTMuMzY5djIuMzMyYS4wOC4wOCAwIDAgMS0uMDMzLjA2Mkw5Ljc0IDE5Ljk1YTQuNSA0LjUgMCAwIDEtNi4xNC0xLjY0Nk0yLjM0IDcuODk2YTQuNSA0LjUgMCAwIDEgMi4zNjYtMS45NzNWMTEuNmEuNzcuNzcgMCAwIDAgLjM4OC42NzdsNS44MTUgMy4zNTRsLTIuMDIgMS4xNjhhLjA4LjA4IDAgMCAxLS4wNzEgMGwtNC44My0yLjc4NkE0LjUwNCA0LjUwNCAwIDAgMSAyLjM0IDcuODcyem0xNi41OTcgMy44NTVsLTUuODMzLTMuMzg3TDE1LjExOSA3LjJhLjA4LjA4IDAgMCAxIC4wNzEgMGw0LjgzIDIuNzkxYTQuNDk0IDQuNDk0IDAgMCAxLS42NzYgOC4xMDV2LTUuNjc4YS43OS43OSAwIDAgMC0uNDA3LS42NjdtMi4wMS0zLjAyM2wtLjE0MS0uMDg1bC00Ljc3NC0yLjc4MmEuNzguNzggMCAwIDAtLjc4NSAwTDkuNDA5IDkuMjNWNi44OTdhLjA3LjA3IDAgMCAxIC4wMjgtLjA2MWw0LjgzLTIuNzg3YTQuNSA0LjUgMCAwIDEgNi42OCA0LjY2em0tMTIuNjQgNC4xMzVsLTIuMDItMS4xNjRhLjA4LjA4IDAgMCAxLS4wMzgtLjA1N1Y2LjA3NWE0LjUgNC41IDAgMCAxIDcuMzc1LTMuNDUzbC0uMTQyLjA4TDguNzA0IDUuNDZhLjguOCAwIDAgMC0uMzkzLjY4MXptMS4wOTctMi4zNjVsMi42MDItMS41bDIuNjA3IDEuNXYyLjk5OWwtMi41OTcgMS41bC0yLjYwNy0xLjVaIi8+PC9zdmc+)

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

### ![Codex CLI](https://img.shields.io/badge/Codex_CLI-000000?style=flat-square&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTIyLjI4MiA5LjgyMWE2IDYgMCAwIDAtLjUxNi00LjkxYTYuMDUgNi4wNSAwIDAgMC02LjUxLTIuOUE2LjA2NSA2LjA2NSAwIDAgMCA0Ljk4MSA0LjE4YTYgNiAwIDAgMC0zLjk5OCAyLjlhNi4wNSA2LjA1IDAgMCAwIC43NDMgNy4wOTdhNS45OCA1Ljk4IDAgMCAwIC41MSA0LjkxMWE2LjA1IDYuMDUgMCAwIDAgNi41MTUgMi45QTYgNiAwIDAgMCAxMy4yNiAyNGE2LjA2IDYuMDYgMCAwIDAgNS43NzItNC4yMDZhNiA2IDAgMCAwIDMuOTk3LTIuOWE2LjA2IDYuMDYgMCAwIDAtLjc0Ny03LjA3M00xMy4yNiAyMi40M2E0LjQ4IDQuNDggMCAwIDEtMi44NzYtMS4wNGwuMTQxLS4wODFsNC43NzktMi43NThhLjguOCAwIDAgMCAuMzkyLS42ODF2LTYuNzM3bDIuMDIgMS4xNjhhLjA3LjA3IDAgMCAxIC4wMzguMDUydjUuNTgzYTQuNTA0IDQuNTA0IDAgMCAxLTQuNDk0IDQuNDk0TTMuNiAxOC4zMDRhNC40NyA0LjQ3IDAgMCAxLS41MzUtMy4wMTRsLjE0Mi4wODVsNC43ODMgMi43NTlhLjc3Ljc3IDAgMCAwIC43OCAwbDUuODQzLTMuMzY5djIuMzMyYS4wOC4wOCAwIDAgMS0uMDMzLjA2Mkw5Ljc0IDE5Ljk1YTQuNSA0LjUgMCAwIDEtNi4xNC0xLjY0Nk0yLjM0IDcuODk2YTQuNSA0LjUgMCAwIDEgMi4zNjYtMS45NzNWMTEuNmEuNzcuNzcgMCAwIDAgLjM4OC42NzdsNS44MTUgMy4zNTRsLTIuMDIgMS4xNjhhLjA4LjA4IDAgMCAxLS4wNzEgMGwtNC44My0yLjc4NkE0LjUwNCA0LjUwNCAwIDAgMSAyLjM0IDcuODcyem0xNi41OTcgMy44NTVsLTUuODMzLTMuMzg3TDE1LjExOSA3LjJhLjA4LjA4IDAgMCAxIC4wNzEgMGw0LjgzIDIuNzkxYTQuNDk0IDQuNDk0IDAgMCAxLS42NzYgOC4xMDV2LTUuNjc4YS43OS43OSAwIDAgMC0uNDA3LS42NjdtMi4wMS0zLjAyM2wtLjE0MS0uMDg1bC00Ljc3NC0yLjc4MmEuNzguNzggMCAwIDAtLjc4NSAwTDkuNDA5IDkuMjNWNi44OTdhLjA3LjA3IDAgMCAxIC4wMjgtLjA2MWw0LjgzLTIuNzg3YTQuNSA0LjUgMCAwIDEgNi42OCA0LjY2em0tMTIuNjQgNC4xMzVsLTIuMDItMS4xNjRhLjA4LjA4IDAgMCAxLS4wMzgtLjA1N1Y2LjA3NWE0LjUgNC41IDAgMCAxIDcuMzc1LTMuNDUzbC0uMTQyLjA4TDguNzA0IDUuNDZhLjguOCAwIDAgMC0uMzkzLjY4MXptMS4wOTctMi4zNjVsMi42MDItMS41bDIuNjA3IDEuNXYyLjk5OWwtMi41OTcgMS41bC0yLjYwNy0xLjVaIi8+PC9zdmc+)

```bash
git clone https://github.com/mancusolab/scientific-software-playbook.git
cd scientific-software-playbook
bash scripts/install-codex-home.sh --force
```

### ![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=flat-square&logo=claude&logoColor=white)

Because this is a private repository, Claude Code needs a GitHub token to fetch the plugin.

1. **Create a GitHub Personal Access Token**
   - Go to **GitHub → Settings → Developer settings → Personal access tokens**
   - Choose **Tokens (classic)** with `repo` scope, or **Fine-grained tokens** with repository read access

2. **Set the environment variable**

   For the current session:
   ```bash
   export GITHUB_TOKEN=ghp_your_token_here
   ```

   For persistence, add the export to your shell profile (`~/.zshrc` or `~/.bashrc`):
   ```bash
   echo 'export GITHUB_TOKEN=ghp_your_token_here' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Install the plugins**

   ```text
   /plugin marketplace add https://github.com/mancusolab/scientific-software-playbook.git
   /plugin install scientific-plan-execute@scientific-software-playbook
   /plugin install scientific-research@scientific-software-playbook
   /plugin install scientific-house-style@scientific-software-playbook
   /plugin reload
   ```


## Where to go next

1. Day-1 workflow guide: `docs/ONBOARDING.md`
2. Tutorial (LDSC JAX port walkthrough): `docs/Tutorial-an-example-walkthrough.md`
3. Installation and troubleshooting: `docs/INSTALLATION.md`
4. Internal contracts and hard stops: `AGENTS.md`

## License and attribution

This repository is heavily inspired by [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) and builds directly on
that ecosystem's workflow patterns.

1. Repository and plugin content license: `LICENSE`
2. Upstream lineage license: `LICENSE.superpowers`
3. Provenance details: `NOTICE`
