# ed3d-plugins

This is my collection of plugins that I use on a day-to-day basis for getting stuff done with Claude Code. Most are development-oriented, but many also help with product design, research, and general technical workflows. Skill content in this repo now includes Codex runtime compatibility guidance where practical.

The big stick in this repository is `ed3d-plan-and-execute`, which implements an "RPI" (research-plan-implement) loop that I think does a really good job of avoiding hallucination in the planning stages, adhering to high-level product requirements, avoiding drift between design planning and implementation planning, and reviewing the results such that you get out the other end not just what you asked for, but what you actually wanted.

**NOTE:** `ed3d-plugins` is generally a more stable marketplace. If you'd like to track changes as they happen a bit more aggressively, take a look at [`ed3d-plugins-testing`](https://github.com/ed3dai/ed3d-plugins-testing).

## Runtime Compatibility

This repository is primarily a Claude Code plugin collection. Many skills and docs now include compatibility guidance for Codex-style runtimes:

- Task tracking: `TaskCreate` / `TaskUpdate` / `TodoWrite` -> `update_plan`
- Delegation: Task/subagent patterns -> delegate when available, otherwise run directly
- Skill loading: Claude `Skill` tool references -> runtime-specific skill loader

Platform-specific features such as Claude slash commands and Claude hooks remain Claude-specific.

## Using `ed3d-plan-and-execute`
More in [the README for the plugin](plugins/ed3d-plan-and-execute/README.md), and it's worth skimming, but here's a quickstart:

```
Rough Idea
    │
    ▼
/start-design-plan  ──────► Design Document (committed to git)
    │
    ▼
/start-implementation-plan ──► Implementation Plan (phase files)
    │
    ▼
/execute-implementation-plan ──► Working Code (reviewed & committed)
```

**Customization:** Create `.ed3d/design-plan-guidance.md` and `.ed3d/implementation-plan-guidance.md` in your project to provide project-specific constraints, terminology, and standards. Run `/how-to-customize` for details.

## Plugins

| Plugin | Description |
|--------|-------------|
| **`ed3d-00-getting-started`** | Getting started guide and onboarding for ed3d-plugins. Run `/getting-started` to see this README. |
| **`ed3d-plan-and-execute`** | Planning and execution workflows (Claude-first, with Codex-compatible skill guidance). Feed it a decent-sized task and it helps drive sustainable, thought-through delivery |
| **`ed3d-house-style`** | House style for software development; Very Opinionated |
| **`ed3d-basic-agents`** | Core agents for general-purpose tasks (haiku, sonnet, opus, chatgpt5.3-codex) and generic-agent selection guidance. Other plugins expect this to exist |
| **`ed3d-research-agents`** | Agents for research across multiple data sources (codebase, internet, combined); other plugins expect this to exist |
| **`ed3d-extending-claude`** | Knowledge skills for extending agent workflows: plugins, commands, agents, skills, hooks, MCP servers. Other plugins expect this to exist |
| **`ed3d-playwright`**| Playwright automation with delegated agents |
| **`ed3d-hook-skill-reinforcement`** | UserPromptSubmit hook that reinforces the need to activate skills—helps make sure skills actually get used. Requires `ed3d-extending-claude` to work |
| **`ed3d-hook-claudemd-reminder`** | PostToolUse hook that reminds to update CLAUDE.md before committing |

## Installation

### Claude Code (Marketplace)

Add the marketplace:
```bash
/plugin marketplace add https://github.com/ed3dai/ed3d-plugins.git
```

Install plugins:
All plugins are available from the `ed3d-plugins` marketplace:
```bash
/plugin install ed3d-plan-and-execute@ed3d-plugins
/plugin install ed3d-house-style@ed3d-plugins
# ... etc
```

### Codex (Skills Only)

Codex does not install `.claude-plugin` packages directly. Instead, install skills by copying skill folders into `~/.codex/skills/`.

```bash
git clone https://github.com/ed3dai/ed3d-plugins.git
cd ed3d-plugins

mkdir -p ~/.codex/skills

# Core workflow skills
cp -R plugins/ed3d-plan-and-execute/skills/* ~/.codex/skills/
cp -R plugins/ed3d-house-style/skills/* ~/.codex/skills/
cp -R plugins/ed3d-research-agents/skills/* ~/.codex/skills/
cp -R plugins/ed3d-extending-claude/skills/* ~/.codex/skills/
cp -R plugins/ed3d-basic-agents/skills/* ~/.codex/skills/  # Optional: generic-agent selection helper
```

After copying, start a new Codex session so the new skills are available.

Notes:
- Claude-only plugin features (`/commands`, hooks, marketplace manifests) do not install into Codex.
- Skills in this repository include runtime compatibility guidance to map task-tracking and delegation behavior to Codex equivalents.

## Repository Structure

```
ed3d-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── ed3d-00-getting-started/
│   ├── ed3d-plan-and-execute/
│   ├── ed3d-house-style/
│   ├── ed3d-basic-agents/
│   ├── ed3d-research-agents/
│   ├── ed3d-extending-claude/
│   ├── ed3d-playwright/
│   ├── ed3d-hook-skill-reinforcement/
│   └── ed3d-hook-claudemd-reminder/
└── README.md
```

## Contributing
Issues and pull requests gratefully solicited, except `ed3d-house-style` is _my_ house style, and provided for reference, so I might not take contributions there. (You can make your own house-style plugin though and use that instead!)

## Attribution

`ed3d-plan-and-execute` and parts of `ed3d-extending-claude` are derived from [`obra/superpowers`](https://github.com/obra/superpowers) by Jesse Vincent. The original plugin has been folded, spindled, and mutilated extensively.

Some skills in `ed3d-house-style` are derived from `obra/superpowers` and others (`property-based-testing` is a big one) are derived from the [Trail of Bits Skills repository](https://github.com/trailofbits/skills).

## License

The original [obra/superpowers](https://github.com/obra/superpowers) code in this repository is licensed under the MIT License, copyright Jesse Vincent. See `plugins/ed3d-plan-and-execute/LICENSE.superpowers`.

All other content is licensed under the [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
