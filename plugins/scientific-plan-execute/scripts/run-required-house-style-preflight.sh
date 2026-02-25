#!/usr/bin/env bash
set -euo pipefail

resolver_path="${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/scientific-plan-execute}/scripts/resolve-plugin-path.sh"
if [[ ! -f "$resolver_path" ]]; then
  echo "error: resolver not found: $resolver_path" >&2
  exit 1
fi

checker_path="$(bash "$resolver_path" --plan-execute-script "check-required-house-style-skills.sh")"
bash "$checker_path"
