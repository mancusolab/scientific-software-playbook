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
3. Documentation and skill contracts now use plugin-path-first resolution with
   explicit legacy compatibility fallbacks.
4. Compatibility matrix and deprecation timeline are published in:
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

## Compatibility Shim Policy

1. Shims remain in place through `0.1.x` and `0.2.x`.
2. Earliest removal target is `0.3.0` on or after August 1, 2026.
3. Removal will ship with explicit migration guidance and release notes.

## Action for Downstream Users

1. Reinstall from latest playbook checkout:
```bash
bash scripts/install-codex-home.sh --force
```
2. Re-run bootstrap in each downstream project you want refreshed:
```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/bootstrap-scientific-software-playbook.sh" --force
```
