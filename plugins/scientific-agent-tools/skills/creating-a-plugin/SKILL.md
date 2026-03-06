---
name: creating-a-plugin
description: Use when adding a new plugin to this repository or refitting an existing one - defines plugin structure, repo integration points, optional-vs-required role boundaries, and attribution expectations.
user-invocable: false
metadata:
  short-description: Create or refit a plugin
---

# Creating a Plugin

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Path Contract (Unambiguous)

1. Source-of-truth plugin roots live under `plugins/<plugin-name>/`.
2. Codex installs plugin bundles under `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/<plugin-name>/`.
3. Codex exposes skills from `plugins/<plugin-name>/skills/<skill-name>/` into `${CODEX_HOME:-$HOME/.codex}/skills/<skill-name>/`.
4. Do not reintroduce repository-root compatibility shims such as `skills/`, `agents/`, or `commands/`.

## Scope Boundary

This skill is authoritative for:
- plugin-level directory structure and manifests
- plugin role classification: required workflow plugin vs optional maintainer plugin
- repo integration points that must change when a plugin is added
- plugin-level attribution and provenance files

This skill is not the source of truth for:
- how to write a skill body
- how to design an agent prompt
- how to author project-context files

Use `writing-skills`, `creating-an-agent`, `writing-claude-directives`, and
`writing-claude-md-files` for those concerns.

## Core Principle

Adding a plugin is a repository contract change, not just a folder creation.
The plugin is incomplete until its manifest, inventory, installer, compatibility
docs, and attribution are aligned.

## Required Plugin Shape

Minimum expected layout in this repository:

```text
plugins/<plugin-name>/
  .claude-plugin/plugin.json
  LICENSE
  docs/skill-index.md
  skills/
  agents/                  # if the plugin exposes agents
  NOTICE.ed3d              # if materially derived from ed3d content
```

Add `commands/`, `hooks/`, `scripts/`, or other assets only when the plugin
actually exposes them.

## Decide the Plugin Role First

Choose exactly one role before writing files:

1. **Required workflow plugin**
   - Needed for downstream scientific workflow execution.
   - Must be called out explicitly in `AGENTS.md`, `README.md`,
     `docs/INSTALLATION.md`, and `docs/COMPATIBILITY.md`.
2. **Optional maintainer plugin**
   - Supports playbook/plugin maintenance rather than downstream workflow
     execution.
   - Must be installable and documented, but must not be presented as a
     required workflow dependency.

If the only consumers are repository maintainers, default to optional.

## Manifest Rules

`plugin.json` must:
- use the plugin directory name as `name`
- declare a `version`
- provide a short `description`
- list agent paths explicitly when agents are part of the plugin
- leave `commands` empty when no commands are exposed

Example:

```json
{
  "name": "scientific-agent-tools",
  "version": "0.1.0",
  "description": "Optional maintainer-facing authoring tools.",
  "commands": [],
  "agents": [
    "./agents/project-claude-librarian.md"
  ]
}
```

## Required Repo Integration Points

When adding or refitting a plugin, inspect and update:

1. `AGENTS.md`
   - add the plugin to the repository inventory
   - add source-of-truth skill paths
   - state whether the plugin is required or optional
2. `README.md`
   - mention the plugin in the high-level plugin list and install guidance
3. `docs/INSTALLATION.md`
   - add install commands and dependency notes
4. `docs/COMPATIBILITY.md`
   - clarify whether the plugin participates in required compatibility gates or
     is optional
5. `.claude-plugin/marketplace.json`
   - register the plugin and version
6. `plugins/scientific-plan-execute/scripts/plugin-catalog.sh`
   - add the plugin name, skill inventory, and required paths so Codex install
     works
7. `plugins/scientific-plan-execute/scripts/check-repo-contracts.sh`
   - extend contract checks for the new plugin
8. `plugins/README.md`
   - keep the local plugin inventory and licensing notes in sync
9. `NOTICE`
   - update repository-level provenance mapping when upstream attribution
     changes

## Attribution Rules

If the plugin is materially derived from ed3d content:

1. Add a plugin-local attribution note in `LICENSE`.
2. Add a durable provenance file such as `NOTICE.ed3d`.
3. Keep repository-level attribution in `NOTICE` aligned with the plugin note.
4. Only add per-file attribution when the file is still materially derived after
   rewrite.

Do not silently carry forward upstream content without naming the lineage.

## Practical Workflow

1. Decide whether the plugin is required or optional.
2. Create or normalize the plugin root structure.
3. Add or update `plugin.json`.
4. Add `LICENSE`, plugin docs, and provenance files.
5. Rewrite stale skill and agent content to local repo contracts.
6. Register the plugin in marketplace, installer catalog, docs, and contract
   checks.
7. Verify the plugin installs cleanly and the repo contract checker still passes.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating only the folder tree | Update all repo inventories and install surfaces |
| Treating maintainer tooling as workflow-critical by default | Explicitly mark it optional unless downstream workflows require it |
| Keeping stale upstream namespace references | Replace them with local skill IDs or direct fallback instructions |
| Adding repo-root shims for convenience | Keep plugin-scoped source-of-truth paths only |
| Forgetting attribution after a rewrite | Keep plugin-level provenance explicit even after modernization |
