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
3. `scientific-house-style` is required for workflow execution and review gates.
4. `scripts/install-codex-home.sh` auto-adds `scientific-research` and `scientific-house-style` when `scientific-plan-execute` is selected.
5. Required house-style skills must be resolvable at runtime:
- `jax-equinox-numerics`
- `project-engineering`
- `coding-effectively`
6. Mandatory scientific correctness constraints remain in `scientific-plan-execute`:
   - `validation-first-pipeline-api`
   - `simulation-for-inference-validation`
7. `scientific-house-style` should carry reusable implementation-style guidance, while `scientific-plan-execute` enforces orchestration and hard-stop gates.

## Plugin Assets (Source Of Truth)

### Skills (`scientific-plan-execute`)
- `asking-clarifying-questions`: `plugins/scientific-plan-execute/skills/asking-clarifying-questions/SKILL.md`
- `brainstorming`: `plugins/scientific-plan-execute/skills/brainstorming/SKILL.md`
- `using-plan-and-execute`: `plugins/scientific-plan-execute/skills/using-plan-and-execute/SKILL.md`
- `scientific-kickoff`: `plugins/scientific-plan-execute/skills/scientific-kickoff/SKILL.md`
- `starting-a-design-plan`: `plugins/scientific-plan-execute/skills/starting-a-design-plan/SKILL.md`
- `new-design-plan`: `plugins/scientific-plan-execute/skills/new-design-plan/SKILL.md`
- `validate-design-plan`: `plugins/scientific-plan-execute/skills/validate-design-plan/SKILL.md`
- `set-design-plan-status`: `plugins/scientific-plan-execute/skills/set-design-plan-status/SKILL.md`
- `starting-an-implementation-plan`: `plugins/scientific-plan-execute/skills/starting-an-implementation-plan/SKILL.md`
- `executing-an-implementation-plan`: `plugins/scientific-plan-execute/skills/executing-an-implementation-plan/SKILL.md`
- `writing-design-plans`: `plugins/scientific-plan-execute/skills/writing-design-plans/SKILL.md`
- `writing-implementation-plans`: `plugins/scientific-plan-execute/skills/writing-implementation-plans/SKILL.md`
- `simulation-for-inference-validation`: `plugins/scientific-plan-execute/skills/simulation-for-inference-validation/SKILL.md`
- `validation-first-pipeline-api`: `plugins/scientific-plan-execute/skills/validation-first-pipeline-api/SKILL.md`
- `requesting-code-review`: `plugins/scientific-plan-execute/skills/requesting-code-review/SKILL.md`
- `verification-before-completion`: `plugins/scientific-plan-execute/skills/verification-before-completion/SKILL.md`
- `systematic-debugging`: `plugins/scientific-plan-execute/skills/systematic-debugging/SKILL.md`
- `test-driven-development`: `plugins/scientific-plan-execute/skills/test-driven-development/SKILL.md`
- `using-git-worktrees`: `plugins/scientific-plan-execute/skills/using-git-worktrees/SKILL.md`
- `finishing-a-development-branch`: `plugins/scientific-plan-execute/skills/finishing-a-development-branch/SKILL.md`

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
3. `scientific-test-analyst`

Review delegates:
1. `scientific-code-reviewer`
2. `scientific-architecture-reviewer`
3. `numerics-interface-auditor`
4. `scientific-cli-api-reviewer`
5. `scientific-inference-algorithm-reviewer`

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
2. Choose entrypoint with `using-plan-and-execute`, then continue with the suggested workflow skill/command.

## Workflow

1. Choose workflow entrypoint with `using-plan-and-execute`.
2. For general design requests, start with `starting-a-design-plan` (or `start-design-plan` command wrapper). Use `new-design-plan` when plan scaffolding is needed directly.
3. For fresh-project/model-path tracks, run `scientific-kickoff` early to choose exactly one model path:
   - `provided-model` (user-supplied model/update rules), or
   - `suggested-model` (literature-backed model candidates + explicit user selection), or
   - `existing-codebase-port` (source-pinned local directory or GitHub URL with parity targets).
   - when `existing-codebase-port` is selected, run `scientific-codebase-investigation-pass` and capture file-level findings before approval.
4. Pass kickoff output (`.scientific/kickoff.md`) into `starting-a-design-plan`; design orchestration must ingest kickoff state/evidence when present.
5. Set required workflow states before approval:
   - `model_path_decided: yes`
   - `codebase_investigation_complete_if_port: yes|n/a`
   - `simulation_contract_complete_if_in_scope: yes|n/a`
6. Define simulation scope for inference validation:
   - use `simulation-for-inference-validation` when simulation-based checks are required.
7. Validate in review phase with `validate-design-plan` (`phase=in-review`).
8. Approve only after explicit user sign-off using `set-design-plan-status` (`approved-for-implementation`).
9. Create implementation phases and traceability with `starting-an-implementation-plan` (or `start-implementation-plan` command wrapper).
10. Execute phase-by-phase with `executing-an-implementation-plan` (or `execute-implementation-plan` command wrapper).
11. During phase execution, apply layer skills in order when relevant:
   - `validation-first-pipeline-api`
   - `jax-equinox-numerics` (from `scientific-house-style`)
   - `test-driven-development` for behavior-changing work
   - `systematic-debugging` for failing tests or persistent blockers
   - `using-git-worktrees` when branch/worktree isolation is required
12. Before phase or branch completion:
   - run `requesting-code-review` for reviewer/fix closure to zero findings
   - run `verification-before-completion` to ensure fresh, command-level completion evidence

## Hard Stops

1. No implementation before explicit design-plan approval.
2. If model artifacts exist, mathematical sanity checks are required.
3. If explicit update rules exist, solver strategy must be documented.
4. Approval transitions must pass strict readiness validation.
5. Completion claims require TDD evidence and fresh verification output.
6. Implementation execution requires AC-to-task-to-test traceability.
7. Architecture approval requires explicit model-path decision:
   - concrete model sources/update rules for `provided-model`
   - literature-backed model evidence plus user selection for `suggested-model`
   - source pin plus behavior/parity inventory for `existing-codebase-port`
   - completed `scientific-codebase-investigation-pass` findings with file-level evidence for `existing-codebase-port`
8. If simulation-based validation is in scope, architecture approval requires an explicit simulation contract aligned to inferential assumptions.
9. Architecture approval requires required workflow states:
   - `model_path_decided: yes`
   - `codebase_investigation_complete_if_port: yes|n/a` (as applicable)
   - `simulation_contract_complete_if_in_scope: yes|n/a` (as applicable)
10. If CLI/API surfaces change during implementation, `scientific-cli-api-reviewer` gating is required before phase completion.
11. If inference-algorithm behavior changes during implementation, `scientific-inference-algorithm-reviewer` gating is required before phase completion.
