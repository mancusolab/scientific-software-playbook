---
description: Define a simulation contract for inference validation (simulate API, assumption alignment, and calibration experiments)
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, WebSearch, WebFetch
model: sonnet
argument-hint: "[design-plan-path]"
---

# Start Simulation Validation

Design simulation support for inference validation.

## Inputs

1. Optional design plan path: `$1`

## Workflow

1. If `$1` is provided, load that design plan context.
2. Use `scientific-simulation-designer` to draft simulation design.
3. Use `simulation-for-inference-validation` to enforce required simulation contract details.
4. If simulation protocol assumptions are uncertain, run `scientific-internet-research-pass` and capture citations.
   - Delegate `internet-researcher` for general/API web evidence.
   - Delegate `scientific-literature-researcher` for paper-backed support.
5. Report:
- simulation contract (`simulate` inputs/outputs/seed policy)
- assumption-alignment summary (simulation vs inference)
- validation experiment set (recovery/SBC/PPC as applicable)
- status (`pass` or `blocked`)
6. If design plan exists, update `Simulation And Inference-Consistency Validation` section.

## Hard Stop

Stop and return `blocked` when model parameterization or inferential assumptions are not explicit.
