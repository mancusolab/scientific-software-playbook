# Scientific Software Playbook Onboarding

Use this workflow when starting from scratch or adding a major feature.

Before running this flow on a fresh clone, complete setup in:
`docs/INSTALLATION.md`

For Codex reuse across repositories, use the global install + downstream bootstrap
steps from `docs/INSTALLATION.md` first.

## Phase Workflow

1. Architecture kickoff
- Claude path: run `/start-scientific-architecture <slug>`.
- Codex path:
  - If this repo is not bootstrapped yet, invoke `bootstrap-scientific-software-playbook`.
  - Use `scientific-software-architecture` directly (see `AGENTS.md`).
  - `bootstrap-scientific-software-playbook` is a one-time project initializer, not an implementation stage.
- Outcome: design plan in `docs/design-plans/YYYY-MM-DD-<slug>.md`.
- Typical status flow: `Draft` (initial scaffold) -> `In Review` (after first planning pass).

2. Plan review and approval
- Review the plan and companion artifacts:
  - `model-symbol-table.md`
  - `equation-to-code-map.md`
  - `solver-feasibility-matrix.md`
- Validate readiness before approval:
`scripts/validate-design-plan-readiness.sh <plan-path> --phase in-review`
- Move status to approved only when architecture and math checks are acceptable:
`scripts/set-design-plan-status.sh <plan-path> approved-for-implementation`
- If approved plans are revised later, move back to review:
`scripts/set-design-plan-status.sh <plan-path> in-review`

3. Implementation sequence
- `ingress-to-canonical-jax`
- `validation-first-pipeline-api`
- `jax-equinox-core-numerics-shell`
- `scientific-cli-thin-shell`

4. Review and completion
- Run `scientific-architecture-reviewer`.
- Run `numerics-interface-auditor`.
- Verify fresh test/check command evidence before claiming completion.

## Plan Utilities

1. Create plan + artifact stubs:
`scripts/new-design-plan.sh <slug>`

2. Change plan status:
`scripts/set-design-plan-status.sh <plan-path> <draft|in-review|approved-for-implementation>`

3. Validate plan readiness:
`scripts/validate-design-plan-readiness.sh <plan-path> --phase in-review`

## Non-Negotiable Gates

1. No implementation before explicit plan approval.
2. If model artifacts exist, math sanity checks are required.
3. If update rules exist, solver strategy decision is required.
4. TDD and fresh verification evidence are required before completion.
