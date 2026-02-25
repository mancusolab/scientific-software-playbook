## Scientific Software Playbook (Codex Native)

Audience and intent:
1. This file is for agents and contributors developing this repository itself.
2. It defines implementation-facing contracts, internal workflow rules, and source-of-truth plugin paths.
3. For user-facing installation and usage guidance on GitHub, use `README.md`.

This repository supports one operational mode:

1. Global install mode (install into `CODEX_HOME` and run workflows directly in downstream projects).

Scope note: this repository hosts three plugins:
1. `scientific-plan-execute`
2. `scientific-research`
3. `scientific-house-style`

Operational workflow remains centered on `scientific-plan-execute`.

Dependency contract:
1. `scientific-plan-execute` is required for orchestration flow.
2. `scientific-research` is required for external-fact validation gates and research workflows.
3. `scripts/install-codex-home.sh` auto-adds `scientific-research` when `scientific-plan-execute` is selected.
4. `scientific-house-style` is optional and provides reusable guidance.
5. If house-style skills are unavailable, workflow should continue without blocking.

## Plugin Assets (Source Of Truth)

### Skills (`scientific-plan-execute`)
- `new-design-plan`: `plugins/scientific-plan-execute/skills/new-design-plan/SKILL.md`
- `validate-design-plan`: `plugins/scientific-plan-execute/skills/validate-design-plan/SKILL.md`
- `set-design-plan-status`: `plugins/scientific-plan-execute/skills/set-design-plan-status/SKILL.md`
- `start-scientific-implementation-plan`: `plugins/scientific-plan-execute/skills/start-scientific-implementation-plan/SKILL.md`
- `execute-scientific-implementation-plan`: `plugins/scientific-plan-execute/skills/execute-scientific-implementation-plan/SKILL.md`
- `starting-a-design-plan`: `plugins/scientific-plan-execute/skills/starting-a-design-plan/SKILL.md`
- `starting-an-implementation-plan`: `plugins/scientific-plan-execute/skills/starting-an-implementation-plan/SKILL.md`
- `executing-an-implementation-plan`: `plugins/scientific-plan-execute/skills/executing-an-implementation-plan/SKILL.md`
- `scientific-software-architecture`: `plugins/scientific-plan-execute/skills/scientific-software-architecture/SKILL.md`
- `simulation-for-inference-validation`: `plugins/scientific-plan-execute/skills/simulation-for-inference-validation/SKILL.md`
- `validation-first-pipeline-api`: `plugins/scientific-plan-execute/skills/validation-first-pipeline-api/SKILL.md`
- `scientific-cli-thin-shell`: `plugins/scientific-plan-execute/skills/scientific-cli-thin-shell/SKILL.md`

### Skills (`scientific-research`)
- `scientific-internet-research-pass`: `plugins/scientific-research/skills/scientific-internet-research-pass/SKILL.md`
- `scientific-codebase-investigation-pass`: `plugins/scientific-research/skills/scientific-codebase-investigation-pass/SKILL.md`

### Skills (`scientific-house-style`)
- `jax-equinox-numerics`: `plugins/scientific-house-style/skills/jax-equinox-numerics/SKILL.md`
- `project-engineering`: `plugins/scientific-house-style/skills/project-engineering/SKILL.md`
- `coding-effectively`: `plugins/scientific-house-style/skills/coding-effectively/SKILL.md`
- `functional-core-imperative-shell`: `plugins/scientific-house-style/skills/howto-functional-vs-imperative/SKILL.md`
- `property-based-testing`: `plugins/scientific-house-style/skills/property-based-testing/SKILL.md`
- `writing-for-a-technical-audience`: `plugins/scientific-house-style/skills/writing-for-a-technical-audience/SKILL.md`
- `writing-good-tests`: `plugins/scientific-house-style/skills/writing-good-tests/SKILL.md`

### Assets
- Plan-execute agents: `plugins/scientific-plan-execute/agents/`
- Plan-execute commands: `plugins/scientific-plan-execute/commands/`
- Plan-execute hooks: `plugins/scientific-plan-execute/hooks/`
- Plan-execute scripts: `plugins/scientific-plan-execute/scripts/`
- Plan-execute templates: `plugins/scientific-plan-execute/docs/design-plans/templates/`
- Plan-execute templates: `plugins/scientific-plan-execute/docs/implementation-plans/templates/`
- Runtime compatibility source: `docs/runtime-compatibility.md`
- Runtime path contract: `docs/installed-path-resolution.md`
- Runtime compatibility sync tool: `plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py`
- Runtime path resolver: `plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`
- Research agents: `plugins/scientific-research/agents/`
- Research docs: `plugins/scientific-research/docs/`
- House-style docs: `plugins/scientific-house-style/docs/`

Breaking-change contract:
1. Repository-root compatibility links are removed.
2. Plugin-scoped paths under `plugins/` are the only supported source-of-truth paths.

Execution delegates:
1. `scientific-task-implementor-fast`
2. `scientific-task-bug-fixer`
3. `scientific-code-reviewer`
4. `scientific-test-analyst`

Research delegates:
1. `codebase-investigator`
2. `internet-researcher`
3. `remote-code-researcher`
4. `combined-researcher`
5. `scientific-literature-researcher`

Simulation delegate:
1. `scientific-simulation-designer`

Script policy:
1. User-facing script usage is limited to `scripts/install-codex-home.sh`.
2. All other scripts are internal and agent-invoked from installed plugin paths.

## Global Install Mode (Required)

Install globally:

```bash
bash scripts/install-codex-home.sh --force
```

Optional selective install:

```bash
bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force
bash scripts/install-codex-home.sh --plugin scientific-research --force
bash scripts/install-codex-home.sh --plugin scientific-house-style --force
```

Run a downstream project:

1. Open the target project root in Codex.
2. Start architecture planning with `scientific-software-architecture`.

## Workflow

1. Start architecture with `scientific-software-architecture`.
2. Choose model path early:
   - `provided-model` (user-supplied model/update rules), or
   - `suggested-model` (literature-backed model candidates + explicit user selection).
3. Define simulation scope for inference validation:
   - use `simulation-for-inference-validation` when simulation-based checks are required.
4. Create plan scaffolding with `new-design-plan`.
5. Run `scientific-internet-research-pass` when external facts are uncertain.
6. Validate in review phase with `validate-design-plan` (`phase=in-review`).
7. Approve only after explicit user sign-off using `set-design-plan-status` (`approved-for-implementation`).
8. Create implementation phases and traceability with `start-scientific-implementation-plan`.
9. Execute phase-by-phase with `execute-scientific-implementation-plan`.
10. Compatibility command aliases are available for upstream parity:
   - `start-design-plan` -> `starting-a-design-plan`
   - `start-implementation-plan` -> `starting-an-implementation-plan`
   - `execute-implementation-plan` -> `executing-an-implementation-plan`
11. During phase execution, apply layer skills in order when relevant:
   - `validation-first-pipeline-api`
   - `jax-equinox-numerics` (from `scientific-house-style`, when installed)
   - `scientific-cli-thin-shell`

## Hard Stops

1. No implementation before explicit design-plan approval.
2. If model artifacts exist, mathematical sanity checks are required.
3. If explicit update rules exist, solver strategy must be documented.
4. Approval transitions must pass strict readiness validation.
5. Completion claims require TDD evidence and fresh verification output.
6. Implementation execution requires AC-to-task-to-test traceability.
7. Architecture approval requires explicit model-path decision, concrete model sources/update rules for `provided-model`, and literature-backed model evidence plus user selection for `suggested-model`.
8. If simulation-based validation is in scope, architecture approval requires an explicit simulation contract aligned to inferential assumptions.
