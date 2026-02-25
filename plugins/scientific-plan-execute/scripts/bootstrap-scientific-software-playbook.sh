#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-scientific-software-playbook.sh [project-root] [--force]

Writes project-local AGENTS.md that references globally installed playbook
assets in CODEX_HOME.

Options:
  --force   Overwrite existing AGENTS.md
USAGE
}

force=0
target_root_input="."

for arg in "$@"; do
  case "$arg" in
    --force)
      force=1
      ;;
    -*)
      echo "error: unknown argument: $arg" >&2
      usage
      exit 1
      ;;
    *)
      if [[ "$target_root_input" != "." ]]; then
        echo "error: multiple project-root arguments provided" >&2
        usage
        exit 1
      fi
      target_root_input="$arg"
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
catalog_path="${script_dir}/plugin-catalog.sh"

if [[ ! -f "$catalog_path" ]]; then
  echo "error: missing plugin catalog: $catalog_path" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$catalog_path"

if ! declare -f ssp_valid_plugins >/dev/null 2>&1 || ! declare -f ssp_plugin_skills >/dev/null 2>&1; then
  echo "error: plugin catalog does not define required functions" >&2
  exit 1
fi

codex_home="${CODEX_HOME:-$HOME/.codex}"
bundle_root="${codex_home}/scientific-software-playbook"
plugin_root="${bundle_root}/plugins/scientific-plan-execute"
if [[ ! -d "$plugin_root" ]]; then
  echo "error: expected installed plan-execute bundle at $plugin_root" >&2
  echo "run from a playbook checkout: bash scripts/install-codex-home.sh --force" >&2
  exit 1
fi

target_parent="$(dirname "$target_root_input")"
mkdir -p "$target_parent"
target_base="$(basename "$target_root_input")"
if [[ "$target_base" == "." ]]; then
  target_root="$(cd "$target_parent" && pwd)"
else
  target_root="$(cd "$target_parent" && pwd)/$target_base"
fi
mkdir -p "$target_root"

agents_path="${target_root}/AGENTS.md"
if [[ -e "$agents_path" && "$force" -ne 1 ]]; then
  echo "error: destination already exists: $agents_path (re-run with --force)" >&2
  exit 1
fi

installed_plugins=()
while IFS= read -r plugin; do
  [[ -n "$plugin" ]] || continue
  if [[ -d "${bundle_root}/plugins/${plugin}" ]]; then
    installed_plugins+=("$plugin")
  fi
done < <(ssp_valid_plugins)

if [[ ${#installed_plugins[@]} -eq 0 ]]; then
  installed_plugins=("scientific-plan-execute")
fi

skill_lines=()
seen_skills="|"
for plugin in "${installed_plugins[@]}"; do
  while IFS= read -r skill; do
    [[ -n "$skill" ]] || continue
    if [[ "$seen_skills" == *"|${skill}|"* ]]; then
      continue
    fi
    if [[ -f "${codex_home}/skills/${skill}/SKILL.md" ]]; then
      skill_lines+=("- \`${skill}\`: \`${codex_home}/skills/${skill}/SKILL.md\`")
      seen_skills+="${skill}|"
    fi
  done < <(ssp_plugin_skills "$plugin")
done

skills_block=""
for line in "${skill_lines[@]}"; do
  skills_block+="${line}"$'\n'
done

plugin_block=""
for plugin in "${installed_plugins[@]}"; do
  plugin_block+="- \`${plugin}\`: \`${bundle_root}/plugins/${plugin}\`"$'\n'
done

house_style_block=""
if [[ -d "${bundle_root}/plugins/scientific-house-style" ]]; then
  house_style_block="- House-style docs: \`${bundle_root}/plugins/scientific-house-style/docs/\`"
fi

research_block=""
if [[ -d "${bundle_root}/plugins/scientific-research" ]]; then
  research_block="- Research agents/skills: \`${bundle_root}/plugins/scientific-research/\`"
fi

cat > "$agents_path" <<AGENT_EOF
## Scientific Software Playbook (Codex Native)

This project was bootstrapped from:
\`${plugin_root}\`

### Installed plugins (in CODEX_HOME)
${plugin_block}
### Global skills (installed in CODEX_HOME)
${skills_block}
### Global playbook assets (not copied into this repository)
- Agents: \`${plugin_root}/agents/\`
- Commands: \`${plugin_root}/commands/\`
- Hooks: \`${plugin_root}/hooks/\` (runtime hook definitions)
- Scripts: \`${plugin_root}/scripts/\` (internal utilities invoked by skills/hooks)
- Templates: \`${plugin_root}/docs/design-plans/templates/\`
- Templates: \`${plugin_root}/docs/implementation-plans/templates/\`
- Review template: \`${plugin_root}/docs/reviews/review-template.md\`
- IO checklist: \`${plugin_root}/docs/checklists/skill-agent-io-checklist.md\`
${research_block}
${house_style_block}

### Project-local footprint
- \`AGENTS.md\` only (this file).
- Workflow outputs (design plans, implementation plans, and reviews) are created under \`docs/\` in this project as you work.

### Workflow
1. Start with \`scientific-software-architecture\`.
   - Note: \`bootstrap-scientific-software-playbook\` is only for one-time project initialization.
2. Create a plan:
   - choose model path (\`provided-model\` or \`suggested-model\`).
   - invoke \`simulation-for-inference-validation\` when simulation-based inference validation is in scope.
   - invoke \`new-design-plan\` with a slug.
   - invoke \`scientific-internet-research-pass\` when external claims need citations.
   - delegate \`internet-researcher\` or \`scientific-literature-researcher\` when needed.
3. Validate draft readiness:
   - invoke \`validate-design-plan\` with phase \`in-review\`.
4. Approve after explicit user sign-off:
   - invoke \`set-design-plan-status\` with \`approved-for-implementation\`.
5. Create implementation orchestration artifacts:
   - invoke \`start-scientific-implementation-plan\`.
6. Execute implementation phases:
   - invoke \`execute-scientific-implementation-plan\`.
7. During phase execution, apply layer skills in order when relevant:
   - \`validation-first-pipeline-api\`
   - \`jax-equinox-numerics\` (from \`scientific-house-style\`, when installed)
   - \`scientific-cli-thin-shell\`
AGENT_EOF

echo "Bootstrapped project configuration in:"
echo "  ${target_root}"
echo
echo "Created:"
echo "  ${target_root}/AGENTS.md"
echo
echo "No other playbook files were copied into this project."
