---
name: coding-effectively
description: Use when writing or refactoring code - activates required and context-dependent sub-skills across languages and runtimes
user-invocable: false
metadata:
  short-description: Cross-language engineering defaults
---

# Coding Effectively

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

1. This skill has no installation-local file dependencies and is valid in either runtime:
- Codex installation example: `${CODEX_HOME:-$HOME/.codex}/skills/coding-effectively/SKILL.md`
- Claude plugin installation example: `${CLAUDE_PLUGIN_ROOT}/skills/coding-effectively/SKILL.md`
2. Skill references in this file are skill IDs, not repository-relative paths.


## Required Sub-Skills

**ALWAYS REQUIRED:**
- `functional-core-imperative-shell` - Separate pure logic from side effects
- `project-engineering` - Apply baseline project-level engineering contracts

**CONDITIONAL:** Use these sub-skills when applicable:
- `jax-equinox-numerics` - JAX and Equinox numerical best practices
- `writing-good-tests` - Writing or reviewing tests
- `property-based-testing` - Tests for serialization, validation, normalization, pure functions

## Property-Driven Design

When designing features, think about properties upfront. This surfaces design gaps early.

**Discovery questions:**

| Question | Property Type | Example |
|----------|---------------|---------|
| Does it have an inverse operation? | Roundtrip | `decode(encode(x)) == x` |
| Is applying it twice the same as once? | Idempotence | `f(f(x)) == f(x)` |
| What quantities are preserved? | Invariants | Length, sum, count unchanged |
| Is order of arguments irrelevant? | Commutativity | `f(a, b) == f(b, a)` |
| Can operations be regrouped? | Associativity | `f(f(a,b), c) == f(a, f(b,c))` |
| Is there a neutral element? | Identity | `f(x, 0) == x` |
| Is there a reference implementation? | Oracle | `new(x) == old(x)` |
| Can output be easily verified? | Easy to verify | `is_sorted(sort(x))` |

**Common design questions these reveal:**
- "What about deleted/deactivated entities?"
- "Case-sensitive or not?"
- "Stable sort or not? Tie-breaking rules?"
- "Which algorithm? Configurable?"

Surface these during design, not during debugging.

## Core Engineering Principles

### Correctness Over Convenience

Model the full error space. No shortcuts.

- Handle all edge cases: race conditions, timing issues, partial failures
- Use the type system to encode correctness constraints
- Prefer compile-time guarantees over runtime checks where possible
- When uncertain, explore and iterate rather than assume

**Don't:**
- Simplify error handling to save time
- Ignore edge cases because "they probably won't happen"
- Use `any` or equivalent to bypass type checking

### Error Handling Philosophy

**Two-tier model:**

1. **User-facing errors**: Semantic exit codes, rich diagnostics, actionable messages
2. **Internal errors**: Programming errors that may panic or use internal types

**Error message format:** Lowercase sentence fragments for "failed to {message}".

```
Good: failed to connect to database: connection refused
Bad:  Failed to Connect to Database: Connection Refused

Good: invalid configuration: missing required field 'apiKey'
Bad:  Invalid Configuration: Missing Required Field 'apiKey'
```

Lowercase fragments compose naturally: `"operation failed: " + error.message` reads correctly.

### Pragmatic Incrementalism

- Prefer specific, composable logic over abstract frameworks
- Evolve design incrementally rather than perfect upfront architecture
- Don't build for hypothetical future requirements
- Document design decisions and trade-offs when making non-obvious choices

**The rule of three applies to abstraction:** Don't abstract until you've seen the pattern three times. Three similar lines of code is better than a premature abstraction.

## File Organization

### Module Organization

- Keep module boundaries strict with restricted visibility
- Platform-specific code in separate files: `unix.py`, `windows.py`, `posix.py`
- Use conditional compilation or runtime checks for platform branching
- Test helpers in dedicated modules/files, not mixed with production code

## Common Mistakes

| Mistake | Reality                                            | Fix |
|---------|----------------------------------------------------|-----|
| "Just put it in utils for now" | utils.py becomes 2000 lines of unrelated code      | Name files by purpose from the start |
| "Edge cases are rare" | Edge cases cause production incidents              | Handle them. Model the full error space. |
| "We might need this abstraction later" | Premature abstraction is harder to remove than add | Wait for the third use case |
| "It works on my Mac" | It may not work on Windows or Linux                | Test on target platforms |
| "The type system is too strict" | Strictness catches bugs at compile time            | Fix the type error, don't bypass it |

## Red Flags

**Stop and refactor when you see:**

- A `utils.py` or `helpers.py` file growing beyond 200 lines
- Error handling that swallows errors or uses generic messages
- Platform-specific code mixed with cross-platform code
- Abstractions created for single use cases
- Type assertions (`as any`) to bypass the type system
- Code that "works on my machine" but isn't tested cross-platform
