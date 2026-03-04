# Scientific Software Playbook Onboarding

Use this workflow when starting from scratch or adding a major feature in software that performs inference for an explicit scientific model.
This playbook is currently tuned for Python/JAX implementations; additional implementation languages are out of scope for the workflow and house-style guidance in this repository.

Before running this flow on a fresh clone, complete setup in:
`docs/INSTALLATION.md`

Plugin prerequisite:
1. This onboarding flow requires `scientific-plan-execute`.
2. This onboarding flow also requires `scientific-research` for research-gated steps.
3. This onboarding flow requires `scientific-house-style` for numerics, Polars/tabular-boundary, and project-engineering guidance gates.
4. If `scientific-house-style` is missing, workflow preflight checks will fail.
5. Compatibility and breaking-change path policy is documented in `docs/COMPATIBILITY.md`.

---

## ![Codex CLI](https://img.shields.io/badge/Codex_CLI-000000?style=flat-square&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTIyLjI4MiA5LjgyMWE2IDYgMCAwIDAtLjUxNi00LjkxYTYuMDUgNi4wNSAwIDAgMC02LjUxLTIuOUE2LjA2NSA2LjA2NSAwIDAgMCA0Ljk4MSA0LjE4YTYgNiAwIDAgMC0zLjk5OCAyLjlhNi4wNSA2LjA1IDAgMCAwIC43NDMgNy4wOTdhNS45OCA1Ljk4IDAgMCAwIC41MSA0LjkxMWE2LjA1IDYuMDUgMCAwIDAgNi41MTUgMi45QTYgNiAwIDAgMCAxMy4yNiAyNGE2LjA2IDYuMDYgMCAwIDAgNS43NzItNC4yMDZhNiA2IDAgMCAwIDMuOTk3LTIuOWE2LjA2IDYuMDYgMCAwIDAtLjc0Ny03LjA3M00xMy4yNiAyMi40M2E0LjQ4IDQuNDggMCAwIDEtMi44NzYtMS4wNGwuMTQxLS4wODFsNC43NzktMi43NThhLjguOCAwIDAgMCAuMzkyLS42ODF2LTYuNzM3bDIuMDIgMS4xNjhhLjA3LjA3IDAgMCAxIC4wMzguMDUydjUuNTgzYTQuNTA0IDQuNTA0IDAgMCAxLTQuNDk0IDQuNDk0TTMuNiAxOC4zMDRhNC40NyA0LjQ3IDAgMCAxLS41MzUtMy4wMTRsLjE0Mi4wODVsNC43ODMgMi43NTlhLjc3Ljc3IDAgMCAwIC43OCAwbDUuODQzLTMuMzY5djIuMzMyYS4wOC4wOCAwIDAgMS0uMDMzLjA2Mkw5Ljc0IDE5Ljk1YTQuNSA0LjUgMCAwIDEtNi4xNC0xLjY0Nk0yLjM0IDcuODk2YTQuNSA0LjUgMCAwIDEgMi4zNjYtMS45NzNWMTEuNmEuNzcuNzcgMCAwIDAgLjM4OC42NzdsNS44MTUgMy4zNTRsLTIuMDIgMS4xNjhhLjA4LjA4IDAgMCAxLS4wNzEgMGwtNC44My0yLjc4NkE0LjUwNCA0LjUwNCAwIDAgMSAyLjM0IDcuODcyem0xNi41OTcgMy44NTVsLTUuODMzLTMuMzg3TDE1LjExOSA3LjJhLjA4LjA4IDAgMCAxIC4wNzEgMGw0LjgzIDIuNzkxYTQuNDk0IDQuNDk0IDAgMCAxLS42NzYgOC4xMDV2LTUuNjc4YS43OS43OSAwIDAgMC0uNDA3LS42NjdtMi4wMS0zLjAyM2wtLjE0MS0uMDg1bC00Ljc3NC0yLjc4MmEuNzguNzggMCAwIDAtLjc4NSAwTDkuNDA5IDkuMjNWNi44OTdhLjA3LjA3IDAgMCAxIC4wMjgtLjA2MWw0LjgzLTIuNzg3YTQuNSA0LjUgMCAwIDEgNi42OCA0LjY2em0tMTIuNjQgNC4xMzVsLTIuMDItMS4xNjRhLjA4LjA4IDAgMCAxLS4wMzgtLjA1N1Y2LjA3NWE0LjUgNC41IDAgMCAxIDcuMzc1LTMuNDUzbC0uMTQyLjA4TDguNzA0IDUuNDZhLjguOCAwIDAgMC0uMzkzLjY4MXptMS4wOTctMi4zNjVsMi42MDItMS41bDIuNjA3IDEuNXYyLjk5OWwtMi41OTcgMS41bC0yLjYwNy0xLjVaIi8+PC9zdmc+) Codex

For Codex reuse across repositories, use the global install + downstream bootstrap
steps from `docs/INSTALLATION.md` first.

Normal Codex workflow:
1. `using-plan-and-execute`
2. `scientific-kickoff` only when the router says the project still needs model-path/bootstrap work
3. `starting-a-design-plan`
4. `starting-an-implementation-plan`
5. `executing-an-implementation-plan`

`new-design-plan`, `validate-design-plan`, `set-design-plan-status`, and `simulation-for-inference-validation` are manual utilities used inside an active workflow.

### Phase Workflow

1. Architecture kickoff
- Use `using-plan-and-execute` first to choose the correct entrypoint.
- The router sends fresh/model-path/parity work to `scientific-kickoff`.
- Otherwise the router sends established work directly to `starting-a-design-plan` (see `AGENTS.md`).
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
- `python-module-design` (from `scientific-house-style`) when introducing or reviewing Python module/file boundaries
- `jax-equinox-numerics` (from `scientific-house-style`)
- `polars-data-engineering` (from `scientific-house-style`) for Polars/LazyFrame/DataFrame/adapter-boundary work
- `test-driven-development` for behavior-changing work
- `systematic-debugging` for failing tests or persistent blockers
- `using-git-worktrees` when branch/worktree isolation is required

6. Review and completion
- Run `scientific-architecture-reviewer`.
- Run `numerics-interface-auditor`.
- Run `requesting-code-review` to close implementation findings before completion.
- Run `verification-before-completion` before any "done" claim.
- Verify fresh test/check command evidence before claiming completion.

### Manual Utilities

1. Create plan + artifact stubs directly:
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

## ![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=flat-square&logo=claude&logoColor=white) Claude Code

### Phase Workflow

Normal Claude Code workflow:
1. `/start-plan-and-execute`
2. `/start-scientific-kickoff` only when the router says the project still needs model-path/bootstrap work
3. `/start-design-plan <slug>`
4. `/start-implementation-plan <design-plan-path>`
5. `/execute-implementation-plan <plan-dir> <working-dir>`

`/new-design-plan`, `/validate-design-plan`, `/set-design-plan-status`, and `/start-simulation-validation` are manual utilities used inside an active workflow.

1. Architecture kickoff
- Start with `/start-plan-and-execute`.
- When the router selects kickoff, run `/start-scientific-kickoff` first, then `/start-design-plan <slug>`.
- Otherwise the router should send you directly to `/start-design-plan <slug>`.
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
- `python-module-design` (from `scientific-house-style`) when introducing or reviewing Python module/file boundaries
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

### Manual Utilities

1. Create plan + artifact stubs directly:
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
