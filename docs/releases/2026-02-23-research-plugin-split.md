# Release Notes: Scientific Research Plugin Split

Date: February 23, 2026

## Summary

Research capabilities were extracted from `scientific-plan-execute` into a new
`scientific-research` plugin.

## What Changed

1. New plugin: `scientific-research`.
2. Moved from plan-execute to scientific-research:
- `scientific-internet-research-pass`
3. Adopted ed3d-style research layout with:
- 4 core agents: `codebase-investigator`, `internet-researcher`, `remote-code-researcher`, `combined-researcher`
- 2 core skills: `scientific-codebase-investigation-pass`, `scientific-internet-research-pass`
- 5th agent: `scientific-literature-researcher`
4. Installer/catalog/marketplace updated for three-plugin architecture.
5. Codex installer now auto-adds `scientific-research` when
`scientific-plan-execute` is selected.

## Migration Notes

1. Reinstall playbook plugins:
```bash
bash scripts/install-codex-home.sh --force
```
2. If you install selectively for Codex and choose `scientific-plan-execute`,
   `scientific-research` is included automatically.
3. For Claude Code, install both workflow and research plugins when using full
   plan-execute workflows.
