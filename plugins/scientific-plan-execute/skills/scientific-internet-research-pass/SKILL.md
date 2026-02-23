---
name: scientific-internet-research-pass
description: Use when architecture or implementation planning depends on uncertain external facts - runs a scoped internet research pass using primary sources and produces citable claims with confidence notes.
---

# Scientific Internet Research Pass

Run a formal research loop when plan correctness depends on external, potentially changing facts.

## Path Contract (Unambiguous)

1. This skill has no installation-local playbook file dependencies.
2. Source references are URLs/citations, not filesystem paths in Codex or Claude plugin installs.

## Input Contract

Required inputs:
1. Research scope:
- architecture planning or implementation planning
2. Research questions/claims to verify.
3. Domain context (for example: JAX/Equinox API behavior, solver docs, scientific data format specs).

Optional inputs:
1. Preferred source domains.
2. Recency requirements.
3. User-provided candidate references.

## Output Contract

This skill must produce:
1. Cited claim table with:
- claim ID
- claim text
- source URL
- source type (`official-doc`, `paper`, `standard`, `reference-implementation`, `secondary`)
- access date
- confidence (`high`, `medium`, `low`)
2. Decision impact summary:
- what changed in the plan because of research
- what remained unchanged
3. Open uncertainties:
- unresolved questions
- recommended follow-up
4. Explicit status:
- `pass` | `blocked`

## Research Trigger Matrix

Run this pass when any are true:
1. External API/library behavior is uncertain or version-sensitive.
2. Solver semantics/options are unclear in current upstream docs.
3. Domain scientific file format interpretation is uncertain.
4. Compliance/standard requirements are claimed but uncited.
5. Performance/reproducibility claims depend on external benchmarks/docs.
6. The plan includes “latest/current/recent” assumptions without sources.

## Workflow

1. Normalize research questions into concrete, testable claims.
2. Use `scientific-internet-researcher` when available for delegated evidence collection.
3. Prioritize primary sources:
- official docs
- standards/specifications
- peer-reviewed papers
- reference implementations
4. Gather evidence and map each claim to at least one citation.
5. Mark source stability:
- `stable` (spec/standard/core API contract)
- `unstable` (blog/forum/changelog-only behavior)
6. Record confidence and any contradictions.
7. Emit decision impact summary for architecture/implementation plan updates.
8. If required claims lack acceptable citations, return `blocked`.

## Citation Rules

1. Every non-trivial external claim must have at least one citation.
2. Prefer primary sources over summaries.
3. Secondary sources are allowed only when primary sources are unavailable; mark confidence `low` or `medium`.
4. Include access date for every citation.
5. Distinguish direct evidence from inference.

## Hard Stops

1. Do not mark research `pass` if critical claims are uncited.
2. Do not claim version-specific behavior without citing versioned docs/changelog.
3. Do not treat anecdotal discussion as definitive evidence without explicit caveat.
4. If web access is unavailable and critical claims are unresolved, return `blocked` and request user-provided sources.
