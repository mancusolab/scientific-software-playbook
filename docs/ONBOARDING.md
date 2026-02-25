# Scientific Software Playbook Onboarding

Use this workflow when starting from scratch or adding a major feature.

Before running this flow on a fresh clone, complete setup in:
`docs/INSTALLATION.md`

For Codex reuse across repositories, use the global install
steps from `docs/INSTALLATION.md` first.

Plugin prerequisite:
1. This onboarding flow requires `scientific-plan-execute`.
2. This onboarding flow also requires `scientific-research` for research-gated steps.
3. `scientific-house-style` is optional and supplements numerics/project-engineering guidance.
4. If only `scientific-house-style` is installed, workflow commands in this guide will not resolve.
5. Compatibility and breaking-change path policy is documented in `docs/COMPATIBILITY.md`.

## Phase Workflow

1. Architecture kickoff
- Claude Code path: run `/start-scientific-architecture <slug>`.
- Codex path:
  - Use `scientific-software-architecture` directly (see `AGENTS.md`).
  - Playbook scripts/templates are loaded from `CODEX_HOME`, while plan/review outputs are created in the current project.
- Choose one model path early:
  - `provided-model`: user supplies model artifacts/update rules.
  - `suggested-model`: planner proposes literature-backed model options and user selects.
- If inference validation should include synthetic-data checks, define simulation contract:
  - Claude Code: `/start-simulation-validation <plan-path>`
  - Codex: invoke `simulation-for-inference-validation`
- If external facts are uncertain (API behavior, format specs, standards), run `scientific-internet-research-pass`.
- Delegate `internet-researcher` for general/API internet research needs.
- Delegate `scientific-literature-researcher` when literature support is needed.
- Outcome: design plan in `docs/design-plans/YYYY-MM-DD-<slug>.md`.
- Typical status flow: `Draft` (initial scaffold) -> `In Review` (after first planning pass).

2. Plan review and approval
- Review the plan and companion artifacts:
  - `model-symbol-table.md`
  - `equation-to-code-map.md`
  - `solver-feasibility-matrix.md`
  - `Simulation And Inference-Consistency Validation` section in the design plan (when in scope)
- Validate readiness before approval:
- Claude Code: `/validate-design-plan <plan-path> --phase in-review`
- Codex: invoke `validate-design-plan` with phase `in-review`
- Move status to approved only when architecture and math checks are acceptable:
- Claude Code: `/set-design-plan-status <plan-path> approved-for-implementation`
- Codex: invoke `set-design-plan-status` with `approved-for-implementation`
- If approved plans are revised later, move back to review:
- Claude Code: `/set-design-plan-status <plan-path> in-review`
- Codex: invoke `set-design-plan-status` with `in-review`

3. Build implementation orchestration artifacts
- Claude Code: `/start-scientific-implementation-plan <design-plan-path> [slug]`
- Codex: invoke `start-scientific-implementation-plan`
- Outcome:
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/README.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/test-requirements.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/phase_XX.md`
  - simulation phase file based on the installed template (when simulation scope is `yes`)
  - absolute implementation plan path for execution handoff
- Recommended: start a fresh session/context before execution.

4. Execute implementation phases
- Claude Code: `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`
- Codex: invoke `execute-scientific-implementation-plan` with the same absolute path
- Outcome: phase-by-phase implementation with TDD, reviewer/fix loops, and traceability coverage checks.
- During execution, surface delegate evidence after each delegate run (tests, findings, blockers, commits).

5. During phase execution, apply layer skills in order when relevant
- `validation-first-pipeline-api`
- `jax-equinox-numerics` (from `scientific-house-style`, when installed)
- `scientific-cli-thin-shell`

6. Review and completion
- Run `scientific-architecture-reviewer`.
- Run `numerics-interface-auditor`.
- Verify fresh test/check command evidence before claiming completion.

## Plan Utilities

1. Create plan + artifact stubs:
- Claude Code: `/new-design-plan <slug>`
- Codex: invoke `new-design-plan` with a slug

2. Change plan status:
- Claude Code: `/set-design-plan-status <plan-path> <draft|in-review|approved-for-implementation>`
- Codex: invoke `set-design-plan-status`

3. Validate plan readiness:
- Claude Code: `/validate-design-plan <plan-path> --phase in-review`
- Codex: invoke `validate-design-plan` with phase `in-review`

4. Run external research pass when triggered:
- Claude Code/Codex:
  - `scientific-internet-research-pass` for external claims
  - delegate `internet-researcher` for general/API web evidence
  - delegate `scientific-literature-researcher` for paper-backed support

5. Define simulation contract when in scope:
- Claude Code: `/start-simulation-validation <plan-path>`
- Codex: invoke `simulation-for-inference-validation`

6. Start implementation planning:
- Claude Code: `/start-scientific-implementation-plan <design-plan-path> [slug]`
- Codex: invoke `start-scientific-implementation-plan`

7. Execute implementation plan:
- Claude Code: `/execute-scientific-implementation-plan <absolute-implementation-plan-dir>`
- Codex: invoke `execute-scientific-implementation-plan`

## Non-Negotiable Gates

1. No implementation before explicit plan approval.
2. If model artifacts exist, math sanity checks are required.
3. Model path must be explicit: `provided-model` with concrete sources/rules, or `suggested-model` with literature-backed candidates plus user selection.
4. If simulation-based validation is in scope, simulation contract (`simulate` API + alignment checks + validation experiments) is required.
5. If update rules exist, solver strategy decision is required.
6. TDD and fresh verification evidence are required before completion.
7. Implementation phases are blocked unless AC-to-task-to-test traceability is complete.
