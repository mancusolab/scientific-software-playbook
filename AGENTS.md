## Scientific Software Playbook (Codex Native)

This repository can be used in two modes:

1. Local repository mode (open this repo directly in Codex).
2. Global install mode (install into `CODEX_HOME` and bootstrap downstream projects).

Scope note: this is a single playbook plugin (plan-and-execute style), not a
multi-plugin catalog.

## Local Repository Mode

### Local skills
- `install-scientific-software-playbook-home`: `skills/install-scientific-software-playbook-home/SKILL.md`
- `bootstrap-scientific-software-playbook`: `skills/bootstrap-scientific-software-playbook/SKILL.md`
- `new-design-plan`: `skills/new-design-plan/SKILL.md`
- `validate-design-plan`: `skills/validate-design-plan/SKILL.md`
- `set-design-plan-status`: `skills/set-design-plan-status/SKILL.md`
- `start-scientific-implementation-plan`: `skills/start-scientific-implementation-plan/SKILL.md`
- `execute-scientific-implementation-plan`: `skills/execute-scientific-implementation-plan/SKILL.md`
- `scientific-internet-research-pass`: `skills/scientific-internet-research-pass/SKILL.md`
- `scientific-software-architecture`: `skills/scientific-software-architecture/SKILL.md`
- `simulation-for-inference-validation`: `skills/simulation-for-inference-validation/SKILL.md`
- `ingress-to-canonical-jax`: `skills/ingress-to-canonical-jax/SKILL.md`
- `validation-first-pipeline-api`: `skills/validation-first-pipeline-api/SKILL.md`
- `jax-equinox-core-numerics-shell`: `skills/jax-equinox-core-numerics-shell/SKILL.md`
- `scientific-cli-thin-shell`: `skills/scientific-cli-thin-shell/SKILL.md`

### Local assets
- Agents: `agents/`
- Commands: `commands/`
- Hooks: `hooks/`
- Scripts: `scripts/` (internal utilities invoked by commands/skills/hooks)
- Templates: `docs/design-plans/templates/`
- Templates: `docs/implementation-plans/templates/`

Execution delegates:
1. `scientific-task-implementor-fast`
2. `scientific-task-bug-fixer`
3. `scientific-test-analyst`

Research delegate:
1. `scientific-internet-researcher`

Simulation delegate:
1. `scientific-simulation-designer`

Script policy:
1. User-facing script usage is limited to `scripts/install-codex-home.sh`.
2. All other scripts are internal and agent-invoked.

## Global Install Mode (Recommended For Reuse)

Install globally:

```bash
bash scripts/install-codex-home.sh --force
```

Bootstrap a downstream project:

1. Open the target project root in Codex.
2. Invoke `bootstrap-scientific-software-playbook`.

The bootstrap command installs project-local assets and writes project `AGENTS.md`
that references globally installed skills in `CODEX_HOME`.

`bootstrap-scientific-software-playbook` is a convenience wrapper for Codex users:
from the current project root, it runs the installed bootstrap script and verifies
required playbook files are present. It is only needed once per downstream project.

## Workflow

1. If this project is not bootstrapped yet, run `bootstrap-scientific-software-playbook`.
2. Start architecture with `scientific-software-architecture`.
3. Choose model path early:
   - `provided-model` (user-supplied model/update rules), or
   - `suggested-model` (literature-backed model candidates + explicit user selection).
4. Define simulation scope for inference validation:
   - use `simulation-for-inference-validation` when simulation-based checks are required.
5. Create plan scaffolding with `new-design-plan`.
6. Run `scientific-internet-research-pass` when external facts are uncertain.
7. Validate in review phase with `validate-design-plan` (`phase=in-review`).
8. Approve only after explicit user sign-off using `set-design-plan-status` (`approved-for-implementation`).
9. Create implementation phases and traceability with `start-scientific-implementation-plan`.
10. Execute phase-by-phase with `execute-scientific-implementation-plan`.
11. During phase execution, apply layer skills in order when relevant:
   - `ingress-to-canonical-jax`
   - `validation-first-pipeline-api`
   - `jax-equinox-core-numerics-shell`
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
