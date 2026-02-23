# Skill And Agent IO Checklist

Use this checklist when authoring or reviewing skills and agents in this project.

## Required Input Contract Checks
- [ ] Inputs are explicit (required vs optional fields are named).
- [ ] Input ambiguity triggers are listed.
- [ ] Missing-input behavior is defined (ask user, block, or apply assumption with note).
- [ ] Source artifacts are enumerated when relevant (for example LaTeX/images/model files).
- [ ] Early model-path branching is explicit (`provided-model` vs `suggested-model` when no model is supplied).
- [ ] Simulation scope trigger is explicit (when inference validation needs synthetic-data checks).

## Required Output Contract Checks
- [ ] Output artifact paths are explicit.
- [ ] Output schema/sections are explicit (minimum required fields).
- [ ] Decision output is explicit (`approved`, `in-review`, `blocked`, etc.).
- [ ] Evidence requirements are explicit (verification commands, test proof).
- [ ] Acceptance criteria are traceable to tasks and tests when implementation planning is in scope.
- [ ] External research claims are cited with source URL and access date when research triggers are present.
- [ ] Suggested-model outputs include candidate options, scientific citations, and explicit user selection.
- [ ] Simulation outputs include explicit simulate contract and validation experiment definitions when in scope.

## Hard Stop Checks
- [ ] Conditions that block downstream execution are explicitly listed.
- [ ] Hard stops map to severity levels in review outputs.
- [ ] Status transitions are constrained and validated.
- [ ] Implementation execution is blocked when required traceability artifacts are incomplete.
- [ ] Architecture/implementation readiness is blocked when research-triggered external claims are uncited.
- [ ] Architecture readiness is blocked when model-path decision or suggested-model evidence is missing.
- [ ] Architecture readiness is blocked when `provided-model` path is selected but model sources/update rules are missing.
- [ ] Architecture readiness is blocked when simulation is in scope but simulate contract/alignment checks are missing.

## Weighted Rigor Checks (100 points)

Use this table during architecture/numerics review authoring. The readiness
validator script is pass/fail and does not compute these weighted scores.

| Check | Weight | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Input contract completeness | 14 | | |
| Output contract completeness | 14 | | |
| Hard-stop specificity | 14 | | |
| Model-path and suggestion-evidence rigor | 12 | | |
| Simulation-design rigor | 12 | | |
| Verification evidence requirements | 12 | | |
| Test/TDD enforcement | 11 | | |
| External citation rigor | 6 | | |
| Review artifact consistency | 5 | | |

Approval recommendation should require:
1. No hard-stop failures.
2. Weighted score >= 90.
