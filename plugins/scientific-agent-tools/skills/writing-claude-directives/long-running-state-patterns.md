# Long-Running State Patterns

Patterns for managing Claude agents across extended multi-context-window workflows. This is optional reference content for when you need to design long-running agent systems.

## Core Challenge

Long-running agents work in discrete sessions. Each new session starts without memory of previous sessions. Complex projects span multiple context windows. The solution: bridge gaps through structured artifacts and explicit state management.

## Context Management

### Automatic Tools

**Auto-Compact**: Triggers at ~95% context capacity. Claude Code summarizes history, preserving architectural decisions and unresolved bugs. Manually trigger with `/compact` at logical breakpoints.

**Token Budget Awareness**: Claude 4.5+ receives updates on remaining context after tool calls. Enables better task persistence and strategy adjustment.

### Compression Strategies (Karpathy Framework)

| Strategy | Description |
|----------|-------------|
| Write | Save context externally to reference later |
| Select | Load relevant context on-demand |
| Compress | Retain only tokens needed for current task |
| Isolate | Split work across subagents with clean windows |

**Hierarchical Summarization**: Subagents return condensed summaries (1,000-2,000 tokens) rather than full exploration context.

**Just-In-Time Loading**: Maintain lightweight identifiers (file paths, queries). Load data at runtime using tools.

## State Persistence

### Git-Based State Tracking

Anthropic recommends combining git history with structured progress files:

**Two-Agent Pattern**:
1. **Initializer Agent** (first session): Sets up environment, creates `init.sh` and `claude-progress.txt`, makes initial commit
2. **Coding Agent** (subsequent): Reads git history + progress files, works incrementally, commits with descriptive messages

**Why This Works**: Fresh agents understand state quickly from git + progress file. Commits enable recovery. Progress tracking prevents premature completion.

### Structured Progress Files

```
# Project Progress Log

## Current Status
- Session: [timestamp]
- Focus: [current task]
- Blockers: [if any]

## Completed Features
- Feature A: ✓ (commit abc123)

## In Progress
- Feature B: [current work description]

## Pending
- Feature C: [description]

## Testing Status
- Unit: ✓
- Integration: [status]
- E2E: [status]
```

### JSON Feature Lists

```json
{
  "features": [
    {
      "id": "auth-login",
      "status": "complete",
      "tested": true,
      "commit": "abc123"
    }
  ]
}
```

Explicit feature lists prevent premature completion and duplicate work.

## Failure Mode Prevention

| Failure | Symptom | Prevention |
|---------|---------|------------|
| One-shotting | Runs out of context mid-implementation | Work on single feature at a time, commit frequently |
| Premature completion | Half-implemented feature marked done | Require E2E verification before marking complete |
| Context loss | Next session duplicates effort | Structured progress file + clear git messages |

## Multi-Context-Window Workflows

### Session Initialization Ritual

1. `pwd` - establish location
2. `git log --oneline -20` - review recent work
3. Read progress file and CLAUDE.md
4. `source init.sh` - start services
5. Run tests to verify baseline
6. Choose single feature from pending list

### Context Boundary Crossing

**Manual Compact** (Recommended): At logical breakpoints, run `/compact`, then reset context (`/clear` when available; otherwise start a new session). Start fresh on next feature.

**Memory Tool Preservation**: Before context limits, save state to memory files. Update CLAUDE.md and progress file.

## Subagent Orchestration

### Orchestrator-Worker Pattern

```
Orchestrator (Opus 4.5)
├── Holds plan, routes tasks
├── No implementation work
└── Context reserved for coordination

Subagents (Sonnet/Haiku 4.5)
├── Focused expertise
├── Own context window
├── Returns condensed results
└── Task-specific configuration
```

**Why Orchestration-Only Main Agent**: When main agent implements, everything competes for same context. Subagents get clean, dedicated context.

### Model Selection

| Model | Use For | Cost |
|-------|---------|------|
| Opus 4.5 | Orchestration, complex planning | $15/M output |
| Sonnet 4.5 | Focused implementation | $15/M output |
| Haiku 4.5 | Simple tasks (90% of Sonnet capability) | $5/M output |

Haiku 4.5 makes multi-agent orchestration economically viable.

## Test-Driven Long-Horizon Tasks

### Why Tests Matter for Agents

- Tests provide objective verification targets
- Failing tests guide implementation
- Multiple rounds (2-3) yield better results
- Enable confident recovery via revert

### Progressive Testing Across Sessions

```
Session 1: Unit tests + implementation
Session 2: Integration tests
Session 3: E2E tests
Session 4: Deployment verification
```

## Failure Recovery

### Git Recovery Strategies

**Session Branches**:
```bash
git checkout -b claude-session/$(date +%s)
# Merge on success, delete on failure
```

**Checkpoint Stash**:
```bash
git stash save "claude-checkpoint: $(date)"
```

### Claude Code Checkpoints

- Esc+Esc or `/rewind` opens checkpoint menu
- Can restore conversation, code, or both
- Bash commands (`rm`, `mv`) are not tracked

## Key Insights

### What Works

1. **Explicit state** beats implicit understanding
2. **Incremental commits** beat large commits
3. **Feature lists** prevent premature completion
4. **Tests drive implementation**
5. **Multi-agent** beats single-agent for complex tasks

### Common Pitfalls

These patterns consistently cause session failures:

1. Building everything in one session → Work one feature at a time
2. Assuming prior state → Verify with git log + progress file first
3. Relying on conversation history alone → Use structured artifacts
4. Vague requirements → Define explicit acceptance criteria
5. No recovery plan → Use session branches or checkpoint stashes

## References

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Code Best practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [claude-flow](https://github.com/ruvnet/claude-flow) - Multi-agent orchestration
- [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) - CI/CD loop pattern
