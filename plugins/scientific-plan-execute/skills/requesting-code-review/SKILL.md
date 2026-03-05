---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements - runs the canonical reviewer workflow, handles retries and timeouts, and manages the review-fix loop until zero issues
user-invocable: false
---

# Requesting Code Review

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->

## Delegate Contract

Preferred delegate mechanism:
- use installed agent definitions from the `scientific-plan-execute` plugin bundle
- dispatch them through the runtime's generic agent-spawning mechanism when plugin-specific delegate IDs are unavailable

Canonical agent definitions for this skill:
- `scientific-code-reviewer` -> `agents/scientific-code-reviewer.md`
- `scientific-task-bug-fixer` -> `agents/scientific-task-bug-fixer.md`

Resolve agent-definition paths through the shared plugin resolver. Do not encode repository-relative `plugins/.../agents/...` paths in workflow logic.

If the runtime supports direct agent IDs and these names resolve, you may use them. Otherwise, resolve the installed agent-definition file and delegate through a generic agent using that definition as the governing instructions.

If a required agent definition cannot be resolved from the installed plugin bundle, STOP and report `blocked` instead of silently reviewing or fixing inline.

### Agent Path Resolution

Use the shared resolver from the installed plugin bundle:

```bash
RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"
CODE_REVIEWER_AGENT_PATH="$(bash "$RESOLVER_PATH" scientific-plan-execute agents/scientific-code-reviewer.md)"
BUG_FIXER_AGENT_PATH="$(bash "$RESOLVER_PATH" scientific-plan-execute agents/scientific-task-bug-fixer.md)"
```

Fail if any required path does not exist.


Run the canonical `scientific-code-reviewer` workflow to catch issues before they cascade.

**Core principle:** Review early, review often. Fix ALL issues before proceeding.

## Reviewer Scope

This skill is baseline-only:
1. It always invokes `scientific-code-reviewer`.
2. It does not select specialized reviewers.
3. Specialized reviewer routing is owned by `executing-an-implementation-plan` via its deterministic routing table.

## When to Request Review

**Mandatory:**
- After each phase in `executing-an-implementation-plan`
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## The Review Loop

The review process is a loop: review → fix → re-review → until zero issues.

```
┌──────────────────────────────────────────────────┐
│                                                  │
│   Dispatch code-reviewer                         │
│         │                                        │
│         ▼                                        │
│   Issues found? ──No──► Done (proceed)           │
│         │                                        │
│        Yes                                       │
│         │                                        │
│         ▼                                        │
│   Dispatch bug-fixer                             │
│         │                                        │
│         ▼                                        │
│   Re-review with prior issues ◄──────────────────┘
│
└──────────────────────────────────────────────────┘
```

**Exit condition:** Zero issues, or issues accepted per your workflow's policy.

## Step 1: Initial Review

**Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or commit before task
HEAD_SHA=$(git rev-parse HEAD)
```

**Run `scientific-code-reviewer`:**

```
<dispatch generic agent>
agent_definition_path: [CODE_REVIEWER_AGENT_PATH]
description: Reviewing [what was implemented]
prompt: |
  Use template at requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [summary of implementation]
  PLAN_OR_REQUIREMENTS: [task/requirements reference]
  BASE_SHA: [commit before work]
  HEAD_SHA: [current commit]
  DESCRIPTION: [brief summary]
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment

## Step 2: Handle Reviewer Response

### If Zero Issues
All categories empty → return control to the calling workflow.

### If Any Issues Found
Regardless of category (Critical, Important, or Minor), dispatch `scientific-task-bug-fixer`:

```
<dispatch generic agent>
agent_definition_path: [BUG_FIXER_AGENT_PATH]
description: Fixing review issues
prompt: |
  Fix issues from code review.

  Code reviewer found these issues:
  [list all issues - Critical, Important, and Minor]

  Your job is to:
  1. Understand root cause of each issue
  2. Apply fixes systematically (Critical → Important → Minor)
  3. Verify with tests/build/lint
  4. Commit your fixes
  5. Report back with evidence

  Work from: [directory]

  Fix ALL issues — including every Minor issue. The goal is ZERO issues on re-review.
  Minor issues are not optional. Do not skip them.
```

After fixes, proceed to Step 3.

## Step 3: Re-Review After Fixes

**CRITICAL:** Track prior issues across review cycles.

```
<dispatch generic agent>
agent_definition_path: [CODE_REVIEWER_AGENT_PATH]
description: Re-reviewing after fixes (cycle N)
prompt: |
  Use template at requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from bug-fixer's report]
  PLAN_OR_REQUIREMENTS: [original task/requirements]
  BASE_SHA: [commit before this fix cycle]
  HEAD_SHA: [current commit after fixes]
  DESCRIPTION: Re-review after bug fixes (review cycle N)

  PRIOR_ISSUES_TO_VERIFY_FIXED:
  [list all outstanding issues from previous reviews]

  Verify:
  1. Each prior issue listed above is actually resolved
  2. No regressions introduced by the fixes
  3. Any new issues in the changed code

  Report which prior issues are now fixed and which (if any) remain.
```

**Tracking prior issues:**
- When re-reviewer explicitly confirms fixed → remove from list
- When re-reviewer doesn't mention an issue → keep on list (silence ≠ fixed)
- When re-reviewer finds new issues → add to list

Loop back to Step 2 if any issues remain.

## Handling Failures

### Operational Errors
If reviewer reports operational errors (can't run tests, missing scripts):
1. **STOP** - do not continue
2. Report to human
3. When told to continue, re-execute same review

### Timeouts / Empty Response
Usually means context limits. Retry with focused scope:

**First retry:** Narrow to changed files only:
```
FOCUSED REVIEW - Context was too large.

Review ONLY the diff between BASE_SHA and HEAD_SHA.
Focus on: [list only files actually modified]

Skip: broad architectural analysis, unchanged files, tangential concerns.

WHAT_WAS_IMPLEMENTED: [summary]
PLAN_OR_REQUIREMENTS: [reference]
BASE_SHA: [sha]
HEAD_SHA: [sha]
```

**Second retry:** Split into multiple smaller reviews (one per file or logical group).

**Third failure:** Stop and ask human for help.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Zero issues | Proceed |
| Any issues | Fix, re-review (or accept per workflow) |
| Operational error | Stop, report, wait |
| Timeout | Retry with focused scope |
| 3 failed retries | Ask human |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Proceed with ANY unfixed issues (Critical, Important, OR Minor)
- Argue with valid technical feedback without evidence
- Rationalize skipping Minor issues ("they're just style", "we can fix later")

**Minor issues are NOT optional.** The code reviewer flagged them for a reason. Fix all of them. "Minor" means lower severity, not "ignorable."

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification on unclear feedback

## Integration

**Called by:**
- executing-an-implementation-plan (after each phase)
- finishing-a-development-branch (final review)
- Ad-hoc when you need a review

**Template location:** requesting-code-review/code-reviewer.md
