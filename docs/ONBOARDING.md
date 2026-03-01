# Scientific Software Playbook Onboarding

Use this workflow when starting from scratch or adding a major feature in software that performs inference for an explicit scientific model.
This playbook is currently tuned for Python/JAX implementations; additional implementation languages are out of scope for the workflow and house-style guidance in this repository.

Before running this flow on a fresh clone, complete setup in:
`docs/INSTALLATION.md`

Plugin prerequisite:
1. This onboarding flow requires `scientific-plan-execute`.
2. This onboarding flow also requires `scientific-research` for research-gated steps.
3. This onboarding flow requires `scientific-house-style` for numerics/jax-project-engineering guidance gates.
4. If `scientific-house-style` is missing, workflow preflight checks will fail.
5. Compatibility and breaking-change path policy is documented in `docs/COMPATIBILITY.md`.

---

## Codex

For Codex reuse across repositories, use the global install + downstream bootstrap
steps from `docs/INSTALLATION.md` first.

### Phase Workflow

1. Architecture kickoff
- Use `using-plan-and-execute` first to choose the correct entrypoint.
- Run `scientific-kickoff` first only when model provenance, model selection, or existing-codebase parity must be established.
- Otherwise start with `starting-a-design-plan` (see `AGENTS.md`).
- Playbook scripts/templates are loaded from `CODEX_HOME`, while plan/review outputs are created in the current project.
- Run `scientific-kickoff` only when the project still needs one mode (`provided-model`, `suggested-model`, `existing-codebase-port`) selected before full architecture expansion.
- Pass kickoff output (`.scientific/kickoff.md`) into `starting-a-design-plan`; design workflow should ingest this handoff when present.
- Run `asking-clarifying-questions` to resolve contradictions and narrow scope.
- Run `brainstorming` to compare alternatives and validate a direction.
- When model provenance or model selection is still unresolved, choose one model path early:
  - `provided-model`: user supplies model artifacts/update rules.
  - `suggested-model`: planner proposes literature-backed model options and user selects.
  - `existing-codebase-port`: user supplies a local directory or GitHub URL and defines a pinned source + behavior parity contract.
  - for `existing-codebase-port`, run `scientific-codebase-investigation-pass` and record file-level findings before approval.
- If inference validation should include synthetic-data checks, define a synthetic-data validation contract:
  - invoke `simulation-for-inference-validation`
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
  - invoke `validate-design-plan` with phase `in-review`
- Move status to approved only when architecture and math checks are acceptable:
  - invoke `set-design-plan-status` with `approved-for-implementation`
- If approved plans are revised later, move back to review:
  - invoke `set-design-plan-status` with `in-review`

3. Build implementation orchestration artifacts
- invoke `starting-an-implementation-plan`
- Outcome:
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/README.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/test-requirements.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/phase_XX.md`
  - simulation-validation phase file based on the installed template (when synthetic-data validation scope is `yes`)
  - absolute implementation plan path for execution handoff
- Recommended: start a fresh session/context before execution.

4. Execute implementation phases
- invoke `executing-an-implementation-plan` with the absolute path
- Outcome: phase-by-phase implementation with TDD, reviewer/fix loops, and traceability coverage checks.
- During execution, surface delegate evidence after each delegate run (tests, findings, blockers, commits).

5. During phase execution, apply layer skills in order when relevant
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

### Plan Utilities

1. Create plan + artifact stubs:
- invoke `new-design-plan` with a slug
- Use `writing-design-plans` to expand/refine design sections after scaffolding.

2. Clarify and explore before architecture lock-in:
- invoke `asking-clarifying-questions` then `brainstorming`.

3. Change plan status:
- invoke `set-design-plan-status`

4. Validate plan readiness:
- invoke `validate-design-plan` with phase `in-review`

5. Run external research pass when triggered:
- `scientific-internet-research-pass` for external claims
- delegate `internet-researcher` for general/API web evidence
- delegate `scientific-literature-researcher` for paper-backed support

6. Define a synthetic-data validation contract when in scope:
- invoke `simulation-for-inference-validation`

7. Start implementation planning:
- invoke `starting-an-implementation-plan`
- Use `writing-implementation-plans` to flesh out phase/task detail and traceability.

8. Execute implementation plan:
- invoke `executing-an-implementation-plan`

---

## Claude Code

### Phase Workflow

1. Architecture kickoff
- When model provenance or existing-codebase parity still needs to be established: run `/start-scientific-kickoff` first, then `/start-design-plan <slug>`.
- Otherwise start directly with `/start-design-plan <slug>`.
- Run `asking-clarifying-questions` to resolve contradictions and narrow scope.
- Run `brainstorming` to compare alternatives and validate a direction.
- When model provenance or model selection is still unresolved, choose one model path early:
  - `provided-model`: user supplies model artifacts/update rules.
  - `suggested-model`: planner proposes literature-backed model options and user selects.
  - `existing-codebase-port`: user supplies a local directory or GitHub URL and defines a pinned source + behavior parity contract.
  - for `existing-codebase-port`, run `scientific-codebase-investigation-pass` and record file-level findings before approval.
- If inference validation should include synthetic-data checks, define a synthetic-data validation contract:
  - `/start-simulation-validation <plan-path>`
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
  - `/validate-design-plan <plan-path> --phase in-review`
- Move status to approved only when architecture and math checks are acceptable:
  - `/set-design-plan-status <plan-path> approved-for-implementation`
- If approved plans are revised later, move back to review:
  - `/set-design-plan-status <plan-path> in-review`

3. Build implementation orchestration artifacts
- `/start-implementation-plan <design-plan-path>`
- Outcome:
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/README.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/test-requirements.md`
  - `docs/implementation-plans/YYYY-MM-DD-<slug>/phase_XX.md`
  - simulation-validation phase file based on the installed template (when synthetic-data validation scope is `yes`)
  - absolute implementation plan path for execution handoff
- Recommended: start a fresh session/context before execution.

4. Execute implementation phases
- `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`
- Outcome: phase-by-phase implementation with TDD, reviewer/fix loops, and traceability coverage checks.
- During execution, surface delegate evidence after each delegate run (tests, findings, blockers, commits).

5. During phase execution, apply layer skills in order when relevant
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

### Plan Utilities

1. Create plan + artifact stubs:
- `/new-design-plan <slug>`
- Use `writing-design-plans` to expand/refine design sections after scaffolding.

2. Clarify and explore before architecture lock-in:
- invoke `asking-clarifying-questions` then `brainstorming`.

3. Change plan status:
- `/set-design-plan-status <plan-path> <draft|in-review|approved-for-implementation>`

4. Validate plan readiness:
- `/validate-design-plan <plan-path> --phase in-review`

5. Run external research pass when triggered:
- `scientific-internet-research-pass` for external claims
- delegate `internet-researcher` for general/API web evidence
- delegate `scientific-literature-researcher` for paper-backed support

6. Define a synthetic-data validation contract when in scope:
- `/start-simulation-validation <plan-path>`

7. Start implementation planning:
- `/start-implementation-plan <design-plan-path>`
- Use `writing-implementation-plans` to flesh out phase/task detail and traceability.

8. Execute implementation plan:
- `/execute-implementation-plan <absolute-implementation-plan-dir> <absolute-working-dir>`

---

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
