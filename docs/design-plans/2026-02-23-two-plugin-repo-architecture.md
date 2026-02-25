# Two-Plugin Repository Architecture Design

## Summary
This design splits the current single plugin into two first-class plugins within this repository:
1. `scientific-plan-execute` for workflow orchestration (architecture -> plan -> execute -> validate).
2. `scientific-house-style` for reusable engineering policy and reference skills (`jax-equinox-numerics`, `project-engineering`, related checklists/snippets).

The goal is to remove ambiguity about global scope, keep downstream repositories minimal (`AGENTS.md` only), and preserve a simple install path while making plugin boundaries explicit and maintainable.

## Definition of Done
1. Repository contains two plugin roots with explicit manifests and isolated assets.
2. Global install can install either plugin independently or both together with one command.
3. `scientific-plan-execute` references `scientific-house-style` skills as dependencies, not vendored duplicates.
4. Downstream bootstrap remains minimal (`AGENTS.md` only).
5. Existing users can migrate without workflow breakage via compatibility aliases or documented migration steps.
6. Docs define scope, ownership, install commands, and compatibility contracts unambiguously.

## Problem Statement
Current state mixes two concerns in one plugin contract:
1. Workflow orchestration assets (`agents/`, `commands/`, planning/validation/execution skills).
2. House-style engineering guidance skills with independent lifecycle (`jax-equinox-numerics`, `project-engineering`).

This creates scope ambiguity:
1. Some skills exist in `skills/` but are not part of the installed and documented workflow set.
2. Install/bootstrap/docs require synchronized manual lists in multiple files.
3. It is unclear whether house-style assets are bundled dependencies or local extras.

## Goals and Non-Goals
### Goals
1. Make plugin boundaries explicit and rigorous.
2. Keep user install experience simple.
3. Preserve minimal downstream footprint.
4. Enable independent versioning cadence for house-style vs workflow loop.

### Non-Goals
1. Rewriting scientific workflow semantics.
2. Introducing automatic "always latest" dependency updates.
3. Changing current hard-stop quality gates.

## Existing Patterns
1. Single plugin manifest at `.claude-plugin/plugin.json` points to root-level `commands/` and `agents/`.
2. Global install script enumerates installable skills explicitly.
3. Bootstrap writes downstream `AGENTS.md` and currently references global bundle paths.
4. Core workflow skills already support global script fallback via `CODEX_HOME`.

## Target Architecture
## Repository Structure
```text
scientific-software-playbook/
  plugins/
    scientific-plan-execute/
      .claude-plugin/plugin.json
      agents/
      commands/
      hooks/
      scripts/
      skills/
        bootstrap-scientific-software-playbook/
        new-design-plan/
        validate-design-plan/
        set-design-plan-status/
        start-scientific-implementation-plan/
        execute-scientific-implementation-plan/
        scientific-internet-research-pass/
        scientific-software-architecture/
        simulation-for-inference-validation/
        validation-first-pipeline-api/
        scientific-cli-thin-shell/
      docs/
        design-plans/templates/
        implementation-plans/templates/
        reviews/
        checklists/
    scientific-house-style/
      .claude-plugin/plugin.json
      skills/
        jax-equinox-numerics/
        project-engineering/
      docs/
        skill-index.md
  scripts/
    install-codex-home.sh
  README.md
```

## Global Install Contract
1. Installer supports plugin selection:
- `--plugin scientific-plan-execute`
- `--plugin scientific-house-style`
- default installs both.
2. Installer writes assets to:
- `${CODEX_HOME}/skills/<skill-name>/`
- `${CODEX_HOME}/scientific-software-playbook/plugins/<plugin-name>/...`
3. Bootstrap script comes from `scientific-plan-execute` plugin and remains AGENTS-only for downstream repos.

## Dependency Contract
1. `scientific-plan-execute` declares dependency on house-style skills by name and version range in docs/AGENTS contract.
2. Dependency behavior:
- If house-style skills are missing, plan-execute still runs but warns when optional house-style steps are requested.
- Required-vs-optional dependency status is explicit in contract docs.

## Compatibility and Versioning
1. Use explicit versions, not floating latest.
2. Compatibility table maintained in docs:
- plan-execute version -> compatible house-style versions.
3. Transitional aliases supported for one migration window:
- old path references and skill names continue to resolve where feasible.

## Implementation Phases
<!-- START_PHASE_1 -->
### Phase 1: Define Plugin Boundaries and Contracts
**Goal:** Freeze scope and ownership so refactor can proceed without churn.

**Components:**
1. Create plugin boundary spec doc with owned asset matrix (agents/commands/hooks/scripts/skills/templates).
2. Define dependency policy (`required`, `optional`, compatibility ranges).
3. Define migration policy and deprecation window.

**Dependencies:** None.

**Done when:**
1. Boundary spec approved.
2. Dependency policy approved.
3. Migration compatibility policy approved.
<!-- END_PHASE_1 -->

<!-- START_PHASE_2 -->
### Phase 2: Physical Repo Split Into `plugins/` Layout
**Goal:** Move assets into plugin-specific directories without behavior changes.

**Components:**
1. Create `plugins/scientific-plan-execute/` and move workflow assets.
2. Create `plugins/scientific-house-style/` and move `jax-equinox-numerics`, `project-engineering`.
3. Add plugin manifests in each plugin root.
4. Keep temporary compatibility shims at legacy root paths where required.

**Dependencies:** Phase 1.

**Done when:**
1. Both plugins are loadable from their own manifest roots.
2. Existing key commands/skills still run through compatibility paths.
<!-- END_PHASE_2 -->

<!-- START_PHASE_3 -->
### Phase 3: Installer and Bootstrap Refactor
**Goal:** Make install/bootstrap plugin-aware while preserving simple user experience.

**Components:**
1. Refactor installer to discover plugins and install by selection/default both.
2. Update bootstrap to source plan-execute assets from plugin bundle path.
3. Add install verification checks for plugin manifests and required assets.

**Dependencies:** Phase 2.

**Done when:**
1. Fresh install + bootstrap works in a clean temporary `CODEX_HOME`.
2. Downstream project receives `AGENTS.md` only.
3. Plan creation/validation/status scripts resolve correctly from installed plugin paths.
<!-- END_PHASE_3 -->

<!-- START_PHASE_4 -->
### Phase 4: Contract and Documentation Alignment
**Goal:** Remove ambiguity in user/operator docs and skill docs.

**Components:**
1. Update root README to explain two-plugin model and install options.
2. Update installation/onboarding docs with plugin selection examples.
3. Update AGENTS and skill docs to reflect dependency contract and plugin paths.
4. Publish compatibility matrix and deprecation timeline.

**Dependencies:** Phase 3.

**Done when:**
1. No doc claims conflict with actual installer/bootstrap behavior.
2. Skill inventory in docs matches installed inventories exactly.
3. Migration steps are explicit and executable.
<!-- END_PHASE_4 -->

<!-- START_PHASE_5 -->
### Phase 5: Migration Hardening and Cleanup
**Goal:** Validate migration end-to-end and remove temporary ambiguity.

**Components:**
1. Run migration test matrix:
- existing user upgrade path
- new install path
- plan-execute-only install
- both-plugins install
2. Remove deprecated compatibility shims after migration window.
3. Finalize release notes for downstream users.

**Dependencies:** Phase 4.

**Done when:**
1. Test matrix passes.
2. Deprecated shims removed or scheduled with explicit date/version.
3. Release notes published.
<!-- END_PHASE_5 -->

## Additional Considerations
1. Keep list duplication low by generating skill inventories from plugin manifests or a shared manifest file.
2. Preserve local-development convenience by keeping a top-level dev entrypoint script that delegates to plugin-specific installers.
3. Avoid hidden coupling by ensuring scripts do not rely on repository-root assumptions after split.

## Risks and Mitigations
1. Risk: Path breakage during move.
- Mitigation: add temporary compatibility wrappers and path-resolution tests.
2. Risk: Users install only one plugin unintentionally.
- Mitigation: default install both, plus clear warning when dependencies are missing.
3. Risk: Drift between docs and install lists.
- Mitigation: generate docs sections from manifest/skill inventory where possible.

## Acceptance Criteria
1. Two plugin manifests exist and load independently.
2. `scientific-plan-execute` install works without vendoring house-style files.
3. `scientific-house-style` skills can be installed independently and referenced by plan-execute docs/contracts.
4. Bootstrap remains AGENTS-only in downstream repos.
5. Installer supports explicit plugin selection and default both-plugins mode.
6. All references to global scope and dependencies are consistent across README, INSTALLATION, ONBOARDING, AGENTS, and skills.

## Glossary
1. Plan-execute plugin: orchestration plugin for design/implementation workflow.
2. House-style plugin: reusable engineering standards and reference skills.
3. Compatibility shim: temporary path/name bridge maintained during migration.
4. Downstream project: a project that consumes this playbook from `CODEX_HOME`.
