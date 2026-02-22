# Skill And Agent IO Checklist

Use this checklist when authoring or reviewing skills and agents in this project.

## Required Input Contract Checks
- [ ] Inputs are explicit (required vs optional fields are named).
- [ ] Input ambiguity triggers are listed.
- [ ] Missing-input behavior is defined (ask user, block, or apply assumption with note).
- [ ] Source artifacts are enumerated when relevant (for example LaTeX/images/model files).

## Required Output Contract Checks
- [ ] Output artifact paths are explicit.
- [ ] Output schema/sections are explicit (minimum required fields).
- [ ] Decision output is explicit (`approved`, `in-review`, `blocked`, etc.).
- [ ] Evidence requirements are explicit (verification commands, test proof).

## Hard Stop Checks
- [ ] Conditions that block downstream execution are explicitly listed.
- [ ] Hard stops map to severity levels in review outputs.
- [ ] Status transitions are constrained and validated.

## Weighted Rigor Checks (100 points)

Use this table during architecture/numerics review authoring. The readiness
validator script is pass/fail and does not compute these weighted scores.

| Check | Weight | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Input contract completeness | 20 | | |
| Output contract completeness | 20 | | |
| Hard-stop specificity | 20 | | |
| Verification evidence requirements | 15 | | |
| Test/TDD enforcement | 15 | | |
| Review artifact consistency | 10 | | |

Approval recommendation should require:
1. No hard-stop failures.
2. Weighted score >= 90.
