# Test Requirements

Use this file to enforce acceptance-criteria-to-test traceability.

## Requirements Matrix
| Test ID | AC ID | Phase | Task IDs | Test Type | Command | Failure-First Evidence Required | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TEST-001 | __SLUG__.AC1 | 1 | 1 | unit | `pytest -q path/to/test.py::test_name` | yes | blocked |

## Test Types
- `unit`: single function/module behavior
- `integration`: boundary crossing and API composition
- `property`: invariants and edge behavior
- `cli-contract`: stdout/stderr/exit-code and parse behavior
- `numerics-regression`: solver result/stability/transform behavior
- `simulation-calibration`: parameter recovery, SBC, or posterior predictive simulation checks

## Hard Requirements
1. Every AC must have at least one mapped test.
2. Every behavior-changing task must have failure-first evidence.
3. Every bug fix must include a regression test.
4. Phase completion is blocked when mapped tests are missing or failing.
