# Scientific Software Playbook (Claude + Codex)

This repository defines a reusable plugin scaffold for building scientific software with:

1. Architecture-first planning.
2. Strict ingress-to-canonical-data boundaries.
3. Validation-first pipelines.
4. Thin, transform-safe numerics shells.
5. CLI contract discipline.

It is designed for teams that want hard gates before implementation and reproducible review artifacts.

## Install and First Use

1. GitHub install + Codex/Claude setup:
- `docs/INSTALLATION.md`

2. Day-1 workflow:
- `docs/ONBOARDING.md`

## What This Project Contains

1. Runtime integration:
- `.claude-plugin/plugin.json`
- `AGENTS.md` (Codex-native project contract)

2. Skills:
- `skills/bootstrap-scientific-software-playbook/SKILL.md`
- `skills/scientific-software-architecture/SKILL.md`
- `skills/ingress-to-canonical-jax/SKILL.md`
- `skills/validation-first-pipeline-api/SKILL.md`
- `skills/jax-equinox-core-numerics-shell/SKILL.md`
- `skills/scientific-cli-thin-shell/SKILL.md`

3. Agents:
- `agents/scientific-architecture-planner.md`
- `agents/scientific-architecture-reviewer.md`
- `agents/numerics-interface-auditor.md`

4. Commands:
- `commands/start-scientific-architecture.md`
- `commands/new-design-plan.md`
- `commands/set-design-plan-status.md`
- `commands/validate-design-plan.md`

5. Plan/review templates:
- `docs/design-plans/templates/scientific-architecture-plan-template.md`
- `docs/design-plans/templates/artifacts/*.md`
- `docs/reviews/review-template.md`

6. Operational scripts:
- `scripts/new-design-plan.sh`
- `scripts/set-design-plan-status.sh`
- `scripts/validate-design-plan-readiness.sh`
- `scripts/install-codex-home.sh`
- `scripts/bootstrap-scientific-software-playbook.sh`

## End-to-End Workflow

1. Kick off architecture:
- Claude path: run `/start-scientific-architecture <slug>`
- Codex path:
  - If needed, bootstrap current repo with `bootstrap-scientific-software-playbook`
  - Then start with `scientific-software-architecture` (see `docs/INSTALLATION.md`)
  - `bootstrap-scientific-software-playbook` only initializes the current project with playbook assets and `AGENTS.md`; it is not an implementation skill.

2. Fill the plan and companion artifacts:
- Model symbol table.
- Equation-to-code map.
- Solver feasibility matrix.

3. Keep status in review:
- `scripts/set-design-plan-status.sh <plan-path> in-review`

4. Validate readiness:
- Draft review pass:
  `scripts/validate-design-plan-readiness.sh <plan-path> --phase in-review`

5. Approve plan only after readiness passes:
- `scripts/set-design-plan-status.sh <plan-path> approved-for-implementation`
  (this runs strict approval validation automatically)

6. If approved plans change, move back to review:
- `scripts/set-design-plan-status.sh <plan-path> in-review`

7. Implement using skills in order:
- `ingress-to-canonical-jax`
- `validation-first-pipeline-api`
- `jax-equinox-core-numerics-shell`
- `scientific-cli-thin-shell`

8. Run both reviewers and save review artifacts.

## Hard Stops

1. No implementation before explicit plan approval.
2. If model artifacts exist, mathematical sanity checks are required.
3. If update rules exist, solver strategy decision is required.
4. Approval transition is blocked unless readiness validation passes.
5. TDD and fresh verification evidence are required before completion claims.

## Readiness Scoring

Use weighted gate checks in:
- `docs/reviews/review-template.md`
- `docs/checklists/skill-agent-io-checklist.md`

Note:
- `scripts/validate-design-plan-readiness.sh` is a phase-aware pass/fail validator.
- Weighted scoring is recorded in review artifacts, not emitted by the validator script.

Recommended threshold:
1. No hard-stop failures.
2. Weighted score >= 90.

## Additional Docs

1. Onboarding:
- `docs/ONBOARDING.md`

2. Codex-native project contract:
- `AGENTS.md`

3. Current example design plan:
- `docs/design-plans/2026-02-22-scientific-software-playbook.md`
  (illustrative snapshot; may not satisfy strict readiness validation)

4. Skill/agent IO checklist:
- `docs/checklists/skill-agent-io-checklist.md`
