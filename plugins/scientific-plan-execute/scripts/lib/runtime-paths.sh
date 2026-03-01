#!/usr/bin/env bash
# shellcheck shell=bash

# Shared runtime-path resolution helpers for Codex and Claude plugin installs.

ssp_resolve_plugin_root() {
  local plugin
  plugin="${1:-}"
  if [[ -z "$plugin" ]]; then
    echo "error: ssp_resolve_plugin_root requires <plugin>" >&2
    return 1
  fi

  if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    local claude_root
    claude_root="${CLAUDE_PLUGIN_ROOT%/}"

    if [[ -d "$claude_root" && "$(basename "$claude_root")" == "$plugin" ]]; then
      printf '%s\n' "$claude_root"
      return 0
    fi

    local claude_sibling
    claude_sibling="$(cd "$claude_root/.." 2>/dev/null && pwd)/${plugin}"
    if [[ -d "$claude_sibling" ]]; then
      printf '%s\n' "$claude_sibling"
      return 0
    fi
  fi

  local codex_plugin_root
  codex_plugin_root="${CODEX_HOME:-$HOME/.codex}/scientific-software-playbook/plugins/${plugin}"
  if [[ -d "$codex_plugin_root" ]]; then
    printf '%s\n' "$codex_plugin_root"
    return 0
  fi

  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local plan_execute_root
  plan_execute_root="$(cd "$lib_dir/../.." && pwd)"

  if [[ -d "$plan_execute_root" && "$(basename "$plan_execute_root")" == "$plugin" ]]; then
    printf '%s\n' "$plan_execute_root"
    return 0
  fi

  local sibling_from_plan_execute
  sibling_from_plan_execute="$(cd "$plan_execute_root/.." && pwd)/${plugin}"
  if [[ -d "$sibling_from_plan_execute" ]]; then
    printf '%s\n' "$sibling_from_plan_execute"
    return 0
  fi

  echo "error: could not resolve plugin root for '${plugin}' (checked CLAUDE_PLUGIN_ROOT, CODEX_HOME, and local sibling paths)" >&2
  return 1
}

ssp_resolve_plugin_asset() {
  local plugin relpath
  plugin="${1:-}"
  relpath="${2:-}"

  if [[ -z "$plugin" || -z "$relpath" ]]; then
    echo "error: ssp_resolve_plugin_asset requires <plugin> <relative-path>" >&2
    return 1
  fi

  local plugin_root
  plugin_root="$(ssp_resolve_plugin_root "$plugin")" || return 1

  # Normalize leading ./ to keep joined paths predictable.
  relpath="${relpath#./}"
  printf '%s\n' "${plugin_root}/${relpath}"
}

ssp_resolve_plan_execute_script() {
  local script_name
  script_name="${1:-}"
  if [[ -z "$script_name" ]]; then
    echo "error: ssp_resolve_plan_execute_script requires <script-name>" >&2
    return 1
  fi

  local script_path
  script_path="$(ssp_resolve_plugin_asset "scientific-plan-execute" "scripts/${script_name}")" || return 1

  if [[ ! -f "$script_path" ]]; then
    echo "error: plan-execute script not found: $script_path" >&2
    return 1
  fi

  printf '%s\n' "$script_path"
}
