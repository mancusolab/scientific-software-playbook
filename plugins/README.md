# Scientific Software Playbook Plugins

This repository now hosts multiple plugins.

## Plugins

1. `scientific-plan-execute`
2. `scientific-research`
3. `scientific-house-style`
4. `scientific-agent-tools`

## Intent

1. Keep workflow orchestration (`plan-execute`) separate from reusable
   engineering doctrine (`house-style`).
2. Allow independent install/update cadence while preserving compatibility.
3. Keep runtime command/handoff conventions centralized in repository-root
   `README.md` and `AGENTS.md` to avoid drift across plugin docs.
4. Keep maintainer-facing authoring and context-maintenance tooling separate
   from downstream workflow requirements.

See compatibility matrix and shim timeline in:
1. `docs/COMPATIBILITY.md`

## Licensing

1. Each plugin ships a local `LICENSE` file.
2. `scientific-plan-execute` also includes `LICENSE.superpowers` for upstream MIT lineage via `ed3d-plan-and-execute`.
3. `scientific-agent-tools` includes `LICENSE.ed3d` for plugin-local ed3d attribution.
4. Repository-level attribution details are in `NOTICE`.
