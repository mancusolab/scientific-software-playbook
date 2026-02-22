#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install-codex-home.sh [--codex-home <path>] [--force]

Installs this playbook into Codex home:
1. Skills -> <codex-home>/skills/
2. Playbook bundle (agents/commands/scripts/templates) ->
   <codex-home>/scientific-software-playbook/

Options:
  --codex-home <path>  Override CODEX_HOME (default: $CODEX_HOME or ~/.codex)
  --force              Overwrite existing installed playbook bundle
EOF
}

codex_home="${CODEX_HOME:-$HOME/.codex}"
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-home)
      if [[ $# -lt 2 ]]; then
        echo "error: --codex-home requires a value" >&2
        usage
        exit 1
      fi
      codex_home="$2"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

skills_src="${repo_root}/skills"
agents_src="${repo_root}/agents"
commands_src="${repo_root}/commands"
scripts_src="${repo_root}/scripts"
docs_src="${repo_root}/docs"

if [[ ! -d "$skills_src" || ! -d "$agents_src" || ! -d "$commands_src" || ! -d "$scripts_src" ]]; then
  echo "error: script must be run from a repository checkout with skills/agents/commands/scripts" >&2
  exit 1
fi

skills_dst="${codex_home}/skills"
bundle_dst="${codex_home}/scientific-software-playbook"

skill_dirs=(
  "bootstrap-scientific-software-playbook"
  "scientific-software-architecture"
  "ingress-to-canonical-jax"
  "validation-first-pipeline-api"
  "jax-equinox-core-numerics-shell"
  "scientific-cli-thin-shell"
)

mkdir -p "$skills_dst"

copy_tree() {
  local src="$1"
  local dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    mkdir -p "$dst"
    rsync -a --delete "${src}/" "${dst}/"
  else
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
  fi
}

for skill in "${skill_dirs[@]}"; do
  src="${skills_src}/${skill}"
  dst="${skills_dst}/${skill}"
  if [[ ! -d "$src" ]]; then
    echo "error: missing skill directory: $src" >&2
    exit 1
  fi
  copy_tree "$src" "$dst"
done

if [[ -e "$bundle_dst" && "$force" -ne 1 ]]; then
  echo "error: bundle already exists at $bundle_dst (use --force to overwrite)" >&2
  exit 1
fi

if [[ -e "$bundle_dst" ]]; then
  rm -rf "$bundle_dst"
fi
mkdir -p "$bundle_dst"

copy_tree "$agents_src" "${bundle_dst}/agents"
copy_tree "$commands_src" "${bundle_dst}/commands"
copy_tree "$scripts_src" "${bundle_dst}/scripts"

mkdir -p "${bundle_dst}/docs/design-plans" "${bundle_dst}/docs/reviews" "${bundle_dst}/docs/checklists"
copy_tree "${docs_src}/design-plans/templates" "${bundle_dst}/docs/design-plans/templates"
cp -f "${docs_src}/reviews/review-template.md" "${bundle_dst}/docs/reviews/review-template.md"
cp -f "${docs_src}/checklists/skill-agent-io-checklist.md" "${bundle_dst}/docs/checklists/skill-agent-io-checklist.md"

chmod +x \
  "${bundle_dst}/scripts/new-design-plan.sh" \
  "${bundle_dst}/scripts/set-design-plan-status.sh" \
  "${bundle_dst}/scripts/validate-design-plan-readiness.sh" \
  "${bundle_dst}/scripts/bootstrap-scientific-software-playbook.sh" \
  "${bundle_dst}/scripts/install-codex-home.sh"

echo "Installed Codex skills:"
for skill in "${skill_dirs[@]}"; do
  echo "  - ${skills_dst}/${skill}/SKILL.md"
done
echo
echo "Installed playbook bundle:"
echo "  - ${bundle_dst}"
echo
echo "Next step (per downstream project):"
echo "  bash \"${bundle_dst}/scripts/bootstrap-scientific-software-playbook.sh\" /path/to/project"
