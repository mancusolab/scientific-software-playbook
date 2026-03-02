# Tutorial: Rebuild LDSC with JAX ![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=flat-square&logo=claude&logoColor=white)

This tutorial walks through porting LD Score Regression (LDSC) from NumPy to JAX using the playbook's kickoff and design workflow. By the end, you'll have seen how the workflow guides decisions from "port this codebase" to a complete design plan ready for implementation.

For conceptual background on the workflow phases, model paths, and commands, see `docs/ONBOARDING.md`.

## Prerequisites

The playbook plugins must be installed. See `docs/INSTALLATION.md`.

---

## 1. Running Kickoff

Start by invoking the router:

```
/using-plan-and-execute
```

Describe your goal:

> "We have the Bulik-Sullivan LDSC implementation in NumPy. Port the full workflow — munging, LD score computation, h2, and rg estimation — to JAX/Equinox with numerical parity."

The router recognizes this as an existing-codebase port and directs you to `scientific-kickoff` with `existing-codebase-port` mode.

### Step 1: Provide source pin

The system asks for the source implementation location:

- **Source type:** `github-url`
- **URL:** `https://github.com/bulik/ldsc`
- **Commit/tag:** `aa33296`

### Step 2: Define parity tolerance

```
What numerical parity tolerance do you require for the port?

❯ 1. Strict (rtol=1e-5, atol=1e-8)
     Results must match within floating-point precision for scientific reproducibility
  2. Moderate (rtol=1e-3, atol=1e-6)
     Results should be very close but minor numerical differences are acceptable
  3. Functional equivalence
     Same scientific conclusions; minor numerical drift from JAX optimizations is acceptable
```

Select **Strict** — the reference implementation is ground truth.

### Step 3: Define behavior targets

| Behavior | Surface | Target | Evidence plan |
|----------|---------|--------|--------------|
| Univariate h2 estimate | `numerics` | Match reference within `rtol=1e-5` | Golden output comparison on fixture data |
| Intercept estimate | `numerics` | Match reference within `rtol=1e-5` | Same test data |
| Block-jackknife standard errors | `numerics` | Match within `rtol=1e-3` | Looser tolerance for solver differences |
| Cross-trait genetic correlation | `numerics` | Match within `rtol=1e-5` | Two-trait test case |
| Summary stat munging | `io` | Same column recognition and QC filters | Compare munged output files |
| LD score computation | `numerics` | Match reference LD scores from PLINK input | Fixture-based comparison |
| CLI exit codes | `cli` | 0 on success, non-zero on input error | End-to-end CLI tests |

### Step 4: Define exclusions

- Partitioned heritability — separate feature, future work
- Plotting utilities
- Python 2 compatibility code

### Step 5: Codebase investigation

The system runs `scientific-codebase-investigation-pass` and produces findings:

| Finding ID | Source scope | Summary |
|-----------|-------------|---------|
| PORT-INV-1 | `ldscore/regressions.py` | Core regression logic in `Hsq` class; WLS with LD weights |
| PORT-INV-2 | `ldscore/regressions.py` | `Gencov` class extends `Hsq` for cross-trait correlation |
| PORT-INV-3 | `ldscore/regressions.py` | Block jackknife for SE in `_jknife` method |
| PORT-INV-4 | `ldscore/sumstats.py` | Flexible column name matching (~50 variants) |
| PORT-INV-5 | `ldscore/ldscore.py` | LD score computation from PLINK genotypes |
| PORT-INV-6 | `test/` | Test fixtures with expected outputs |
| PORT-INV-7 | `requirements.txt` | NumPy-only numerics |

### Step 6: Simulation contract

The system asks about simulation-based validation. You say **yes** and define:

| Experiment | Type | Success criterion |
|-----------|------|------------------|
| SIM-1 | Parameter recovery | Estimated h2 within 2 SE of true h2 |
| SIM-2 | Calibration | Mean chi2 ≈ 1 under null |
| SIM-3 | Intercept recovery | Within `rtol=0.05` of true intercept |

### Step 7: Kickoff output

The system writes `.scientific/kickoff.md` with all readiness states set to `yes`.

### Step 8: Handoff

Start a fresh session and run `/using-plan-and-execute` again. The router detects kickoff is complete and automatically starts design planning.

---

## 2. Design Planning

The design workflow ingests kickoff output and runs six phases.

### Phase 1: Context gathering

Describe project goals:

> "Full JAX/Equinox port of LDSC: summary stat munging, LD score computation from PLINK genotypes, univariate h2 estimation, and cross-trait rg estimation."

### Phase 2: Clarification

The system presents structured questions by category:

```
←  ☐ CLI design  ☐ LD Score input  ☐ Versions  ☐ Architecture  ✔ Submit  →
```

**CLI design:**
```
How should the CLI interface be structured?

❯ 1. Mirror original LDSC CLI exactly
  2. Modern CLI with subcommands
  3. Library-first, minimal CLI
```
→ Select **Modern CLI with subcommands**

**LD Score input:**
```
Should the port include PLINK BED file reading, or assume pre-computed LD scores?

❯ 1. Include BED parsing (full port)
  2. Pre-computed LD scores only
```
→ Select **Include BED parsing**

**Versions:**
```
What is the target Python version and JAX compatibility?

❯ 1. Python 3.10+, latest JAX
  2. Python 3.9+, JAX 0.4+
```
→ Select **Python 3.10+, latest JAX**

**Architecture:**
```
How should the JAX port be organized architecturally?

❯ 1. FCIS: Functional Core, Imperative Shell
  2. Equinox modules throughout
  3. Hybrid: eqx.Module for models, pure functions for algorithms
```
→ Select **FCIS**

### Phase 3: Definition of Done

The system synthesizes completion criteria:

```
Definition of Done:

1. A Python package ldsc-jax implementing:
   - Summary statistics munging (munge subcommand)
   - LD Score computation from Plink BED files (ldscore subcommand)
   - Heritability estimation (h2 subcommand)
   - Genetic correlation estimation (rg subcommand)

2. Strict numerical parity with the original bulik/ldsc implementation:
   - All outputs match within rtol=1e-5, atol=1e-8
   - Parity test suite comparing JAX vs NumPy outputs on reference data

3. FCIS architecture with:
   - Pure JAX functional core for all numerics
   - Polars-based ingress for tabular data
   - Thin CLI shell with subcommands

4. Simulation-based validation with:
   - simulate_h2 and simulate_rg APIs per kickoff contract
   - Parameter recovery tests

5. Testing infrastructure:
   - pytest + hypothesis for property-based tests
   - Parity tests against reference implementation
```

### Phase 4: Brainstorming

```
Which architectural approach do you prefer?

❯ 1. Approach A: Module-Parallel (Recommended)
     Clean FCIS with 1:1 module mapping to original code
  2. Approach B: Algorithm-Centric
  3. Approach C: Equinox-Hybrid
```
→ Select **Module-Parallel** for straightforward parity verification

After brainstorming, confirm the proposed design structure before proceeding.

### Phase 5: Design documentation

The system writes the design plan to `docs/design-plans/2026-03-01-ldsc-jax-port.md` with:
- Model acquisition path from kickoff
- Required workflow states
- Codebase investigation findings
- Layer contracts
- Implementation phases
- Acceptance criteria

**Companion artifacts** in `docs/design-plans/artifacts/2026-03-01-ldsc-jax-port/`:
- `model-symbol-table.md`
- `equation-to-code-map.md`
- `solver-feasibility-matrix.md`

### Phase 6: Planning handoff

The system commits the design document to git and provides handoff instructions for implementation planning.

---

## 3. Validation and Approval

### Validation for `in-review`

```
/validate-design-plan docs/design-plans/2026-03-01-ldsc-jax-port.md --phase in-review
```

Checks: Definition of Done filled, acceptance criteria present, model path decided.

### Validation for `approval`

```
/validate-design-plan docs/design-plans/2026-03-01-ldsc-jax-port.md --phase approval
```

Enforces hard stops for `existing-codebase-port`:
- Source pin present
- Behavior inventory populated
- Codebase investigation complete
- Simulation contract defined (if in scope)

### Approving the plan

```
/set-design-plan-status docs/design-plans/2026-03-01-ldsc-jax-port.md approved-for-implementation
```

---

## 4. What Happens Next

After approval:

1. **Implementation planning** (`/start-implementation-plan`) — Creates task files for each phase
2. **Execution** (`/execute-implementation-plan`) — Phase-by-phase implementation with TDD

---

## 5. The Final Output: `jax-ldsc`

The result is [`jax-ldsc`](https://github.com/CamelliaRui/jax-ldsc) — a JAX-based port of LD Score Regression.

### Repository structure

```
jax-ldsc/
├── .scientific/           # Kickoff and workflow state
├── docs/                   # Design plans and documentation
├── ldsc_jax/               # Main package
│   ├── cli/                # CLI subcommands
│   ├── core/               # Pure JAX numerics (functional core)
│   │   ├── irwls.py        # Iteratively reweighted least squares
│   │   ├── jackknife.py    # Block jackknife for standard errors
│   │   ├── ldscore.py      # LD score computation
│   │   ├── regression.py   # Core regression routines
│   │   ├── stats.py        # Statistical utilities
│   │   ├── types.py        # Type definitions
│   │   └── weights.py      # Regression weighting schemes
│   ├── ingress/            # Data loading (imperative shell)
│   ├── munge/              # Summary statistics canonicalization
│   └── sim/                # Simulation for validation
├── tests/                  # Test suite
└── pyproject.toml          # Project configuration
```

### How human decisions shaped the code

| Decision | Phase | Answer |
|----------|-------|--------|
| Block-jackknife SE (not AD) | Clarification | Keep jackknife only for parity |
| FCIS with 1:1 module mapping | Brainstorming | Module-Parallel for parity verification |
| Polars at ingress boundary | Clarification | Faster, cleaner column operations |
| Modern CLI with subcommands | Clarification | `ldsc-jax h2`, `ldsc-jax rg` |
| Include BED parsing | Clarification | Full port with genotype→LD score |
| Python 3.10+, latest JAX | Clarification | Modern typing worth narrower compatibility |

---

## Quick Reference

### Commands

| Step | Command | What it does |
|------|---------|-------------|
| Entry point | `/using-plan-and-execute` | Router for workflow entry |
| Start kickoff | `/start-scientific-kickoff` | Model path selection |
| Validate | `/validate-design-plan <path> --phase <phase>` | Check readiness |
| Approve | `/set-design-plan-status <path> approved-for-implementation` | Approve for implementation |
| Implementation | `/start-implementation-plan <path>` | Create task files |
| Execute | `/execute-implementation-plan <plan-dir> <working-dir>` | Run implementation |

### Readiness states for `existing-codebase-port`

| State | Required |
|-------|----------|
| `model_path_decided` | `yes` |
| `codebase_investigation_complete_if_port` | `yes` |
| `simulation_contract_complete_if_in_scope` | `yes` or `n/a` |

### Files created

| File | Purpose |
|------|---------|
| `.scientific/kickoff.md` | Model path decision and readiness state |
| `docs/design-plans/YYYY-MM-DD-<slug>.md` | Architecture and contracts |
| `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/` | Symbol table, equation map, solver matrix |
