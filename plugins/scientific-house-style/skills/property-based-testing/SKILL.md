---
name: property-based-testing
description: Use when writing tests for serialization, validation, normalization, or pure functions - provides property catalog, pattern detection, and library reference for property-based testing
user-invocable: false
metadata:
  short-description: Property-based testing
---

# Property-Based Testing

## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.

## Path Contract (Unambiguous)

1. This skill has no installation-local file dependencies and is valid in either runtime:
- Codex installation example: `${CODEX_HOME:-$HOME/.codex}/skills/property-based-testing/SKILL.md`
- Claude plugin installation example: `<claude-plugin-root>/skills/property-based-testing/SKILL.md`
2. For external library syntax, prefer primary docs and optionally `scientific-internet-research-pass` when that research skill is available.


## Overview

Property-based testing (PBT) generates random inputs and verifies that properties hold for all of them. Instead of testing specific examples, you test invariants.

**When PBT beats example-based tests:**
- Serialization pairs (encode/decode)
- Pure functions with clear contracts
- Validators and normalizers
- Data structure operations

## Property Catalog

| Property | Formula | When to Use |
|----------|---------|-------------|
| **Roundtrip** | `decode(encode(x)) == x` | Serialization, conversion pairs |
| **Idempotence** | `f(f(x)) == f(x)` | Normalization, formatting, sorting |
| **Invariant** | Property holds before/after | Any transformation |
| **Commutativity** | `f(a, b) == f(b, a)` | Binary/set operations |
| **Associativity** | `f(f(a,b), c) == f(a, f(b,c))` | Combining operations |
| **Identity** | `f(x, identity) == x` | Operations with neutral element |
| **Inverse** | `f(g(x)) == x` | encrypt/decrypt, compress/decompress |
| **Oracle** | `new_impl(x) == reference(x)` | Optimization, refactoring |
| **Easy to Verify** | `is_sorted(sort(x))` | Complex algorithms |
| **No Exception** | No crash on valid input | Baseline (weakest) |

**Strength hierarchy** (weakest to strongest):
```
No Exception -> Type Preservation -> Invariant -> Idempotence -> Roundtrip
```

Always aim for the strongest property that applies.

## Pattern Detection

**Use PBT when you see:**

| Pattern | Property | Priority |
|---------|----------|----------|
| `encode`/`decode`, `serialize`/`deserialize` | Roundtrip | HIGH |
| `toJSON`/`fromJSON`, `pack`/`unpack` | Roundtrip | HIGH |
| Pure functions with clear contracts | Multiple | HIGH |
| `normalize`, `sanitize`, `canonicalize` | Idempotence | MEDIUM |
| `is_valid`, `validate` with normalizers | Valid after normalize | MEDIUM |
| Sorting, ordering, comparators | Idempotence + ordering | MEDIUM |
| Custom collections (add/remove/get) | Invariants | MEDIUM |
| Builder/factory patterns | Output invariants | LOW |

## When NOT to Use

- Simple CRUD without transformation logic
- UI/presentation logic
- Integration tests requiring complex external setup
- Code with side effects that cannot be isolated
- Prototyping where requirements are fluid
- Tests where specific examples suffice and edge cases are understood

## Library Quick Reference

| Language | Library | Import |
|----------|---------|--------|
| Python | Hypothesis | `from hypothesis import given, strategies as st` |
| TypeScript/JS | fast-check | `import fc from 'fast-check'` |
| Rust | proptest | `use proptest::prelude::*` |
| Go | rapid | `import "pgregory.net/rapid"` |
| Java | jqwik | `@Property` annotations |
| Haskell | QuickCheck | `import Test.QuickCheck` |

**For library-specific syntax and patterns:** Use official library docs first; when needed, run `scientific-internet-research-pass` for current references.

## Input Strategy Best Practices

1. **Constrain early:** Build constraints INTO the strategy, not via `assume()`
   ```python
   # GOOD
   st.integers(min_value=1, max_value=100)

   # BAD - high rejection rate
   st.integers().filter(lambda x: 1 <= x <= 100)
   ```

2. **Size limits:** Prevent slow tests
   ```python
   st.lists(st.integers(), max_size=100)
   st.text(max_size=1000)
   ```

3. **Realistic data:** Match real-world constraints
   ```python
   st.integers(min_value=0, max_value=150)  # Real ages, not arbitrary ints
   ```

4. **Reuse strategies:** Define once, use across tests
   ```python
   valid_users = st.builds(User, ...)

   @given(valid_users)
   def test_one(user): ...

   @given(valid_users)
   def test_two(user): ...
   ```

## Settings Guide

```python
# Development (fast feedback)
@settings(max_examples=10)

# CI (thorough)
@settings(max_examples=200)

# Nightly/Release (exhaustive)
@settings(max_examples=1000, deadline=None)
```

## Quality Checklist

Before committing PBT tests:

- [ ] Not tautological (assertion doesn't compare same expression)
- [ ] Strong assertion (not just "no crash")
- [ ] Not vacuous (inputs not over-filtered by `assume()`)
- [ ] Edge cases covered with explicit examples (`@example`)
- [ ] No reimplementation of function logic in assertion
- [ ] Strategy constraints are realistic
- [ ] Settings appropriate for context

## Red Flags

- **Tautological:** `assert sorted(xs) == sorted(xs)` tests nothing
- **Only "no crash":** Always look for stronger properties
- **Vacuous:** Multiple `assume()` calls filter out most inputs
- **Reimplementation:** `assert add(a, b) == a + b` if that's how add is implemented
- **Missing edge cases:** No `@example([])`, `@example([1])` decorators
- **Overly constrained:** Many `assume()` calls means redesign the strategy

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Testing mock behavior | Test real behavior |
| Reimplementing function in test | Use algebraic properties |
| Filtering with assume() | Build constraints into strategy |
| No edge case examples | Add @example decorators |
| One property only | Add multiple properties (length, ordering, etc.) |
