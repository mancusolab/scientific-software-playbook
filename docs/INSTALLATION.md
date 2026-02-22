# Installation and Usage Guide

This guide is for GitHub distribution. It installs reusable assets into Codex home
and bootstraps any downstream project with local playbook files.

## Prerequisites

1. `git`
2. `bash`
3. Codex and/or Claude

## Clone

```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

## Codex Installation (Global, Reusable)

Install skills and playbook assets into Codex home:

```bash
bash scripts/install-codex-home.sh --force
```

What this installs:
1. Skills to `${CODEX_HOME:-$HOME/.codex}/skills/`
   - `bootstrap-scientific-software-playbook`
   - `scientific-software-architecture`
   - `ingress-to-canonical-jax`
   - `validation-first-pipeline-api`
   - `jax-equinox-core-numerics-shell`
   - `scientific-cli-thin-shell`
2. Bundle assets to `${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/`
   - `agents/`
   - `commands/`
   - `scripts/`
   - `docs/design-plans/templates/`
   - review/checklist templates

## Bootstrap a Downstream Project

After global install, run:

```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh" /path/to/project --force
```

This copies project-local assets and writes `/path/to/project/AGENTS.md` that
references globally installed skills in Codex home.

### Codex Skill Shortcut (Current Directory)

After global install, users can call the `bootstrap-scientific-software-playbook` skill from
the target project's current directory. The skill runs:

```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh"
```

Use `--force` only when replacing existing playbook files.

### What `bootstrap-scientific-software-playbook` Is For

`bootstrap-scientific-software-playbook` is a one-time project initialization wrapper. It:
1. Copies playbook assets into the current project.
2. Writes project `AGENTS.md` with global skill paths.
3. Verifies expected files exist.

It does not design or implement scientific workflows by itself.

## Claude Installation (Plugin)

Claude uses:

- `.claude-plugin/plugin.json`

Register the manifest using your Claude client's local plugin workflow.

## Verify Codex Install

```bash
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
ls "$CODEX_ROOT/skills/scientific-software-architecture/SKILL.md"
ls "$CODEX_ROOT/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh"
ls "$CODEX_ROOT/skills/bootstrap-scientific-software-playbook/SKILL.md"
```

## Verify Downstream Bootstrap

```bash
cd /path/to/project
ls AGENTS.md
ls scripts/new-design-plan.sh
ls docs/design-plans/templates/scientific-architecture-plan-template.md
```

## Usage Example (Downstream Project)

```bash
cd /path/to/project
bash scripts/new-design-plan.sh genetics-infer
PLAN_PATH="$(ls -1 docs/design-plans/*-genetics-infer.md)"
bash scripts/validate-design-plan-readiness.sh "$PLAN_PATH" --phase in-review
```

After explicit approval:

```bash
bash scripts/set-design-plan-status.sh "$PLAN_PATH" approved-for-implementation
```

## Upgrade / Reinstall

From a newer checkout of this repository:

```bash
bash scripts/install-codex-home.sh --force
```

Then re-bootstrap downstream projects that should receive updated assets:

```bash
bash "${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/scripts/bootstrap-scientific-software-playbook.sh" /path/to/project --force
```
