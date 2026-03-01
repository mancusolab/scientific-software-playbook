#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/resolve-plugin-path.sh <plugin> <relative-path>
  scripts/resolve-plugin-path.sh --plan-execute-script <script-name>

Examples:
  scripts/resolve-plugin-path.sh scientific-plan-execute scripts/new-design-plan.sh
  scripts/resolve-plugin-path.sh --plan-execute-script new-design-plan.sh
USAGE
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${script_dir}/lib/runtime-paths.sh"

if [[ "$1" == "--plan-execute-script" ]]; then
  if [[ $# -ne 2 ]]; then
    usage
    exit 1
  fi
  ssp_resolve_plan_execute_script "$2"
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

ssp_resolve_plugin_asset "$1" "$2"
