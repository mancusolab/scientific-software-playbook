---
description: Explain how to customize scientific plan-and-execute workflows with project guidance files
---

# Customizing Scientific Plan-and-Execute

You can provide project-specific guidance that shapes design and implementation planning.

## Guidance Files

Create a `.scientific/` directory in your project root with these optional files:

### `.scientific/design-plan-guidance.md`

Loaded before architecture/design clarification during `start-design-plan`.

What to include:
- Domain terminology and symbols
- Architecture constraints (required and forbidden patterns)
- Technology preferences (required/avoided tools)
- Scientific assumptions and risk boundaries
- Scope defaults (what is usually in/out)

### `.scientific/implementation-plan-guidance.md`

Loaded when starting an implementation plan and reused during implementation reviews.

What to include:
- Coding standards and file organization
- Test requirements and evidence expectations
- Review criteria beyond defaults
- Commit conventions
- Project-specific boundary rules (ingress/pipeline/numerics/CLI)

## Example: `.scientific/design-plan-guidance.md`

```markdown
# Design Guidance

## Domain Terms
- Observation: one row of measured assay data
- Batch: controlled acquisition session with shared calibration metadata

## Architecture Constraints
- Keep numerics functions array/PyTree-only
- Keep CLI and file parsing out of numerics

## Scope Defaults
- Schema migrations are in scope for model-shape changes
- New dashboards are out of scope unless explicitly requested
```

## Example: `.scientific/implementation-plan-guidance.md`

```markdown
# Implementation Guidance

## Coding Standards
- Preserve validation-first API boundaries
- Keep CLI shell thin and deterministic

## Testing Requirements
- Every behavior change starts with a failing test
- Include regression tests for each bug fix

## Review Criteria
- No unresolved critical/high findings
- Verification output must be fresh and explicit
```

Use this command when setting up or refreshing project-specific workflow constraints.
