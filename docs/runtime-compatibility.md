# Runtime Compatibility And Skill Lookup Contract

This document is the single source of truth for runtime compatibility and skill
lookup expectations used in skills and agents.

Contract:
1. `Skill` tool calls mean "load the named skill" in the active runtime.
2. `TaskCreate`, `TaskUpdate`, and `TodoWrite` map to `update_plan`.
3. `Task` delegate calls map to in-session execution when delegation is unavailable.
4. Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` map to equivalent native runtime tools.

Maintenance contract:
1. Edit only the block between the `BEGIN`/`END` markers.
2. Run `python3 plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py`.
3. CI validates no drift via `--check` mode.

<!-- BEGIN:RUNTIME_COMPATIBILITY_BLOCK -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- END:RUNTIME_COMPATIBILITY_BLOCK -->
