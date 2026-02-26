#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${script_dir}/lib/runtime-paths.sh"

required_skills=("$@")
if [[ ${#required_skills[@]} -eq 0 ]]; then
  required_skills=(
    "jax-equinox-numerics"
    "jax-project-engineering"
    "coding-effectively"
  )
fi

house_style_root="$(ssp_resolve_plugin_root "scientific-house-style")" || {
  echo "error: scientific-house-style plugin root is not resolvable in this runtime." >&2
  echo "fix: install scientific-house-style and retry." >&2
  exit 1
}

missing_paths=()
for skill in "${required_skills[@]}"; do
  skill_path="${house_style_root}/skills/${skill}/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    missing_paths+=("$skill_path")
  fi
done

if [[ ${#missing_paths[@]} -gt 0 ]]; then
  echo "error: required scientific-house-style skills are missing:" >&2
  for path in "${missing_paths[@]}"; do
    echo "  - ${path}" >&2
  done
  echo "fix (Codex): bash scripts/install-codex-home.sh --plugin scientific-plan-execute --force" >&2
  echo "fix (Claude Code): /plugin install scientific-house-style@scientific-software-playbook" >&2
  exit 1
fi

echo "house_style_dependency_check_ok"
