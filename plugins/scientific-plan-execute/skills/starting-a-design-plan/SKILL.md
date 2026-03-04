---
name: starting-a-design-plan
description: Use when beginning any design process - orchestrates gathering context, clarifying requirements, brainstorming solutions, and documenting validated designs to create implementation-ready design documents
user-invocable: false
---

# Starting a Design Plan

<!-- SYNC:BEGIN runtime-compatibility -->
## Runtime Compatibility

When executing this definition in Codex or another runtime, apply this mapping:

- `TaskCreate`, `TaskUpdate`, `TodoWrite` -> `update_plan`
- `Task` delegate calls (for example `<invoke name="Task">`) -> perform the requested work directly in the current session when delegation is unavailable
- `Skill` tool calls -> load the named skill with your runtime skill-loading mechanism
- Tool names like `Read`, `Write`, `Edit`, `Bash`, `Grep`, and `Glob` -> use equivalent native tools in your runtime

Apply this translation before following the remaining steps.
<!-- SYNC:END runtime-compatibility -->


## Overview

Orchestrate the complete design workflow from initial idea to implementation-ready documentation through six core phases: context gathering, clarification, definition of done, brainstorming, design documentation, and planning handoff.

This skill is kickoff-agnostic. If kickoff artifacts already exist, ingest and carry them forward. If not, continue with general design orchestration.

**Core principle:** Progressive information gathering -> clear understanding -> creative exploration -> validated design -> documented plan.

**Announce at start:** "I'm using the starting-a-design-plan skill to guide us through the design process."

## Path Contract (Unambiguous)

1. When creating the initial design document, use the shared `new-design-plan.sh` scaffolder rather than hand-writing an ad hoc file.
2. Resolve the scaffolder through the shared resolver only:
- Codex install: `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh`
- Claude Code plugin install: `${CLAUDE_PLUGIN_ROOT}/scripts/resolve-plugin-path.sh`
3. Do not use repository-local `scripts/...` paths directly.
4. Project-local outputs still belong under the active downstream project root (`docs/design-plans/...`).

## Quick Reference

| Phase | Key Activities | Output |
|-------|---------------|--------|
| **1. Context Gathering** | Ask for freeform description, constraints, goals, URLs, files | Initial context bundle |
| **(conditional) Kickoff Handoff Ingestion** | Read `.scientific/kickoff.md` when present | Kickoff definitions folded into design context |
| **2. Clarification** | Invoke asking-clarifying-questions skill | Disambiguated requirements |
| **3. Definition of Done** | Synthesize and confirm deliverables before brainstorming | Confirmed success criteria |
| **4. Brainstorming** | Invoke brainstorming skill | Validated design (in conversation) |
| **5. Design Documentation** | Invoke writing-design-plans skill | Committed design document |
| **6. Planning Handoff** | Offer to invoke writing-plans skill | Implementation plan (optional) |

## The Process

**REQUIRED: Create task tracker at start**

Use `update_plan` (or `TaskCreate` where available) to create todos for each phase (or `TodoWrite` in runtimes that still expose it):

- Phase 1: Context Gathering (initial information collected)
- (conditional) Read project design guidance (if `.scientific/design-plan-guidance.md` exists)
- (conditional) Read kickoff handoff (if `.scientific/kickoff.md` exists)
- Phase 2: Clarification (requirements disambiguated)
- Phase 3: Definition of Done (deliverables confirmed)
- Phase 4: Brainstorming (design validated)
- Phase 5: Design Documentation (design written to docs/design-plans/)
- Phase 6: Planning Handoff (implementation plan offered/created)

Use `update_plan` updates (or `TaskUpdate` where available) to mark each phase as in_progress when working on it, completed when finished (or `TodoWrite` in runtimes that still expose it).

### Phase 1: Context Gathering

**Never skip this phase.** Even if the user provides detailed information, ask for anything missing.

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 1 as in_progress.

**Ask the user to provide (freeform, not AskUserQuestion):**

"I need some information to start the design process. Please provide what you have:

**What are you designing?**
- High-level description of what you want to build
- Goals or success criteria
- Any known constraints or requirements

**Context materials (very helpful if available):**
- URLs to relevant documentation, APIs, or examples
- File paths to existing code or specifications in this repository
- Any research you've already done

**Project state:**
- Are you starting fresh or extending existing functionality?
- Are there existing patterns in the codebase I should follow?
- Any architectural decisions already made?

Share whatever details you have. We'll clarify anything unclear in the next step."

**Progressive prompting:** If user already provided some of this information, acknowledge what you have and ask only for what's missing.

**Example:**
"You mentioned OAuth2 integration. I have the high-level goal. To help design this effectively, I need:
- Any constraints (regulatory, existing auth system, etc.)
- URLs to the OAuth2 provider's documentation (if you have them)
- Whether this is for human users, service accounts, or both"

Mark Phase 1 as completed when you have initial context.

### Between Phase 1 and Phase 2: Check for Project Guidance

Before clarification, check for project-specific design guidance.

**Check if `.scientific/design-plan-guidance.md` exists:**

Use the Read tool to check if `.scientific/design-plan-guidance.md` exists in the session's working directory.

**If the file exists:**

1. Use `update_plan` (or `TaskCreate` where available) to add: "Read project design guidance from [absolute path to .scientific/design-plan-guidance.md]"
   - Set this task as blocked by Phase 1 (Context Gathering)
   - Update the next phase task (Kickoff Handoff Ingestion when `.scientific/kickoff.md` exists, otherwise Phase 2) to be blocked by this new task
2. Mark the task in_progress
3. Read the file and incorporate the guidance into your understanding
4. Mark the task completed
5. Proceed to Kickoff Handoff Ingestion (if `.scientific/kickoff.md` exists), then Phase 2.

**If the file does not exist:**

Proceed to Kickoff Handoff Ingestion check. Do not create a task or mention the missing guidance file.

**What project guidance provides:**
- Domain-specific terminology to use in clarification
- Architectural constraints or preferences
- Technologies that are required, preferred, or forbidden
- Stakeholders and their priorities
- Project conventions that designs must follow

The guidance informs what questions you ask during clarification.

### Between Phase 1 and Phase 2: Kickoff Handoff Ingestion (Conditional)

If kickoff was run earlier, ingest its output before clarification.

**Check if `.scientific/kickoff.md` exists:**

Use the Read tool to check if `.scientific/kickoff.md` exists in the session's working directory.

**If the file exists:**

1. Use `update_plan` (or `TaskCreate` where available) to add: "Read kickoff handoff from [absolute path to .scientific/kickoff.md]"
2. Mark the task in_progress
3. Read the file and extract:
- `mode`
- `model_path_decided`
- `codebase_investigation_complete_if_port`
- `simulation_contract_complete_if_in_scope`
- mode-specific evidence entries
4. Carry these fields forward as design constraints and readiness context.
5. Mark the task completed.

**If the file does not exist:**

Continue directly to Phase 2 with no kickoff assumptions.

**Important:** This skill does not run kickoff directly. `scientific-kickoff` is a separate entry skill for fresh-project/model-path tracks. When kickoff outputs exist, this skill must ingest them.

### Phase 2: Clarification

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 2 as in_progress.

**REQUIRED SUB-SKILL:** Use scientific-plan-execute:asking-clarifying-questions

Announce: "I'm using the asking-clarifying-questions skill to make sure I understand your requirements correctly."

The clarification skill will:
- Use delegate agents to disambiguate before raising questions to the user (or do this work directly when delegation is unavailable)
- Disambiguate technical terms ("OAuth2" -> which flow?)
- Identify scope boundaries ("users" -> humans? services? both?)
- Clarify assumptions ("integrate with X" -> which version?)
- Understand constraints ("must use Y" -> why?)

**Output:** Clear understanding of what user means, ready to confirm Definition of Done.

Mark Phase 2 as completed when requirements are disambiguated.

### Phase 3: Definition of Done

Before brainstorming the *how*, lock in the *what*. Brainstorming explores texture and approach — it assumes the goal is already clear.

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 3 as in_progress.

**Synthesize the Definition of Done from context gathered so far:**

From Phases 1-2 (Context Gathering and Clarification), you should be able to infer or extract:
- What the deliverables are (what gets built/changed)
- What success looks like (how we know it's done)
- What's explicitly out of scope

**If the Definition of Done is clear:**

State it back to the user and confirm using AskUserQuestion (or ask directly with the same options if AskUserQuestion is unavailable):

```
Question: "Before we explore approaches, let me confirm what success looks like:"
Options:
  - "Yes, that's right" (Definition of Done is accurate)
  - "Needs adjustment" (User will clarify what's missing or wrong)
```

Present the Definition of Done as a brief statement (2-4 sentences) covering:
- Primary deliverable(s)
- Success criteria
- Key exclusions (if any were discussed)

**If the Definition of Done is unclear:**

Ask targeted questions to nail it down. Use AskUserQuestion when available for discrete options (or ask directly with numbered options), and use open-ended questions when you need the user to describe their vision.

Examples of clarifying questions:
- "What's the primary deliverable here — is it [X] or [Y]?"
- "How will you know this is done? What would you test or demonstrate?"
- "You mentioned [feature]. Is that in scope for this design, or a future addition?"

**Do not proceed to brainstorming until Definition of Done is confirmed.**

#### Create Design Document Immediately After Confirmation

**REQUIRED:** Once the user confirms the Definition of Done, create the design document file immediately. This captures the DoD at full fidelity before brainstorming begins.

##### Step 1: Get Design Plan Name

The slug becomes part of all acceptance criteria identifiers (e.g., `my-feature.AC1.1`) and appears in test names.

**If a slug was already supplied by the entry command or latest user message:**
- Validate it first.
- Valid format: lowercase hyphenated `a-z`, `0-9`, `-`.
- If valid, use it directly and do not ask again.
- If the user supplied a mixed-case ticket or descriptive phrase, normalize it to lowercase hyphenated form before file creation (for example `PROJ-1234` -> `proj-1234`, `My Cool Feature` -> `my-cool-feature`) and confirm only if the normalization changes meaning.

**If no usable slug was supplied already:** ask the user to choose it explicitly.

**Generate 2-3 suggested slugs** based on the conversation context. Good slugs are:
- Lowercase with hyphens (no spaces, underscores, or special characters)
- **Terse but unambiguous** — prefer short forms that don't create confusion (e.g., `authn` not `authentication`, but not `auth` since that's ambiguous with `authz`)
- Recognizable months later

**Use AskUserQuestion when available (otherwise ask directly with the same options):**

```
Question: "What should we call this design plan? The name becomes the prefix for all acceptance criteria (e.g., `{slug}.AC1.1`) and appears in test names.

If you have a ticketing system, you can use the ticket name (e.g., PROJ-1234)."

Options:
  - "[auto-generated-slug-1]" (e.g., "oauth2-svc-authn")
  - "[auto-generated-slug-2]" (e.g., "svc-authn")
  - "[auto-generated-slug-3]" (if meaningfully different)
```

**If user selects "Other":** They can provide any name. Normalize it:
- Ticket names (pattern: `UPPERCASE-DIGITS`, e.g., `PROJ-1234`): lowercase and keep hyphenated (for example `proj-1234`)
- Descriptive names: lowercase, hyphens for spaces, strip invalid characters (e.g., "My Cool Feature" → `my-cool-feature`)

##### Step 2: Create File

**File location:** `docs/design-plans/YYYY-MM-DD-{slug}.md`

Use today's date and the validated slug.

**Create the initial file through the shared scaffolder:**

1. Resolve the installed script path:
- `RESOLVER_PATH="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"`
- fail if `"$RESOLVER_PATH"` does not exist.
- `SCRIPT_PATH="$(bash "$RESOLVER_PATH" --plan-execute-script "new-design-plan.sh")"`
2. Run the scaffolder with the validated slug and a title derived from the feature name or confirmed Definition of Done:
- `bash "$SCRIPT_PATH" "<slug>" "<title>"`
3. If the plan already exists, stop and ask whether to reuse/update it instead of creating a second file.
4. Immediately replace scaffold placeholders with the highest-fidelity information already known:
- `## Definition of Done`: copy the confirmed Definition of Done exactly.
- `## Problem Statement`: replace the placeholder with a concise problem statement from Phases 1-2.
- `## Model Acquisition Path` and `## Required Workflow States`: fill these immediately when kickoff handoff was ingested.
5. Leave Summary, Acceptance Criteria, Implementation Phases, and Glossary placeholders for Phase 5.

**Why write immediately:**
- Captures Definition of Done at peak resolution (right after user confirmation)
- Prevents fidelity loss during brainstorming conversation
- Creates working document that grows incrementally
- Acceptance Criteria, Summary, and Glossary filled in later by writing-design-plans skill

Mark Phase 3 as completed when user confirms the Definition of Done AND the file is created.

### Phase 4: Brainstorming

With clear understanding from Phases 1-3, explore design alternatives and validate the approach.

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 4 as in_progress.

**REQUIRED SUB-SKILL:** Use scientific-plan-execute:brainstorming

Announce: "I'm using the brainstorming skill to explore design alternatives and validate the approach."

**Pass context to brainstorming:**
- Information gathered in Phase 1
- Clarifications from Phase 2
- Confirmed Definition of Done from Phase 3
- This reduces Phase 1 of brainstorming (Understanding) since much is already known

The brainstorming skill will:
- Complete any remaining understanding gaps (Phase 1)
- Propose 2-3 architectural approaches (Phase 2)
- Present design incrementally for validation (Phase 3)
- Use research agents for codebase patterns and external knowledge

**Output:** Validated design held in conversation context.

Mark Phase 4 as completed when design is validated.

### Phase 5: Design Documentation

Append the validated design to the document created in Phase 3.

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 5 as in_progress.

**REQUIRED SUB-SKILL:** Use scientific-plan-execute:writing-design-plans

Announce: "I'm using the writing-design-plans skill to complete the design document."

**Important:** The design document already exists from Phase 3 with:
- Title and metadata from the shared scientific design template
- Summary placeholder
- Problem Statement seeded from gathered context
- Confirmed Definition of Done
- Scientific model/readiness sections scaffolded for later completion
- Implementation Phases placeholder
- Acceptance Criteria placeholder
- Glossary placeholder

The writing-design-plans skill will:
- Fill the scaffolded scientific design sections and add implementation phases
- Structure with implementation phases (<=8 recommended)
  - DO NOT pad out phases in order to reach the number of 8. 8 is the maximum, not the target.
- Document existing patterns followed
- Generate Acceptance Criteria (success + failure cases for each DoD item), get human validation
- Generate Summary and Glossary to replace placeholders
- Commit to git

**Output:** Committed design document ready for implementation planning.

Mark Phase 5 as completed when design document is committed.

### Phase 6: Planning Handoff

After design is documented, guide user to create implementation plan in fresh context.

Use `update_plan` updates (or `TaskUpdate` where available) to mark Phase 6 as in_progress.

**Do NOT create implementation plan directly.** The user needs fresh context first.

Announce design completion and provide next steps:

Design complete! Design document committed to `docs/design-plans/<filename>`.

Ready to create the implementation plan? This requires fresh context to work effectively.

**IMPORTANT: Copy the command for your runtime below BEFORE clearing context or starting a new session.**

(1) Copy this command now:

Claude Code:
```
/start-implementation-plan @docs/design-plans/<full-filename>.md
```

Codex:
```
$starting-an-implementation-plan docs/design-plans/<full-filename>.md
```

(2) Start fresh context (recommended):

Claude Code:
```
/clear  # if your runtime supports it
```

Codex:
```
/new  # if your runtime supports it
```

If neither `/clear` nor `/new` is available, open a new session/conversation in the same repository.

(3) Paste and run the copied command in the fresh session.

The `starting-an-implementation-plan` skill (or `/start-implementation-plan` command wrapper) will create detailed tasks, set up a branch, and prepare for execution.

**Why fresh context instead of continuing:**
- Implementation planning needs fresh context for codebase investigation
- Long conversations accumulate context that degrades quality
- Fresh session/context gives the next phase a clean slate

Mark Phase 6 as completed after providing instructions.

## When to Revisit Earlier Phases

You can and should go backward when:
- Phase 2 reveals fundamental gaps -> Return to Phase 1
- Phase 2 reveals missing kickoff context -> Return to Kickoff Handoff Ingestion (and ask user to run kickoff if needed)
- Phase 3 reveals unclear deliverables -> Return to Phase 2 for more clarification
- Phase 4 uncovers new constraints -> Return to Phase 1, Kickoff Handoff Ingestion, 2, or 3
- User questions approach during Phase 4 -> Return to Phase 2
- Phase 4 changes the Definition of Done -> Return to Phase 3 to reconfirm
- Design documentation reveals missing details -> Return to Phase 4

**Don't force forward linearly** when going backward gives better results.

## Common Rationalizations - STOP

| Excuse | Reality |
|--------|---------|
| "User provided details, can skip context gathering" | Always run Phase 1. Ask for what's missing. |
| "Kickoff outputs can be ignored" | If `.scientific/kickoff.md` exists, ingest it before clarification and carry it into design context. |
| "Requirements are clear, skip clarification" | Clarification prevents misunderstandings. Always run Phase 2. |
| "I know what done looks like, skip confirmation" | Confirm Definition of Done explicitly. Always run Phase 3. |
| "Simple idea, skip brainstorming" | Brainstorming explores alternatives. Always run Phase 4. |
| "Design is in conversation, don't need documentation" | Documentation is contract with writing-implementation-plans. Always run Phase 5. |
| "Can invoke implementation planning directly" | Must use fresh context first. Provide copy-then-clear/new-session workflow. |
| "I can combine phases for efficiency" | Each phase has distinct purpose. Run all six core phases and include kickoff handoff ingestion when present. |
| "User knows what they want, less structure needed" | Structure ensures nothing is missed. Follow all phases. |

**All of these mean: STOP. Run the full phased workflow and ingest kickoff handoff when available.**

## Key Principles

| Principle | Application |
|-----------|-------------|
| **Never skip brainstorming** | Even with detailed specs, always run Phase 4 (may be shorter) |
| **Progressive prompting** | Ask for less if user already provided some context |
| **Kickoff handoff ingestion** | If kickoff artifact exists, treat it as required input to downstream design work |
| **Clarify before ideating** | Phase 2 prevents building the wrong thing |
| **Lock in the goal before exploring** | Phase 3 confirms what "done" means before brainstorming the how |
| **All brains in skills** | This skill orchestrates; sub-skills contain domain expertise |
| **Task tracking** | YOU MUST create todos with TaskCreate and update with TaskUpdate for all phases (or `TodoWrite` in runtimes that still expose it) |
| **Flexible progression** | Go backward when needed to fill gaps |
