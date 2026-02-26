# Scientific Software Playbook Onboarding

Use this workflow when starting from scratch or adding a major feature.

Before running this flow on a fresh clone, complete setup in:
`docs/INSTALLATION.md`

For Codex reuse across repositories, use the global install
steps from `docs/INSTALLATION.md` first.

Plugin prerequisite:
1. This onboarding flow requires `scientific-plan-execute`.
2. This onboarding flow also requires `scientific-research` for research-gated steps.
3. This onboarding flow requires `scientific-house-style` for numerics/jax-project-engineering guidance gates.
4. If `scientific-house-style` is missing, workflow preflight checks will fail.
5. Compatibility and breaking-change path policy is documented in `docs/COMPATIBILITY.md`.

## Phase Workflow

1. Architecture kickoff
- Claude Code path: run `/start-design-plan <slug>`.
- Codex path:
  - Use `using-plan-and-execute` first to choose the correct entrypoint.
  - Use `starting-a-design-plan` directly (see `AGENTS.md`).
  - Playbook scripts/templates are loaded from `CODEX_HOME`, while plan/review outputs are created in the current project.
- Run `scientific-kickoff` for fresh-project/model-path tracks to force one mode (`provided-model`, `suggested-model`, `existing-codebase-port`) before full architecture expansion.
- Pass kickoff output (`.scientific/kickoff.md`) into `starting-a-design-plan`; design workflow should ingest this handoff when present.
- Run `asking-clarifying-questions` to resolve contradictions and narrow scope.
- Run `brainstorming` to compare alternatives and validate a direction.
- For fresh-project/model-path tracks, choose one model path early:
  - `provided-model`: user supplies model artifacts/update rules.
  - `suggested-model`: planner proposes literature-backed model options and user selects.
  - `existing-codebase-port`: user supplies a local directory or GitHub URL and defines a pinned source + behavior parity contract.
  - for `existing-codebase-port`, run `scientific-codebase-investigation-pass` and record file-level findings before approval.
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
- Claude Code: `/start-implementation-plan <design-plan-path>`
- Codex: invoke `starting-an-implementation-plan`
- Outcome:
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/README.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/test-requirements.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/phase_XX.md`
  - simulation phase file based on the installed template (when simulation scope is `yes`)
  - absolute implementation plan path for execution handoff
- Recommended: start a fresh session/context before execution.

4. Execute implementation phases
- Claude Code: `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`
- Codex: invoke `executing-an-implementation-plan` with the same paths
- Outcome: phase-by-phase implementation with TDD, reviewer/fix loops, and traceability coverage checks.
- During execution, surface delegate evidence after each delegate run (tests, findings, blockers, commits).

5. During phase execution, apply layer skills in order when relevant
- `validation-first-pipeline-api`
- `jax-equinox-numerics` (from `scientific-house-style`)
- `test-driven-development` for behavior-changing work
- `systematic-debugging` for failing tests or persistent blockers
- `using-git-worktrees` when branch/worktree isolation is required

6. Review and completion
- Run `scientific-architecture-reviewer`.
- Run `numerics-interface-auditor`.
- Run `requesting-code-review` to close implementation findings before completion.
- Run `verification-before-completion` before any "done" claim.
- Verify fresh test/check command evidence before claiming completion.

## Plan Utilities

1. Create plan + artifact stubs:
- Claude Code: `/new-design-plan <slug>`
- Codex: invoke `new-design-plan` with a slug
- Use `writing-design-plans` to expand/refine design sections after scaffolding.

2. Clarify and explore before architecture lock-in:
- Codex/Claude: invoke `asking-clarifying-questions` then `brainstorming`.

3. Change plan status:
- Claude Code: `/set-design-plan-status <plan-path> <draft|in-review|approved-for-implementation>`
- Codex: invoke `set-design-plan-status`

4. Validate plan readiness:
- Claude Code: `/validate-design-plan <plan-path> --phase in-review`
- Codex: invoke `validate-design-plan` with phase `in-review`

5. Run external research pass when triggered:
- Claude Code/Codex:
  - `scientific-internet-research-pass` for external claims
  - delegate `internet-researcher` for general/API web evidence
  - delegate `scientific-literature-researcher` for paper-backed support

6. Define simulation contract when in scope:
- Claude Code: `/start-simulation-validation <plan-path>`
- Codex: invoke `simulation-for-inference-validation`

7. Start implementation planning:
- Claude Code: `/start-implementation-plan <design-plan-path>`
- Codex: invoke `starting-an-implementation-plan`
- Use `writing-implementation-plans` to flesh out phase/task detail and traceability.

8. Execute implementation plan:
- Claude Code: `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`
- Codex: invoke `executing-an-implementation-plan`

## Non-Negotiable Gates

Canonical hard stops are maintained in `AGENTS.md`.

Minimum required checks before implementation:
1. Explicit plan approval.
2. Explicit model path (`provided-model`, `suggested-model`, or `existing-codebase-port`).
3. Required workflow states set for approval:
- `model_path_decided: yes`
- `codebase_investigation_complete_if_port: yes|n/a` (as applicable)
- `simulation_contract_complete_if_in_scope: yes|n/a` (as applicable)
4. Fresh verification evidence before completion claims.
