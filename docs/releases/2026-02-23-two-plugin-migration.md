# Release Notes: Two-Plugin Migration (Phase 5)

Date: February 23, 2026

## Summary

This release finalizes migration hardening for the two-plugin architecture:
1. `scientific-plan-execute` (workflow orchestration)
2. `scientific-house-style` (numerics/project-engineering guidance)

The install/bootstrap path is verified across upgrade and clean-install scenarios,
and downstream bootstrap remains AGENTS-only.

## What Changed

1. Installer supports deterministic plugin-scoped installation:
   - default installs both plugins
   - `--plugin scientific-plan-execute`
   - `--plugin scientific-house-style`
2. Bootstrap resolves from plugin bundle paths and writes downstream `AGENTS.md` only.
3. Documentation and skill contracts now use plugin-path-only resolution.
4. Legacy root compatibility links and legacy installed bundle paths were removed.
5. Compatibility policy is published in:
   - `docs/COMPATIBILITY.md`

## Migration Matrix Results

Validated scenarios:
1. Existing-user upgrade path: pass
2. New install path (clean `CODEX_HOME`): pass
3. Plan-execute-only install: pass
4. Both-plugins install (explicit selection): pass

Validation checks included:
1. Plugin bundle path existence and selection correctness.
2. Installed skill inventory correctness for selected plugins.
3. Bootstrap output footprint (`AGENTS.md` only) for downstream projects.
4. AGENTS scope correctness for optional house-style presence/absence.

## Breaking Change Policy

1. Root compatibility links are no longer supported.
2. Plugin-scoped paths are now the only supported contract.
3. Any future path changes will be documented in release notes and `docs/COMPATIBILITY.md`.

## Action for Downstream Users

1. Reinstall from latest playbook checkout:
```bash
bash scripts/install-codex-home.sh --force
```
2. Re-run bootstrap in each downstream project you want refreshed:
```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh" --force
```
