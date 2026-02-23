# Scientific Software Playbook (Claude + Codex)

This repository defines a reusable plugin scaffold for building scientific software with:

1. Architecture-first planning.
2. Strict ingress-to-canonical-data boundaries.
3. Validation-first pipelines.
4. Thin, transform-safe numerics shells.
5. CLI contract discipline.

It is designed for teams that want hard gates before implementation and reproducible review artifacts.

## Scope

This repository is intentionally structured as a single playbook plugin, similar in
scope to `ed3d-plan-and-execute`:

1. One cohesive workflow.
2. Modular skills/agents/commands inside the same plugin.
3. No plugin marketplace/catalog layering.

## Install and First Use

1. GitHub install + Codex/Claude setup:
- `docs/INSTALLATION.md`

2. Day-1 workflow:
- `docs/ONBOARDING.md`

Codex install step:

```bash
bash scripts/install-codex-home.sh --force
```

## What This Project Contains

1. Runtime integration:
- `.claude-plugin/plugin.json`
- `hooks/hooks.json`
- `AGENTS.md` (Codex-native project contract)

2. Skills:
- `skills/install-scientific-software-playbook-home/SKILL.md`
- `skills/bootstrap-scientific-software-playbook/SKILL.md`
- `skills/new-design-plan/SKILL.md`
- `skills/validate-design-plan/SKILL.md`
- `skills/set-design-plan-status/SKILL.md`
- `skills/start-scientific-implementation-plan/SKILL.md`
- `skills/execute-scientific-implementation-plan/SKILL.md`
- `skills/scientific-internet-research-pass/SKILL.md`
- `skills/scientific-software-architecture/SKILL.md`
- `skills/simulation-for-inference-validation/SKILL.md`
- `skills/ingress-to-canonical-jax/SKILL.md`
- `skills/validation-first-pipeline-api/SKILL.md`
- `skills/jax-equinox-core-numerics-shell/SKILL.md`
- `skills/scientific-cli-thin-shell/SKILL.md`

3. Agents:
- `agents/scientific-architecture-planner.md`
- `agents/scientific-architecture-reviewer.md`
- `agents/scientific-simulation-designer.md`
- `agents/numerics-interface-auditor.md`
- `agents/scientific-internet-researcher.md`
- `agents/scientific-task-implementor-fast.md`
- `agents/scientific-task-bug-fixer.md`
- `agents/scientific-test-analyst.md`

4. Commands:
- `commands/start-scientific-architecture.md`
- `commands/start-simulation-validation.md`
- `commands/new-design-plan.md`
- `commands/set-design-plan-status.md`
- `commands/validate-design-plan.md`
- `commands/start-scientific-implementation-plan.md`
- `commands/execute-scientific-implementation-plan.md`

5. Hooks and internal scripts:
- `hooks/hooks.json`
- `scripts/hooks/session-start.sh`
- `scripts/hooks/post-edit.sh`
- `scripts/hooks/stop.sh`

6. Plan/review templates:
- `docs/design-plans/templates/scientific-architecture-plan-template.md`
- `docs/design-plans/templates/artifacts/*.md`
- `docs/implementation-plans/templates/*.md`
- `docs/reviews/review-template.md`

Simulation implementation template:
- `docs/implementation-plans/templates/phase-simulation-validation-template.md`

Internal script policy:
1. Users should run only `scripts/install-codex-home.sh` directly.
2. All other scripts are internal and invoked by commands, skills, hooks, or agents.


## End-to-End Workflow

1. Kick off architecture:
- Claude path: run `/start-scientific-architecture <slug>`
- Codex path:
  - If needed, bootstrap current repo with `bootstrap-scientific-software-playbook`
  - Then start with `scientific-software-architecture` (see `docs/INSTALLATION.md`)
  - `bootstrap-scientific-software-playbook` only initializes the current project with playbook assets and `AGENTS.md`; it is not an implementation skill.

2. Fill the plan and companion artifacts:
- Claude: `/new-design-plan <slug>` when the plan file does not exist.
- Codex: invoke `new-design-plan` when plan scaffolding is needed.
- Choose model path early:
  - `provided-model` (user supplies model/update rules), or
  - `suggested-model` (literature-backed model options + explicit user selection).
- If inference validation needs synthetic-data checks, add simulation design with `simulation-for-inference-validation`.
- Claude shortcut for simulation design: `/start-simulation-validation [design-plan-path]`.
- Run `scientific-internet-research-pass` when external facts are uncertain.
- Model symbol table.
- Equation-to-code map.
- Solver feasibility matrix.

3. Keep status in review:
- Claude path: `/set-design-plan-status <plan-path> in-review`
- Codex path: invoke `set-design-plan-status` with `in-review`

4. Validate readiness:
- Claude path: `/validate-design-plan <plan-path> --phase in-review`
- Codex path: invoke `validate-design-plan` with phase `in-review`

5. Approve plan only after readiness passes:
- Claude path: `/set-design-plan-status <plan-path> approved-for-implementation`
- Codex path: invoke `set-design-plan-status` with `approved-for-implementation`
- Both paths enforce strict approval validation.

6. If approved plans change, move back to review:
- Claude path: `/set-design-plan-status <plan-path> in-review`
- Codex path: invoke `set-design-plan-status` with `in-review`

7. Create implementation orchestration artifacts:
- Claude path: `/start-scientific-implementation-plan <design-plan-path> [slug]`
- Codex path: invoke `start-scientific-implementation-plan`
- Capture the absolute implementation plan path from command output.
- Recommended: run execution in a fresh session/context after planning is complete.
- If simulation scope is `yes`, include a dedicated simulation-validation `phase_XX.md` using `phase-simulation-validation-template.md`.

8. Execute the implementation plan phases:
- Claude path: `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`
- Codex path: invoke `execute-scientific-implementation-plan` with the same absolute path
- Execution delegates:
  - `scientific-task-implementor-fast`
  - `scientific-task-bug-fixer`
  - `scientific-test-analyst`
- During execution, delegate evidence must be surfaced after each delegate run (tests, findings, blockers, commits).

9. During phase execution, apply layer skills in this order when relevant:
- `ingress-to-canonical-jax`
- `validation-first-pipeline-api`
- `jax-equinox-core-numerics-shell`
- `scientific-cli-thin-shell`

10. Run both reviewers and save review artifacts.

## Operator Checklist

Use this as the minimum go/no-go checklist for a new project:

1. [ ] Playbook is installed and project is bootstrapped (`scripts/install-codex-home.sh`, then `bootstrap-scientific-software-playbook` in Codex if needed).
2. [ ] Architecture kickoff completed with explicit goals, inputs, outputs, and CLI shape.
3. [ ] Model path chosen and recorded: `provided-model` or `suggested-model`.
4. [ ] Solver strategy recorded: custom updates, existing solver, or comparison path.
5. [ ] Model artifacts (if provided) passed mathematical sanity checks and are traceable.
6. [ ] External uncertain claims are cited via `scientific-internet-research-pass`.
7. [ ] Design status advanced to `in-review`, then validated with `validate-design-plan`.
8. [ ] Explicit user sign-off captured and status set to `approved-for-implementation`.
9. [ ] Implementation plan generated with complete AC-to-task-to-test mapping.
10. [ ] If simulation scope is `yes`, dedicated simulation-validation phase and mappings exist.
11. [ ] Execution run phase-by-phase with TDD and reviewer/fix loops.
12. [ ] Final completion declared only with fresh verification evidence and test-analyst coverage pass.

## Hard Stops

1. No implementation before explicit plan approval.
2. If model artifacts exist, mathematical sanity checks are required.
3. If update rules exist, solver strategy decision is required.
4. Model path must be explicit: `provided-model` (with concrete sources/rules) or `suggested-model` (with literature-backed candidates and user selection).
5. If simulation-based validation is in scope, simulation contract (`simulate` inputs/outputs/seed policy + validation experiments) must be explicit.
6. Approval transition is blocked unless readiness validation passes.
7. TDD and fresh verification evidence are required before completion claims.
8. Implementation execution is blocked unless AC-to-task-to-test traceability is complete.

## Readiness Scoring

Use weighted gate checks in:
- `docs/reviews/review-template.md`
- `docs/checklists/skill-agent-io-checklist.md`

Note:
- `/validate-design-plan` and `validate-design-plan` both run the same phase-aware pass/fail validator.
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
