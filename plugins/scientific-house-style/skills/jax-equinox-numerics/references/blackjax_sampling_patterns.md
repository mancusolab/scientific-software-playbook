# BlackJAX Sampling Patterns

Detailed rules for sampling-based inference workflows where the primary contract is posterior draws plus diagnostics, not a single point estimate.

## Scope

Use this reference when the implementation involves MCMC or related sampling-based inference.
Do not use it to describe variational inference or other objective-minimizing approximations;
those remain under deterministic optimization guidance.

## Sampling-engine contract

### Rule: Make the inference-engine choice explicit
- Do: state the sampling family (`nuts`, `hmc`, etc.), kernel implementation, and any adaptation strategy in the design/API contract.
- Don’t: refer to the engine only as a generic "solver".
- Why: inference review and reproducibility depend on knowing the actual sampling algorithm.

### Rule: Make warmup/adaptation separate from posterior sampling
- Do: represent warmup/adaptation outputs separately from final posterior draws.
- Do: document which adapted quantities are carried into the sampling phase.
- Don’t: blur warmup state and production-sampling state into one unnamed container.
- Why: adaptation behavior affects both correctness and reproducibility.

### Rule: Make chain axes and sample axes explicit
- Do: define whether chains are sequential, vmapped, or otherwise batched.
- Do: document output shape conventions for chains, draws, and parameter/event dimensions.
- Don’t: return arrays whose chain/draw layout must be guessed by callers.
- Why: ambiguous sample layout causes downstream diagnostic and posterior-predictive errors.

### Rule: Thread PRNG keys explicitly across chains and phases
- Do: split keys explicitly across chain initialization, warmup/adaptation, and posterior draws.
- Do: make replay expectations clear for fixed seeds and fixed chain counts.
- Don’t: hide chain-local randomness in global state or implicit callbacks.
- Why: reproducible sampling requires phase-aware and chain-aware key management.

## Diagnostics and failure semantics

### Rule: Expose sampler diagnostics as part of the public contract
- Do: return or log diagnostics such as divergences, acceptance statistics, and effective-sample-size/R-hat summaries when available at the relevant layer.
- Don’t: treat diagnostics as optional debug-only metadata.
- Why: sampler correctness is judged partly through diagnostics, not just sample presence.

### Rule: Distinguish hard failures from degraded-but-usable runs
- Do: document which conditions are hard failures (for example invalid log density or adaptation breakdown) versus warnings requiring user judgment.
- Don’t: collapse all non-ideal outcomes into a single generic success flag.
- Why: inference consumers need actionable interpretation of sampler quality.

### Rule: Keep posterior sample outputs self-describing
- Do: name sample groups, parameter blocks, and any transformed quantities clearly.
- Do: include enough metadata for posterior predictive checks and simulation-based calibration.
- Don’t: hand back bare sample tensors without labeling or provenance.
- Why: unlabeled samples are difficult to validate and easy to misuse.

## Engineering guidance

### Rule: Keep log-density and model code separate from sampler orchestration
- Do: isolate the target log-density / model evaluation from warmup loops, chain orchestration, and output formatting.
- Don’t: entangle sampler control flow with domain-model definitions.
- Why: separation makes testing and algorithm review easier.

### Rule: Test more than "it runs"
- Do: add tests for deterministic seeded replay, shape/layout contracts, and failure/diagnostic surfacing.
- Do: connect implementation tests to higher-level validation such as recovery, SBC, or posterior predictive checks when those are in scope.
- Don’t: treat a completed sampling loop as sufficient evidence of correctness.
- Why: sampling regressions often show up in diagnostics and contracts before obvious runtime failure.
