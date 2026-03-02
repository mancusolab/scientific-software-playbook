# Tutorial: Kickoff and Design Plan

This tutorial walks through the playbook's kickoff and design-plan workflow using a statistical genetics example: porting LD Score Regression (LDSC) from NumPy to JAX.

By the end you will understand:
- How `using-plan-and-execute` routes you to the correct workflow entry point
- What kickoff does and when to run it (vs. when to skip it)
- The three model-acquisition paths (with genetics examples for each)
- How `existing-codebase-port` works in detail
- How kickoff hands off to design planning
- What the design plan contains and how it gets approved

## Prerequisites

The playbook plugins must be installed. See `docs/INSTALLATION.md`.

---

## 0. The Entry Point: `using-plan-and-execute`

Before diving into kickoff, understand how you actually start the workflow.

**The first step is always `using-plan-and-execute`.** This is a router skill that decides which workflow entry point fits your situation. You don't jump directly into kickoff or design planning — the router examines your request and directs you appropriately.

### How the router decides

| Your situation | Router directs you to |
|----------------|----------------------|
| Fresh project, model path not yet decided | `scientific-kickoff` → then `starting-a-design-plan` |
| User requests model suggestions with citations | `scientific-kickoff` (suggested-model mode) |
| Porting an existing codebase | `scientific-kickoff` (existing-codebase-port mode) |
| Existing project with established model/contract | `starting-a-design-plan` directly (skip kickoff) |
| Approved design ready for implementation | `starting-an-implementation-plan` |
| Implementation plan already exists | `executing-an-implementation-plan` |

### The flow

```
using-plan-and-execute (START HERE)
    │
    ├─→ scientific-kickoff (when model path needs deciding)
    │       ↓
    ├─→ starting-a-design-plan (architecture design)
    │       ↓
    └─→ starting-an-implementation-plan (build it)
```

### When kickoff is required vs. optional

**Kickoff is required** when any of these apply:
- Model path is not yet selected
- User requests model-family suggestions with citations
- User requests existing-codebase porting
- Parity expectations against an existing implementation must be defined

**Kickoff is skipped** when:
- Model and software contract are already established
- Working on a scoped feature in an existing project
- The router determines model provenance is already clear

For this tutorial, we're porting LDSC — an existing codebase — so the router will direct us to kickoff with `existing-codebase-port` mode.

---

## 1. Why Kickoff Exists

Scientific software projects fail in predictable ways. A common one: the team starts coding before agreeing on where the model comes from. Two weeks in, someone realizes the "reference implementation" everyone assumed they'd follow was actually a different version, or the equations came from a preprint that was later revised.

Kickoff prevents this. It forces exactly one decision — **where does the model come from?** — and records it before design planning begins.

The output is a small file (`.scientific/kickoff.md`) that the design-plan workflow reads as its starting constraint.

## 2. The Three Model Paths

Kickoff offers three modes. You pick one.

| Path | You have... | Kickoff collects... |
|------|------------|-------------------|
| `provided-model` | Equations, update rules, or model artifacts | Source files/URLs, solver preference, known math risks |
| `suggested-model` | A scientific objective but no specific model yet | Candidate model families with citations, your explicit selection |
| `existing-codebase-port` | A working implementation you want to rewrite | Source pin, behavior/parity targets, codebase investigation findings |

### Statistical genetics examples for each path

**`provided-model`** — You have the mixed-model equations for GWAS and want to implement them in JAX:

> "Here are the REML equations for estimating variance components from a GRM. I have the likelihood, gradient, and AI update rule written out. Implement these."

Kickoff records your equations, notes which solver you prefer (custom AI-REML updates vs. a generic optimizer), and flags any mathematical unknowns.

**`suggested-model`** — You need a fine-mapping method but haven't committed to one:

> "I have GWAS summary statistics and LD reference panels. I need a method to identify causal variants in each locus. What model families fit?"

Kickoff triggers a literature search, proposes 2-3 candidates (SuSiE, FINEMAP, DAP-G) with citations, and waits for you to explicitly select one before proceeding.

**`existing-codebase-port`** — You have the `ldsc` Python package and want a JAX version:

> "We have the Bulik-Sullivan LDSC implementation in NumPy. Port the full workflow — munging, LD score computation, h2, and rg estimation — to JAX/Equinox with numerical parity."

Kickoff pins the source, defines what "parity" means numerically, and investigates the source codebase file by file. This is the path we'll walk through below.

---

## 3. Deep Dive: `existing-codebase-port`

This is the most involved kickoff mode. It exists because porting scientific code is deceptively hard — the reference implementation is the ground truth, and any deviation needs to be intentional and documented.

### What kickoff collects

**Source pin.** A specific commit or tag of the reference implementation. Not "the ldsc repo" but `github.com/bulik/ldsc` at commit `aa33296`. This makes parity checks reproducible — if the upstream changes, your parity baseline doesn't drift.

**Behavior/parity targets.** Which outputs must match, and how closely. For LDSC this might be:
- Heritability point estimate (`h2`) matches within `rtol=1e-5`
- Intercept matches within `rtol=1e-5`
- Block-jackknife standard errors match within `rtol=1e-3`
- Cross-trait genetic correlation matches within `rtol=1e-5`

**Explicit exclusions.** What you will not port. For LDSC:
- Partitioned heritability (out of scope for v1)
- Plotting and visualization code
- Python 2 compatibility paths

**Codebase investigation.** The system runs `scientific-codebase-investigation-pass`, which reads through the source repo and produces file-level findings: module layout, key classes and functions, data formats, test fixtures, and dependencies. For LDSC, this would discover:
- `ldscore/regressions.py` contains the core `Hsq` and `Gencov` classes
- `ldscore/sumstats.py` handles summary statistic parsing
- `ldscore/ldscore.py` computes LD scores from genotype data
- Tests in `test/` with golden output files
- NumPy is the only numerical dependency (no SciPy optimization — LDSC uses direct WLS)

This investigation must complete before kickoff can mark `codebase_investigation_complete_if_port: yes`. Without it, the design plan cannot be approved — this is a hard stop.

### Why these steps matter

Each piece prevents a specific failure mode:

| Step | Prevents... |
|------|------------|
| Source pin | "Which version were we porting from?" confusion |
| Parity targets | Ambiguous "close enough" arguments during review |
| Exclusions | Scope creep into features nobody asked for |
| Codebase investigation | Design assumptions that don't match the actual source code |

---

## 4. Worked Example: Running Kickoff for LDSC

Here is what each step looks like in practice.

### Step 1: Start with the router

Claude Code:
```
/using-plan-and-execute
```

You describe your goal:

> "We have the Bulik-Sullivan LDSC implementation in NumPy. Port the full workflow — munging, LD score computation, h2, and rg estimation — to JAX/Equinox with numerical parity."

The router recognizes this as an existing-codebase port scenario. It determines that:
- Model path is not yet formally decided
- Parity expectations against an existing implementation must be defined
- Codebase investigation is required before design can proceed

The router directs you to `scientific-kickoff` with `existing-codebase-port` mode.

### Step 2: Kickoff begins

The kickoff skill loads and confirms the mode: `existing-codebase-port`.

### Step 3: Provide source pin

The system asks for the source implementation location. You provide:

- **Source type:** `github-url`
- **URL:** `https://github.com/bulik/ldsc`
- **Commit/tag:** `aa33296` (or whatever the latest stable commit is)

### Step 4: Define behavior/parity targets

The system first asks about your overall numerical parity tolerance:

```
What numerical parity tolerance do you require for the port?

❯ 1. Strict (rtol=1e-5, atol=1e-8)
     Results must match within floating-point precision for scientific reproducibility
  2. Moderate (rtol=1e-3, atol=1e-6)
     Results should be very close but minor numerical differences are acceptable
  3. Functional equivalence
     Same scientific conclusions; minor numerical drift from JAX optimizations is acceptable
```

You select **Strict** — this is a codebase port where the reference implementation is ground truth, so primary estimates should match closely. You can specify looser tolerances for specific outputs (like standard errors) in the detailed behavior table.

The system then asks what specific behaviors must be preserved. You specify:

| Behavior | Surface | Target | Evidence plan |
|----------|---------|--------|--------------|
| Univariate h2 estimate | `numerics` | Match reference within `rtol=1e-5` | Golden output comparison on fixture data |
| Intercept estimate | `numerics` | Match reference within `rtol=1e-5` | Same test data |
| Block-jackknife standard errors | `numerics` | Match within `rtol=1e-3` | Same SE method as reference; looser tolerance for solver differences |
| Cross-trait genetic correlation | `numerics` | Match within `rtol=1e-5` | Two-trait test case |
| Summary stat munging | `io` | Same column recognition and QC filters | Compare munged output files |
| LD score computation | `numerics` | Match reference LD scores from PLINK input | Fixture-based comparison |
| CLI exit codes | `cli` | 0 on success, non-zero on input error | End-to-end CLI tests |

Note that block-jackknife SE uses a looser tolerance (`rtol=1e-3`) than the strict default because jackknife involves more numerical operations where small differences can accumulate.

### Step 5: Define exclusions

You list what's out of scope:
- Partitioned heritability — separate feature, future work
- Plotting utilities
- Python 2 compatibility code

### Step 6: Codebase investigation runs

The system launches `scientific-codebase-investigation-pass` against the pinned source. It produces findings like:

| Finding ID | Source scope | Summary | Evidence |
|-----------|-------------|---------|----------|
| PORT-INV-1 | `ldscore/regressions.py` | Core regression logic in `Hsq` class; uses weighted least squares with LD score weights | `regressions.py:45-180` |
| PORT-INV-2 | `ldscore/regressions.py` | `Gencov` class extends `Hsq` for cross-trait genetic correlation | `regressions.py:182-260` |
| PORT-INV-3 | `ldscore/regressions.py` | Block jackknife for standard errors in `_jknife` method | `regressions.py:88-120` |
| PORT-INV-4 | `ldscore/sumstats.py` | Summary statistic parsing reads `.sumstats.gz` format; flexible column name matching (~50 variants) | `sumstats.py:15-60` |
| PORT-INV-5 | `ldscore/ldscore.py` | LD score computation from PLINK genotypes within genomic windows | `ldscore.py:1-200` |
| PORT-INV-6 | `test/` | Test fixtures include small simulated datasets and expected outputs | `test/test_regressions.py` |
| PORT-INV-7 | `requirements.txt` | NumPy-only numerics (no SciPy optimization) | `requirements.txt:1` |

### Step 7: Simulation scope question

The system asks whether simulation-based inference validation is in scope. You say **yes** — you want to verify that the JAX LDSC implementation recovers known heritability from simulated summary statistics.

The `simulation-for-inference-validation` skill runs and defines:

**Simulate function:**
```
simulate_sumstats(h2, n_snps, n_samples, ld_scores, intercept=1.0, seed=0)
  -> (chi2_stats, true_params)
```

**Validation experiments:**
| Experiment | Type | Success criterion |
|-----------|------|------------------|
| SIM-1 | Parameter recovery | Estimated h2 within 2 SE of true h2 across 100 replicates |
| SIM-2 | Calibration | Mean chi2 of z-scores ≈ 1 under null (h2=0) |
| SIM-3 | Intercept recovery | Estimated intercept within `rtol=0.05` of true intercept |

### Step 8: Kickoff output written

The system writes `.scientific/kickoff.md`:

```markdown
mode: existing-codebase-port
model_path_decided: yes
codebase_investigation_complete_if_port: yes
simulation_contract_complete_if_in_scope: yes

## Source Pin
- type: github-url
- url: https://github.com/bulik/ldsc
- commit: aa33296

## Behavior/Parity Targets
- Univariate h2: rtol=1e-5
- Intercept: rtol=1e-5
- Block-jackknife SE: rtol=1e-3
- Cross-trait rg: rtol=1e-5
- Summary stat munging: same column recognition + QC filters
- LD score computation: match reference from PLINK input
- CLI exit codes: 0/non-zero contract

## Exclusions
- Partitioned heritability
- Plotting utilities
- Python 2 compatibility

## Codebase Investigation
Completed. 7 findings recorded (PORT-INV-1 through PORT-INV-7).
Key: core regression in Hsq/Gencov classes, WLS with LD weights,
block jackknife for SE, flexible sumstats parsing, LD score
computation from genotypes, NumPy-only numerics.

## Simulation Contract
simulate_sumstats defined. 3 validation experiments (SIM-1, SIM-2, SIM-3).
```

### Step 9: Handoff

Kickoff completes and saves its output to `.scientific/kickoff.md`.

To continue, start a fresh session and run the router again:

```
/using-plan-and-execute
```

The router detects `.scientific/kickoff.md` exists with `model_path_decided: yes`. Since kickoff is complete, the router automatically directs you to `starting-a-design-plan` — no need to invoke it manually.

---

## 5. From Kickoff to Design Plan

### What happens when you run `/using-plan-and-execute` after kickoff

The router checks for `.scientific/kickoff.md`. Finding it with all readiness states set, it automatically starts the design workflow. The design workflow ingests the kickoff output and carries forward:
- Mode: `existing-codebase-port`
- All readiness states
- Source pin, parity targets, exclusions, investigation findings
- Simulation contract

This means the design conversation already knows the model path. It won't re-ask "where does the model come from?" — that's settled.

### The six design phases

**Phase 1: Context gathering.** The system asks about project goals, constraints, and technical requirements. For LDSC-JAX, you say:

> "Full JAX/Equinox port of LDSC: summary stat munging, LD score computation from PLINK genotypes, univariate h2 estimation, and cross-trait rg estimation. Keep the same block-jackknife SE method as the reference. Use Polars for tabular data handling at the ingress boundary. CLI with separate subcommands for each workflow."

**Phase 2: Clarification.** The `asking-clarifying-questions` skill resolves ambiguities through structured questions grouped by category. You'll see a tabbed interface:

```
←  ☐ CLI design  ☐ LD Score input  ☐ Versions  ☐ Architecture  ✔ Submit  →
```

The system walks through each category, presenting multiple-choice questions. Here are the key questions for LDSC:

**CLI design:**

```
How should the CLI interface be structured?

❯ 1. Mirror original LDSC CLI exactly
     Same flags and subcommands (ldsc.py --h2, --rg, --l2) for drop-in replacement
  2. Modern CLI with subcommands
     ldsc-jax munge, ldsc-jax h2, ldsc-jax rg - cleaner but different from original
  3. Library-first, minimal CLI
     Focus on Python API; CLI is thin wrapper for basic workflows only
```

You select **Modern CLI with subcommands** — cleaner UX with `ldsc-jax h2`, `ldsc-jax rg`, etc. While not a drop-in replacement for the original CLI flags, the modern subcommand structure is more intuitive and matches current CLI conventions. Users calling from scripts will need minor adjustments, but the improved ergonomics are worth it.

**LD Score input:**

```
Should the port include PLINK BED file reading, or assume pre-computed LD scores?

❯ 1. Include BED parsing (full port)
     Port the genotype→LD Score computation from BED/BIM/FAM files
  2. Pre-computed LD scores only
     Accept .l2.ldscore files; skip genotype processing (simplifies scope)
```

You select **Include BED parsing** — full port means users can compute LD scores from genotypes, not just consume pre-computed ones. This matches the reference LDSC capability.

**Versions:**

```
What is the target Python version and JAX compatibility?

❯ 1. Python 3.10+, latest JAX
     Modern typing, latest JAX features, narrower compatibility
  2. Python 3.9+, JAX 0.4+
     Broader compatibility, some typing limitations
```

You select **Python 3.10+, latest JAX** — modern typing features (like `X | None` syntax) and latest JAX capabilities are worth the narrower compatibility window. Most scientific users are on recent Python versions.

**Architecture:**

```
How should the JAX port be organized architecturally?

❯ 1. FCIS: Functional Core, Imperative Shell
     Pure JAX numerics in core module; Polars ingress and CLI in separate shell layers
  2. Equinox modules throughout
     Use eqx.Module classes for all stateful components (regression models, jackknife, etc.)
  3. Hybrid: eqx.Module for models, pure functions for algorithms
     Models as Equinox modules; jackknife/IRWLS as pure JAX functions
```

You select **FCIS: Functional Core, Imperative Shell** — clean separation between pure JAX numerics (JIT-compilable, testable, no side effects) and the imperative shell (Polars I/O, CLI argument parsing, file handling). This matches the playbook's layer contracts and makes the numerics code easy to verify against the reference implementation.

Additional dependency decisions resolved during clarification:
- **Tabular data library:** Polars — faster, no global index, cleaner column operations. Convert to JAX arrays at the numerics boundary.
- **Linear algebra solvers:** Lineax — tagged operators so the solver can exploit matrix properties (symmetric, positive semidefinite), configurable solver options (Cholesky, QR, SVD) without rewriting.

Additional clarifications resolved:
- "Should we implement AD-based SE as an alternative to block-jackknife?" → **No. Keep jackknife only.** Parity with reference is the priority.
- "Cross-trait rg: handle arbitrary numbers of traits, or exactly two?" → **Pairwise (two traits).** Match reference behavior.
- "Include cell-type-specific h2 (`h2-cts`)?" → **Yes.** Users expect it from any LDSC tool.

**Phase 3: Definition of Done.** The system synthesizes what "done" means based on your clarification answers:

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
   - Pure JAX functional core for all numerics (LD scores, regression, jackknife)
   - Polars-based ingress for tabular data (sumstats, LD score files)
   - Thin CLI shell with subcommands

4. Simulation-based validation with:
   - simulate_h2 and simulate_rg APIs per kickoff contract
   - Parameter recovery tests (h², intercept, rg)
   - NumPy parity tests on identical random seeds

5. Testing infrastructure:
   - pytest + hypothesis for property-based tests
   - Parity tests against reference NumPy implementation
   - Simulation recovery tests
```

You confirm these criteria.

**Phase 4: Brainstorming.** The `brainstorming` skill explores design alternatives through structured questions:

```
☐ Architecture

Which architectural approach do you prefer?

❯ 1. Approach A: Module-Parallel (Recommended)
     Clean FCIS with 1:1 module mapping to original code
  2. Approach B: Algorithm-Centric
     Fewer files, consolidated numerics module
  3. Approach C: Equinox-Hybrid
     eqx.Module for regression models, pure functions for algorithms
```

You select **Approach A: Module-Parallel** — clean FCIS architecture with a 1:1 module mapping to the original code. This makes parity verification straightforward: each module in the JAX port corresponds to a module in the reference implementation. The functional core contains pure JAX numerics, while the imperative shell handles Polars I/O and CLI.

After brainstorming, the system proposes a design structure and asks for confirmation before proceeding to plan writing. This is your chance to review the proposed module layout, layer boundaries, and key design decisions. If the structure looks good, confirm to proceed; otherwise, provide feedback to refine the design.

**Phase 5: Design documentation.** The `writing-design-plans` skill writes the design plan to `docs/design-plans/2026-02-27-ldsc-jax-port.md`. The key sections it fills:

**Model Acquisition Path** — Pre-populated from kickoff:
```
- Path: existing-codebase-port
- Why this path: Reference NumPy implementation exists and is the ground truth
  for LDSC behavior. Port preserves established methodology while gaining
  JAX benefits (AD, GPU).
- User selection confirmation: Confirmed during kickoff.
```

**Required Workflow States** — All green:
```
- model_path_decided: yes
- codebase_investigation_complete_if_port: yes
- simulation_contract_complete_if_in_scope: yes
```

**Existing Codebase Port Contract** — Source pin and behavior inventory from kickoff.

**Codebase Investigation Findings** — The PORT-INV table from kickoff, now in the design plan.

**Layer Contracts:**
```
Ingress:
- jax_ldsc/io/parsing.py: read sumstats, LD scores, annotations,
  SNP counts via Polars DataFrames
- jax_ldsc/munge.py: canonicalize raw GWAS sumstats — flexible column
  name matching (~50 variants), QC filters (INFO >= 0.9, MAF >= 0.01),
  strand-ambiguous variant filtering
- Reject: missing required columns, non-positive N, invalid alleles

Pipeline:
- jax_ldsc/ldscore.py: compute LD scores from PLINK genotypes within
  genomic windows (configurable: SNPs, kb, or cM)
- Convert Polars DataFrames to JAX/NumPy arrays at numerics boundary

Numerics:
- jax_ldsc/regression/wls.py: weighted least squares via Lineax with
  tagged operators (symmetric, positive semidefinite). JIT-compiled
  via @eqx.filter_jit. Configurable solver (Cholesky default, QR,
  SVD, LU). Optional ridge regularization.
- jax_ldsc/regression/h2.py: heritability estimation with IRWLS
  (2 iterations) + block-jackknife SE (~200 blocks default)
- jax_ldsc/regression/rg.py: pairwise genetic correlation estimation

Egress:
- jax_ldsc/results.py: structured result codes (successful,
  invalid_input, numerical_failure, io_error, not_implemented)
- jax_ldsc/cli.py: 5 subcommands (munge, h2, rg, h2-cts, l2).
  JSON to stdout. Exit 0 on success, 1 on runtime failure, 2 on
  usage error.
```

**Implementation Phases** (example):

| Phase | Goal | Done when |
|-------|------|-----------|
| 1 | Project scaffold, dependencies, CI | `pytest` runs, `pyright` passes on empty package |
| 2 | Ingress: Polars-based sumstats/LD score parsing | Parser reads reference test data, rejects malformed input |
| 3 | Munge: summary statistics canonicalization | Column recognition and QC filters match reference behavior |
| 4 | LD score computation from PLINK genotypes | Computed LD scores match reference on fixture data |
| 5 | Numerics: WLS regression core via Lineax | `weighted_least_squares` recovers known coefficients within `rtol=2e-4` |
| 6 | Numerics: h2 estimation + jackknife SE | h2 and SE match reference within tolerances |
| 7 | Numerics: cross-trait genetic correlation | `estimate_rg` matches reference within tolerances |
| 8 | CLI: 5 subcommands + JSON egress | End-to-end CLI tests pass for munge, h2, rg, h2-cts, l2 |

**Simulation and Inference-Consistency Validation** — The simulation contract and experiments from kickoff.

**Acceptance Criteria:**
```
ldsc-jax-port.AC1.1: jax_ldsc h2 returns h2 within rtol=1e-5 of reference
                     on fixture data.
ldsc-jax-port.AC1.2: jax_ldsc h2 returns intercept within rtol=1e-5.
ldsc-jax-port.AC1.3: Block-jackknife SE within rtol=1e-3 of reference SE.
ldsc-jax-port.AC2.1: jax_ldsc rg returns genetic correlation within rtol=1e-5.
ldsc-jax-port.AC3.1: jax_ldsc munge produces same filtered output as reference
                     on test sumstats.
ldsc-jax-port.AC3.2: jax_ldsc l2 computes LD scores matching reference from
                     PLINK input.
ldsc-jax-port.AC4.1: Simulation recovery: estimated h2 within 2 SE of true
                     h2 across replicates.
ldsc-jax-port.AC4.2: Null calibration: mean chi2 of z-scores ~ 1 when h2=0.
ldsc-jax-port.AC5.1: All numerics functions JIT-compile via @eqx.filter_jit.
ldsc-jax-port.AC5.2: WLS solver recovers synthetic coefficients within rtol=2e-4.
ldsc-jax-port.AC6.1: CLI outputs JSON with structured result codes.
ldsc-jax-port.AC6.2: CLI exits 0 on valid input, non-zero on failure.
ldsc-jax-port.AC6.3: chi2 and z-score regression paths produce identical results.
```

**Companion artifacts** are created in `docs/design-plans/artifacts/2026-03-01-ldsc-jax-port/`:
- `model-symbol-table.md` — Symbols: chi2 (GWAS chi-squared statistics), N (sample size), l_j (LD score for SNP j), h2 (heritability), a (intercept), w_j (regression weight)
- `equation-to-code-map.md` — Maps the LDSC regression equation E[chi2_j] = N * h2 * l_j / M + a to `ldsc_jax/core/regression.py`
- `solver-feasibility-matrix.md` — WLS has closed-form normal equations. IRWLS with 2 iterations is the approach used by the reference implementation.

**Phase 6: Planning handoff.** The system finalizes the design document and commits it to git for version control. It writes the design plan to `docs/design-plans/` along with the kickoff file in `.scientific/`.

The system then provides handoff instructions with commands for your runtime (Claude Code or Codex). Copy the command before clearing context, start a fresh session, and paste the command to begin implementation planning.

---

## 6. Validation and Approval

Before the design plan can be approved for implementation, it must pass validation.

### Validation for `in-review`

```
/validate-design-plan docs/design-plans/2026-02-27-ldsc-jax-port.md --phase in-review
```

This checks:
- Definition of Done is filled (not placeholder text)
- Acceptance Criteria are present and use the `{slug}.AC{N}.{M}` format
- Model path is decided
- No placeholder content remains

### Validation for `approval`

```
/validate-design-plan docs/design-plans/2026-02-27-ldsc-jax-port.md --phase approval
```

This enforces **hard stops specific to `existing-codebase-port`**:

| Check | Requires |
|-------|----------|
| Source pin present | PORT-SRC table has at least one row with URL + commit |
| Behavior inventory populated | PORT-BHV table has entries with evidence plans |
| Codebase investigation complete | PORT-INV table populated, investigation completion = yes |
| Simulation contract (if in scope) | Simulate function signature + validation experiments defined |
| All workflow states set | `model_path_decided: yes`, `codebase_investigation_complete_if_port: yes`, `simulation_contract_complete_if_in_scope: yes` |

If any check fails, the system reports what's missing. You fix it and re-validate.

### Approving the plan

Once validation passes:

```
/set-design-plan-status docs/design-plans/2026-02-27-ldsc-jax-port.md approved-for-implementation
```

This updates the plan's status header and transition log. The plan is now ready for implementation planning.

---

## 7. The Final Output: `jax-ldsc`

The result of this workflow is [`jax-ldsc`](https://github.com/CamelliaRui/jax-ldsc) — a JAX-based port of LD Score Regression. Looking at the finished repository reveals how design decisions from kickoff and planning materialized into code.

### Repository structure

```
jax-ldsc/
├── .scientific/           # Kickoff and workflow state
├── docs/                   # Design plans and documentation
├── ldsc_jax/               # Main package
│   ├── __init__.py
│   ├── py.typed            # PEP 561 type hints marker
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

### How the design mapped to implementation

**FCIS architecture realized:**

| Layer | Module | What it does |
|-------|--------|--------------|
| Functional Core | `ldsc_jax/core/regression.py` | Pure JAX regression routines, JIT-compilable |
| Functional Core | `ldsc_jax/core/irwls.py` | Iteratively reweighted least squares (2 iterations) |
| Functional Core | `ldsc_jax/core/jackknife.py` | Block jackknife for standard error estimation |
| Functional Core | `ldsc_jax/core/ldscore.py` | LD score computation from genotypes |
| Functional Core | `ldsc_jax/core/weights.py` | Regression weighting schemes |
| Imperative Shell | `ldsc_jax/ingress/` | Polars-based data loading |
| Imperative Shell | `ldsc_jax/munge/` | Summary statistics canonicalization |
| Imperative Shell | `ldsc_jax/cli/` | CLI subcommands |
| Validation | `ldsc_jax/sim/` | Simulation APIs for parameter recovery tests |

### How human decisions shaped the code

Each major design decision traces back to a specific human answer during kickoff or design:

| Decision in `jax-ldsc` | Phase | The question and answer |
|------------------------|-------|------------------------|
| Block-jackknife SE (not AD) | Clarification | "AD-based SE as alternative?" → "No — keep jackknife only for parity." |
| FCIS with 1:1 module mapping | Brainstorming | Selected Module-Parallel approach for straightforward parity verification |
| Polars at ingress boundary | Clarification | "Pandas or Polars?" → "Polars — faster, cleaner column operations." |
| Modern CLI with subcommands | Clarification | Selected `ldsc-jax h2`, `ldsc-jax rg` over mirroring original flags |
| Include BED parsing | Clarification | Selected full port with genotype→LD score computation |
| Python 3.10+, latest JAX | Clarification | Modern typing and latest JAX features worth narrower compatibility |

### The takeaway

The finished repository demonstrates what the kickoff → design → implementation workflow produces: a structured, layer-separated port where every design decision traces back to a specific human answer. The interactive phases (clarification, brainstorming, definition of done) turn a generic "port this to JAX" request into specific, defensible choices before anyone writes code.

---

## 8. What Happens Next

After approval, the workflow continues:

1. **Implementation planning** (`/start-implementation-plan`) — Converts the design phases into granular task files with exact file paths, code examples, and test specifications.
2. **Execution** (`/execute-implementation-plan`) — Runs through tasks phase by phase with TDD, code review, and traceability checks.

These are covered in separate documentation. The key point: everything downstream depends on the decisions locked in during kickoff and refined during design.

---

## 9. Quick Reference

### Commands used in this tutorial

| Step | Claude Code command | What it does |
|------|-------------------|-------------|
| Entry point | `/using-plan-and-execute` | Router that decides which workflow to use based on your situation; also detects existing kickoff and auto-starts design |
| Start kickoff | `/start-scientific-kickoff` | Select model path, capture readiness state (when router directs you here) |
| Start design | `/start-design-plan <slug>` | Orchestrate design from kickoff through documentation (usually invoked automatically by router) |
| Validate (review) | `/validate-design-plan <path> --phase in-review` | Check plan completeness |
| Validate (approval) | `/validate-design-plan <path> --phase approval` | Enforce hard-stop readiness gates |
| Set status | `/set-design-plan-status <path> approved-for-implementation` | Approve plan for implementation |
| Implementation plan | `/start-implementation-plan <path>` | Generate task-level implementation files |
| Execute | `/execute-implementation-plan <plan-dir> <working-dir>` | Phase-by-phase execution with TDD |

### Readiness states for `existing-codebase-port`

| State | Required value | What gates it |
|-------|---------------|--------------|
| `model_path_decided` | `yes` | Design approval |
| `codebase_investigation_complete_if_port` | `yes` | Design approval (port-specific) |
| `simulation_contract_complete_if_in_scope` | `yes` or `n/a` | Design approval (if simulation in scope) |

### Files created during this workflow

| File | Created by | Purpose |
|------|-----------|---------|
| `.scientific/kickoff.md` | Kickoff | Records model path decision and readiness state |
| `docs/design-plans/YYYY-MM-DD-<slug>.md` | Design planning | Architecture and contracts |
| `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/model-symbol-table.md` | Design planning | Mathematical notation |
| `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/equation-to-code-map.md` | Design planning | Equation-to-code traceability |
| `docs/design-plans/artifacts/YYYY-MM-DD-<slug>/solver-feasibility-matrix.md` | Design planning | Solver evaluation |
