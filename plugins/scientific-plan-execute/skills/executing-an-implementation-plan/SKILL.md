---
name: executing-an-implementation-plan
description: Use when executing implementation plans with independent tasks in the current session - runs fresh delegated execution for each task (or direct execution), reviews once per phase, and loads phases just-in-time to minimize context usage
user-invocable: false
---

# Executing an Implementation Plan

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->


Execute plan phase-by-phase, loading each phase just-in-time to minimize context usage.

**Core principle:** Read one phase → execute all tasks → review → move to next phase. Never load all phases upfront.

**REQUIRED SKILL:** `requesting-code-review` - The review loop (dispatch, fix, re-review until zero issues)

**Required execution skill bundle:**
- `scientific-house-style:functional-core-imperative-shell` (all implementation tasks)
- `scientific-plan-execute:test-driven-development` (behavior-changing work)
- `scientific-plan-execute:verification-before-completion` (before completion claims)
- `scientific-house-style:jax-equinox-numerics` and `scientific-house-style:jax-project-engineering` (JAX/Equinox/numerics work)

## Overview

**When NOT to use:**
- No implementation plan exists yet (use writing-implementation-plans first)
- Plan needs revision (brainstorm first)

## MANDATORY: Human Transparency

**When you delegate work, the human cannot see delegate output directly. You are their window into the work.**

After EVERY delegate-agent run completes (task-implementor, bug-fixer, code-reviewer), you MUST:

1. **Print the delegate output in full** to the user before taking any other action
2. **Do not summarize or paraphrase** - show the exact output
3. **Include all details:** test counts, issue lists, commit hashes, error messages

**Before dispatching any delegate agent:**
- Briefly explain (2-3 sentences) what you're asking the agent to do
- State which phase this covers

**Why this matters:** When you silently process delegated output without showing the user, they lose visibility into their own codebase. They can't catch errors, learn from the process, or intervene when needed. Transparency is not optional.

**Red flag:** If you find yourself thinking "I'll just move on to the next step" without printing delegate output, STOP. Print it first.

## REQUIRED: Implementation Plan Path

**DO NOT GUESS.** If the user has not provided a path to an implementation plan directory, you MUST ask for it.

Use AskUserQuestion when available (if unavailable, ask directly with the same options):
```
Question: "Which implementation plan should I execute?"
Options:
  - [list any plan directories you find in docs/implementation-plans/]
  - "Let me provide the path"
```

If `docs/implementation-plans/` doesn't exist or is empty, ask the user to provide the path directly.

**Never assume, infer, or guess which plan to execute.** The user must explicitly tell you.

## The Process

### Deterministic Reviewer Routing

Reviewer selection must be deterministic. Use this exact process in this exact order for each phase and final review.

1. Inputs:
- `profile`: value from `## Review Profile` in `phase_XX.md` (`minimal|api-cli|numerics|inference|full`).
- `phase_text`: full phase file text.
- `changed_files`: `git diff --name-only BASE_SHA..HEAD_SHA` for the current review scope.

2. Surface flags (set true if any condition matches):
- `cli_api_surface`:
  - phase text contains one of: `cli`, `api`, `endpoint`, `route`, `command`, `schema`.
  - OR any changed path matches: `cli|command|api|http|route|openapi|schema`.
- `numerics_surface`:
  - phase text contains one of: `numerics`, `jax`, `equinox`, `solver`, `kernel`, `lineax`, `optimistix`.
  - OR any changed path matches: `numerics|solver|kernel|jax|equinox|lineax|optimistix`.
- `inference_surface`:
  - phase text contains one of: `inference`, `posterior`, `likelihood`, `objective`, `simulate`, `sbc`, `ppc`, `calibration`.
  - OR any changed path matches: `inference|posterior|likelihood|objective|simulate|sbc|ppc|calibration`.
- `architecture_surface`:
  - phase text contains one of: `boundary contract`, `architecture`, `interface`, `compact-workflow`, `modular-domain`.
  - OR any changed path matches: `docs/design-plans|docs/implementation-plans|AGENTS.md|CLAUDE.md`.

3. Baseline reviewers from `profile`:
- `minimal`: none
- `api-cli`: `scientific-cli-api-reviewer`
- `numerics`: `numerics-interface-auditor`
- `inference`: `numerics-interface-auditor`, `scientific-inference-algorithm-reviewer`
- `full`: `scientific-architecture-reviewer`, `numerics-interface-auditor`, `scientific-cli-api-reviewer`, `scientific-inference-algorithm-reviewer`

4. Escalation reviewers from surface flags:
- if `architecture_surface`: add `scientific-architecture-reviewer`
- if `numerics_surface`: add `numerics-interface-auditor`
- if `cli_api_surface`: add `scientific-cli-api-reviewer`
- if `inference_surface`: add `scientific-inference-algorithm-reviewer`

5. Final reviewer set:
- Always include `scientific-code-reviewer`.
- Add baseline + escalation reviewers.
- Deduplicate.
- Run in this fixed order:
  1. `scientific-code-reviewer`
  2. `scientific-architecture-reviewer`
  3. `numerics-interface-auditor`
  4. `scientific-cli-api-reviewer`
  5. `scientific-inference-algorithm-reviewer`

Never choose reviewers ad hoc outside this process.

### 1. Discover Phases

**DO NOT read the full phase files yet.** List them and read only the header and task markers.

```bash
# List phase files
ls [plan-directory]/phase_*.md

# For each file, get the header (first 10 lines include title and Goal)
head -10 [plan-directory]/phase_01.md

# Get task/subcomponent structure without reading full content
grep -E "START_TASK_|START_SUBCOMPONENT_" [plan-directory]/phase_01.md
```

The header includes the title (`# [Phase Title]`) and `**Goal:**` line. Extract the title for the task entry.

The grep output shows the task structure, e.g.:
```
<!-- START_TASK_1 -->
<!-- START_TASK_2 -->
<!-- START_SUBCOMPONENT_A (tasks 3-5) -->
<!-- START_TASK_3 -->
<!-- START_TASK_4 -->
<!-- START_TASK_5 -->
```

Examples of headers you might see:
- `# Document Infrastructure Implementation Plan` — Phase 1 implied
- `# Phase 4: Link Resolution` — Phase number explicit

**Check for implementation guidance:**

After discovering phases, check if `.scientific/implementation-plan-guidance.md` exists in the project root:

```bash
# Check for implementation guidance (note the absolute path for later use)
ls [project-root]/.scientific/implementation-plan-guidance.md
```

If the file exists, note its **absolute path** for use during code reviews. If it doesn't exist, proceed without it—do not pass a nonexistent path to reviewers.

**Check for test requirements:**

Check if `test-requirements.md` exists in the plan directory:

```bash
# Check for test requirements (note the absolute path for later use)
ls [plan-directory]/test-requirements.md
```

If the file exists, note its **absolute path** for use during final review. The test requirements document specifies what automated tests must exist for each acceptance criterion.

### 2. Create Phase-Level Task List

Use `update_plan` (or `TaskCreate` where available) to create **three task entries per phase** (or `TodoWrite` in runtimes that still expose it). Include the title from the header:

```
- [ ] Phase 1a: Read /absolute/path/to/phase_01.md — Document Infrastructure Implementation Plan
- [ ] Phase 1b: Execute tasks
- [ ] Phase 1c: Code review
- [ ] Phase 2a: Read /absolute/path/to/phase_02.md — API Integration
- [ ] Phase 2b: Execute tasks
- [ ] Phase 2c: Code review
...
```

**Why absolute paths in task entries:** After compaction, context may be summarized. The absolute path in the task entry ensures you always know exactly which file to read.

**Why include the title:** Gives visibility into what each phase covers without loading full content.

### 2b. Skill Activation Gate (Before Task Dispatch)

Before dispatching task implementors for a phase, define the phase skill set from phase content:

1. Always include:
- `scientific-house-style:functional-core-imperative-shell`
2. Include when behavior changes are implemented:
- `scientific-plan-execute:test-driven-development`
- `scientific-plan-execute:verification-before-completion`
3. Include when JAX/Equinox/numerics surfaces are in scope:
- `scientific-house-style:jax-equinox-numerics`
- `scientific-house-style:jax-project-engineering`

If any required skill for the phase cannot be loaded, STOP and report blocked with the missing skill IDs and installation guidance.

Pass this skill list explicitly in every `task-implementor-fast` and `task-bug-fixer` dispatch prompt, and require each delegate to report `Skills Applied`.

### 3. Execute Each Phase

For each phase, follow this cycle:

#### 3a. Read Phase File (just-in-time)

Mark "Phase Na: Read [path]" as in_progress.

Read ONLY that phase file now. Extract:
- List of tasks in this phase
- Working directory
- Any phase-specific context

Mark "Phase Na: Read" as complete.

#### 3b. Execute All Tasks

Mark "Phase Nb: Execute tasks" as in_progress.

**Before dispatching, verify test coverage for functionality tasks:**

If a functionality task (code that does something) has no tests specified:
1. Check if a subsequent task in the same phase provides tests
2. If no tests exist anywhere for this functionality → **STOP**
3. This is a plan gap. Surface to user: "Task N implements [functionality] but no corresponding tests exist in the plan. This needs tests before implementation."

Do NOT implement functionality without tests. Missing tests = plan gap, not something to skip.

**Execute all tasks in sequence.** For each task, dispatch `task-implementor-fast` with the phase file path:

```
<invoke name="Task">
<parameter name="subagent_type">scientific-plan-execute:scientific-task-implementor-fast</parameter>
<parameter name="description">Implementing Phase X, Task Y: [description]</parameter>
<parameter name="prompt">
  Implement Task N from the phase file.

  Phase file: [absolute path to phase file]
  Task number: N

  Read the phase file and implement Task N (look for `<!-- START_TASK_N -->`).

  Your job is to:
  1. Read the phase file to understand context
  2. Load and apply required skills before editing:
     - scientific-house-style:functional-core-imperative-shell
     - scientific-plan-execute:test-driven-development (if behavior-changing)
     - scientific-plan-execute:verification-before-completion
     - scientific-house-style:jax-equinox-numerics and scientific-house-style:jax-project-engineering (if JAX/Equinox/numerics scope)
     If any required skill is unavailable, stop and report blocked with missing skill IDs.
  3. Implement exactly what Task N specifies
  4. Verify with tests/build/lint
  5. Commit your work
  6. Report back with evidence, including "Skills Applied"

  Work from: [directory]

  Provide complete report per your agent instructions.
</parameter>
</invoke>
```

**For subcomponents** (grouped tasks), dispatch once for all tasks in the subcomponent:

```
<invoke name="Task">
<parameter name="subagent_type">scientific-plan-execute:scientific-task-implementor-fast</parameter>
<parameter name="description">Implementing Phase X, Subcomponent A (Tasks 3-5): [description]</parameter>
<parameter name="prompt">
  Implement Subcomponent A (Tasks 3, 4, 5) from the phase file.

  Phase file: [absolute path to phase file]
  Tasks: 3, 4, 5 (look for `<!-- START_SUBCOMPONENT_A -->`)

  Read the phase file and implement all tasks in this subcomponent.

  Your job is to:
  1. Read the phase file to understand context
  2. Load and apply required skills before editing:
     - scientific-house-style:functional-core-imperative-shell
     - scientific-plan-execute:test-driven-development (if behavior-changing)
     - scientific-plan-execute:verification-before-completion
     - scientific-house-style:jax-equinox-numerics and scientific-house-style:jax-project-engineering (if JAX/Equinox/numerics scope)
     If any required skill is unavailable, stop and report blocked with missing skill IDs.
  3. Implement all tasks in sequence
  4. Verify with tests/build/lint after completing all tasks
  5. Commit your work (one commit per task, or logical commits)
  6. Report back with evidence for each task, including "Skills Applied"

  Work from: [directory]

  Provide complete report covering all tasks.
</parameter>
</invoke>
```

**Print each task-implementor's response** before moving to the next task.

**No code review between tasks.** Execute all tasks in the phase first.

After all tasks complete, mark "Phase Nb: Execute tasks" as complete.

#### 3c. Code Review for Phase

Mark "Phase Nc: Code review" as in_progress.

**MANDATORY:** Use the `requesting-code-review` skill for the review loop.

**Context to provide:**
- WHAT_WAS_IMPLEMENTED: Summary of all tasks in this phase
- PLAN_OR_REQUIREMENTS: All tasks from this phase
- BASE_SHA: commit before phase started
- HEAD_SHA: current commit
- IMPLEMENTATION_GUIDANCE: absolute path to `.scientific/implementation-plan-guidance.md` (**only if it exists**—omit entirely if the file doesn't exist)

The implementation guidance file contains project-specific coding standards, testing requirements, and review criteria. When provided, the code reviewer should read it and apply those standards during review.

**Note:** Test requirements validation happens at final review, not per-phase. Per-phase reviews focus on code quality and whether the phase includes tests for its functionality.

**If code reviewer returns a context limit error:**

The phase changed too much for a single review. Chunk the review:

1. Identify the midpoint of tasks in the phase
2. Run code review for first half of tasks (commits for tasks 1 through N/2)
3. Fix any issues found
4. Run code review for second half of tasks (commits for tasks N/2+1 through N)
5. Fix any issues found

**When issues are found:**

1. **Create a task for EACH issue** (survives compaction):
   ```
   TaskCreate: "Phase N fix [Critical]: <VERBATIM issue description from reviewer>"
   TaskCreate: "Phase N fix [Important]: <VERBATIM issue description from reviewer>"
   TaskCreate: "Phase N fix [Minor]: <VERBATIM issue description from reviewer>"
   ...one task per issue...
   TaskCreate: "Phase N: Re-review after fixes"
   TaskUpdate: set "Re-review" blocked by all fix tasks
   ```

   **Copy issue descriptions VERBATIM**, even if long. After compaction, the task description is all that remains — it must contain the full issue details for the bug-fixer to understand what to fix.

2. **Dispatch `task-bug-fixer`** with the phase file:

```
<invoke name="Task">
<parameter name="subagent_type">scientific-plan-execute:scientific-task-bug-fixer</parameter>
<parameter name="description">Fixing review issues for Phase X</parameter>
<parameter name="prompt">
  Fix issues from code review for Phase X.

  Phase file: [absolute path to phase file]

  Code reviewer found these issues:
  [list all issues - Critical, Important, and Minor]

  Read the phase file to understand the tasks and context.

  Your job is to:
  1. Understand root cause of each issue
  2. Load and apply required skills before editing:
     - scientific-house-style:functional-core-imperative-shell
     - scientific-plan-execute:test-driven-development (for behavior-changing fixes and regression tests)
     - scientific-plan-execute:verification-before-completion
     - scientific-house-style:jax-equinox-numerics and scientific-house-style:jax-project-engineering (if JAX/Equinox/numerics scope)
     - scientific-plan-execute:systematic-debugging (if root cause is unclear or failures persist)
     If any required skill is unavailable, stop and report blocked with missing skill IDs.
  3. Apply fixes systematically (Critical → Important → Minor)
  4. Verify with tests/build/lint
  5. Commit your fixes
  6. Report back with evidence, including "Skills Applied"

  Work from: [directory]

  Fix ALL issues — including every Minor issue. The goal is ZERO issues on re-review.
  Minor issues are not optional. Do not skip them.
</parameter>
</invoke>
```

3. **Mark "Fix issues" complete**, then re-review per the `requesting-code-review` skill.

4. **If re-review finds more issues**, create new fix/re-review tasks. Continue loop until zero issues.

5. **Mark "Re-review" complete** when zero issues.

**Plan execution policy (stricter than general code review):**
- ALL issues must be fixed (Critical, Important, AND Minor)
- Ignore APPROVED/BLOCKED status - count issues only
- **Three-strike rule:** If same issues persist after three review cycles, stop and ask human for help

**Minor issues are NOT optional.** Do not rationalize skipping them with "they're just style issues" or "we can fix those later." The reviewer flagged them for a reason. Fix every single one.

**Exit condition:** Zero issues in all categories — including Minor.

Mark "Phase Nc: Code review" as complete.

#### 3c.1 Deterministic Specialized Review Pass

After baseline `requesting-code-review` reaches zero issues, compute reviewers using `Deterministic Reviewer Routing` above and run every reviewer in the computed fixed-order list (excluding `scientific-code-reviewer`, already covered by baseline).

If any specialized reviewer returns findings:
1. Route fixes through `scientific-task-bug-fixer`.
2. Re-run only reviewers that previously returned findings.
3. Repeat until each reviewer in this subset returns zero issues.

#### 3d. Move to Next Phase

Proceed to the next phase's "Read" step. Repeat 3a-3c for each phase.

### 4. Update Project Context

After all phases complete, use the `maintaining-project-context` skill when available to review changes and update AGENTS.md/CLAUDE.md context files if needed. If that skill is unavailable, perform equivalent checks directly.

Minimum required checks:
1. Diff from the first-phase base commit to current HEAD.
2. Identify contract/API/structure changes that impact contributor guidance.
3. Update affected AGENTS.md/CLAUDE.md files.
4. Commit documentation updates (or state explicitly that no updates were needed).

### 5. Final Review Sequence

After all phases complete, run a sequence of specialized agents:

```
Code Review → Test Analysis (Coverage + Plan)
```

#### 5a. Final Code Review

Use the `requesting-code-review` skill for final code review:

**Context to provide:**
- WHAT_WAS_IMPLEMENTED: Summary of all phases completed
- PLAN_OR_REQUIREMENTS: Reference to the full implementation plan directory
- BASE_SHA: commit before first phase started
- HEAD_SHA: current commit
- IMPLEMENTATION_GUIDANCE: absolute path (if exists)
- AC_COVERAGE_CHECK: "Verify all acceptance criteria (using scoped format `{slug}.AC*`) from the design plan are covered by at least one phase. Flag any ACs not addressed."

Continue the review loop until zero issues remain.

Then run deterministic final specialized reviewers on the full diff/range:
1. Build union surface flags across all phases (`cli_api_surface`, `numerics_surface`, `inference_surface`, `architecture_surface`).
2. Use `profile=full` for final review baseline.
3. Compute final reviewer set from `Deterministic Reviewer Routing`.
4. Run reviewers in fixed order and loop fixes per reviewer until all return zero issues.

#### 5b. Test Analysis

**Only after final code review passes with zero issues.**

**Skip this step if test-requirements.md does not exist.**

The test-analyst agent performs two sequential tasks with shared analysis:
1. Validate coverage against acceptance criteria
2. Generate human test plan (only if coverage passes)

Dispatch the test-analyst agent:

```
<invoke name="Task">
<parameter name="subagent_type">scientific-plan-execute:scientific-test-analyst</parameter>
<parameter name="description">Analyzing test coverage and generating test plan</parameter>
<parameter name="prompt">
Analyze test implementation against acceptance criteria.

TEST_REQUIREMENTS_PATH: [absolute path to test-requirements.md]
WORKING_DIRECTORY: [project root]
BASE_SHA: [commit before first phase]
HEAD_SHA: [current commit]

Phase 1: Validate that automated tests exist for all acceptance criteria.
Phase 2: If coverage passes, generate human test plan using your analysis.

Return coverage validation result. If PASS, include the human test plan.
</parameter>
</invoke>
```

**If analyst returns coverage FAIL:**

1. Dispatch bug-fixer to add missing tests:
   ```
   <invoke name="Task">
   <parameter name="subagent_type">scientific-plan-execute:scientific-task-bug-fixer</parameter>
   <parameter name="description">Adding missing test coverage</parameter>
   <parameter name="prompt">
   Add missing tests identified by the test analyst.

   Missing coverage:
   [list from analyst output]

   For each missing test:
   1. Read the acceptance criterion carefully
   2. Load and apply required skills before editing:
      - scientific-house-style:functional-core-imperative-shell
      - scientific-plan-execute:test-driven-development
      - scientific-plan-execute:verification-before-completion
      - scientific-house-style:jax-equinox-numerics and scientific-house-style:jax-project-engineering (if JAX/Equinox/numerics scope)
      If any required skill is unavailable, stop and report blocked with missing skill IDs.
   3. Create the test file at the expected location
   4. Write tests that verify the criterion's actual behavior—not just code that passes, but code that would fail if the criterion weren't met
   5. Run tests to confirm they pass
   6. Commit the new tests
   7. Report back with evidence, including "Skills Applied"

   Work from: [directory]
   </parameter>
   </invoke>
   ```

2. Re-run test-analyst
3. Repeat until coverage PASS or three attempts fail (then escalate to human)

**If analyst returns coverage PASS:**

The response will include the human test plan. Extract the "Human Test Plan" section.

**Write the test plan:**

```bash
# Create test-plans directory if needed
mkdir -p docs/test-plans

# The filename uses the implementation plan directory name
# e.g., impl plan dir: docs/implementation-plans/2025-01-24-oauth/
#       test plan:     docs/test-plans/2025-01-24-oauth.md
```

Write the test plan content to `docs/test-plans/[impl-plan-dir-name].md`, then commit:

```bash
git add docs/test-plans/[impl-plan-dir-name].md
git commit -m "docs: add test plan for [feature name]"
```

Announce: "Human test plan written to `docs/test-plans/[impl-plan-dir-name].md`"

### 6. Complete Development

After final review passes:

- Provide a report to the human operator
  - For each phase:
    - How many tasks were implemented
    - How many review cycles were needed
    - Any compromises made (there should be NO compromises, but if any were made). Examples:
      - "I couldn't run the integration tests, so I continued on"
      - "I couldn't generate the client because the dev environment was down"
      - Note that these are PARTIAL FAILURE CASES and explain to the user what the user must do now.
    - Were any code-review issues left outstanding at any point?

- Activate the `finishing-a-development-branch` skill. DO NOT activate it before this point.

## Example Workflow

```
You: I'm using the `executing-an-implementation-plan` skill.

[Discover phases: phase_01.md, phase_02.md, phase_03.md]
[Read first 3 lines of each to get titles]

[Create tasks with TaskCreate:]
- [ ] Phase 1a: Read /path/to/phase_01.md — Project Setup
- [ ] Phase 1b: Execute tasks
- [ ] Phase 1c: Code review
- [ ] Phase 2a: Read /path/to/phase_02.md — Token Service
- [ ] Phase 2b: Execute tasks
- [ ] Phase 2c: Code review
- [ ] Phase 3a: Read /path/to/phase_03.md — API Middleware
- [ ] Phase 3b: Execute tasks
- [ ] Phase 3c: Code review

--- Phase 1 ---

[Mark 1a in_progress, read phase_01.md]
→ Contains 2 tasks: project setup, config files

[Mark 1a complete, 1b in_progress]

[Dispatch task-implementor-fast for Task 1]
→ Created package.json, tsconfig.json.

[Dispatch task-implementor-fast for Task 2]
→ Created config files. Build succeeds.

[Mark 1b complete, 1c in_progress]

[Use requesting-code-review skill for phase 1]
→ Zero issues.

[Mark 1c complete]

--- Phase 2 ---

[Mark 2a in_progress, read phase_02.md]
→ Contains 3 tasks: types, service, tests

[Mark 2a complete, 2b in_progress]

[Execute all 3 tasks...]

[Mark 2b complete, 2c in_progress]

[Use requesting-code-review skill for phase 2]
→ Important: 1, Minor: 1
→ Dispatch bug-fixer, re-review
→ Zero issues.

[Mark 2c complete]

--- Phase 3 ---

[Similar pattern...]

--- Finalize ---

[Invoke project-claude-librarian delegate agent]
→ Updated CLAUDE.md.

[Use requesting-code-review skill for final review]
→ All requirements met.

[Transitioning to finishing-a-development-branch]
```

## Common Rationalizations - STOP

| Excuse | Reality |
|--------|---------|
| "I'll read all phases upfront to understand the full picture" | No. Read one phase at a time. Context limits are real. |
| "I'll skip the read step, I remember what's in the file" | No. Always read just-in-time. Context may have been compacted. |
| "I'll review after each task to catch issues early" | No. Review once per phase. Task-level review wastes context. |
| "Context error on review, I'll skip the review" | No. Chunk the review into halves. Never skip review. |
| "Minor issues can wait" | No. Fix ALL issues including Minor. |
| "I'll skip loading skills and just implement quickly" | No. Enforce the phase skill-activation gate and require `Skills Applied` evidence from task-implementor and task-bug-fixer. |
