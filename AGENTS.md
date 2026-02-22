## Scientific Software Playbook (Codex Native)

This repository can be used in two modes:

1. Local repository mode (open this repo directly in Codex).
2. Global install mode (install into `CODEX_HOME` and bootstrap downstream projects).

## Local Repository Mode

### Local skills
- `bootstrap-scientific-software-playbook`: `skills/bootstrap-scientific-software-playbook/SKILL.md`
- `scientific-software-architecture`: `skills/scientific-software-architecture/SKILL.md`
- `ingress-to-canonical-jax`: `skills/ingress-to-canonical-jax/SKILL.md`
- `validation-first-pipeline-api`: `skills/validation-first-pipeline-api/SKILL.md`
- `jax-equinox-core-numerics-shell`: `skills/jax-equinox-core-numerics-shell/SKILL.md`
- `scientific-cli-thin-shell`: `skills/scientific-cli-thin-shell/SKILL.md`

### Local assets
- Agents: `agents/`
- Commands: `commands/`
- Scripts: `scripts/`
- Templates: `docs/design-plans/templates/`

## Global Install Mode (Recommended For Reuse)

Install globally:

```bash
bash scripts/install-codex-home.sh --force
```

Bootstrap a downstream project:

```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh" /path/to/project --force
```

The bootstrap command installs project-local assets and writes project `AGENTS.md`
that references globally installed skills in `CODEX_HOME`.

`bootstrap-scientific-software-playbook` is a convenience wrapper for Codex users:
from the current project root, it runs the installed bootstrap script and verifies
required playbook files are present. It is only needed once per downstream project.

## Workflow

1. If this project is not bootstrapped yet, run `bootstrap-scientific-software-playbook`.
2. Start architecture with `scientific-software-architecture`.
3. Create plan scaffolding:
   - `bash scripts/new-design-plan.sh <slug>`
4. Validate in review phase:
   - `bash scripts/validate-design-plan-readiness.sh <plan-path> --phase in-review`
5. Approve only after explicit user sign-off:
   - `bash scripts/set-design-plan-status.sh <plan-path> approved-for-implementation`
6. Implement in order:
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
