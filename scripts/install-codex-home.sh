#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
plugins_src_root="${repo_root}/plugins"
catalog_path="${repo_root}/plugins/scientific-plan-execute/scripts/plugin-catalog.sh"

if [[ ! -f "$catalog_path" ]]; then
  echo "error: missing plugin catalog: $catalog_path" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$catalog_path"

if ! declare -f ssp_valid_plugins >/dev/null 2>&1 || ! declare -f ssp_plugin_skills >/dev/null 2>&1 || ! declare -f ssp_plugin_required_paths >/dev/null 2>&1; then
  echo "error: plugin catalog does not define required functions" >&2
  exit 1
fi

valid_plugins=()
while IFS= read -r plugin; do
  [[ -n "$plugin" ]] || continue
  valid_plugins+=("$plugin")
done < <(ssp_valid_plugins)

usage() {
  cat <<USAGE
Usage: scripts/install-codex-home.sh [--codex-home <path>] [--plugin <name>] [--force] [--dry-run]

Installs playbook plugins into Codex home:
1. Skills -> <codex-home>/skills/
2. Plugin bundles -> <codex-home>/scientific-software-playbook/plugins/<plugin>/

Options:
  --codex-home <path>  Override CODEX_HOME (default: \$CODEX_HOME or ~/.codex)
  --plugin <name>      Plugin to install (repeatable). Default: all plugins
  --force              Overwrite existing installed playbook bundle
  --dry-run            Print what would be installed without making changes

Available plugins:
USAGE
  for plugin in "${valid_plugins[@]}"; do
    echo "  - ${plugin}"
  done
}

is_valid_plugin() {
  local target="$1"
  for plugin in "${valid_plugins[@]}"; do
    if [[ "$plugin" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

codex_home="${CODEX_HOME:-$HOME/.codex}"
force=0
dry_run=0
selected_plugins=()

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
    --plugin)
      if [[ $# -lt 2 ]]; then
        echo "error: --plugin requires a value" >&2
        usage
        exit 1
      fi
      if ! is_valid_plugin "$2"; then
        echo "error: invalid plugin: $2" >&2
        usage
        exit 1
      fi
      selected_plugins+=("$2")
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --dry-run)
      dry_run=1
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

if [[ ${#selected_plugins[@]} -eq 0 ]]; then
  selected_plugins=("${valid_plugins[@]}")
fi

# De-duplicate selected plugin list while preserving order.
dedup_plugins=()
seen_plugins="|"
for plugin in "${selected_plugins[@]}"; do
  if [[ "$seen_plugins" != *"|${plugin}|"* ]]; then
    dedup_plugins+=("$plugin")
    seen_plugins+="${plugin}|"
  fi
done
selected_plugins=("${dedup_plugins[@]}")

# Plan-execute relies on research + house-style skills for required workflow gates.
if [[ " ${selected_plugins[*]} " == *" scientific-plan-execute "* ]] && [[ " ${selected_plugins[*]} " != *" scientific-research "* ]]; then
  selected_plugins+=("scientific-research")
  echo "info: scientific-plan-execute depends on scientific-research; adding scientific-research automatically."
fi
if [[ " ${selected_plugins[*]} " == *" scientific-plan-execute "* ]] && [[ " ${selected_plugins[*]} " != *" scientific-house-style "* ]]; then
  selected_plugins+=("scientific-house-style")
  echo "info: scientific-plan-execute depends on scientific-house-style; adding scientific-house-style automatically."
fi

if [[ ! -d "$plugins_src_root" ]]; then
  echo "error: missing plugins directory at $plugins_src_root" >&2
  exit 1
fi

if [[ "$dry_run" -eq 1 ]]; then
  echo "[dry-run] Would install to: ${codex_home}"
  echo "[dry-run] Plugins:"
  for plugin in "${selected_plugins[@]}"; do
    echo "  - ${plugin}"
    while IFS= read -r skill; do
      [[ -n "$skill" ]] || continue
      echo "    skill: ${skill}"
    done < <(ssp_plugin_skills "$plugin")
  done
  echo "[dry-run] No files were modified."
  exit 0
fi

skills_dst="${codex_home}/skills"
bundle_root="${codex_home}/scientific-software-playbook"
plugins_dst="${bundle_root}/plugins"

if [[ -e "$bundle_root" && "$force" -ne 1 ]]; then
  echo "error: bundle already exists at $bundle_root (use --force to overwrite)" >&2
  exit 1
fi

if [[ -e "$bundle_root" ]]; then
  rm -rf "$bundle_root"
fi
mkdir -p "$bundle_root" "$plugins_dst" "$skills_dst"

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

# Reconcile managed skill directories on every install so plugin selection is
# deterministic across repeated --force runs.
managed_skills=()
seen_managed_skills="|"
for plugin in "${valid_plugins[@]}"; do
  while IFS= read -r skill; do
    [[ -n "$skill" ]] || continue
    if [[ "$seen_managed_skills" != *"|${skill}|"* ]]; then
      managed_skills+=("$skill")
      seen_managed_skills+="${skill}|"
    fi
  done < <(ssp_plugin_skills "$plugin")
done
for skill in "${managed_skills[@]}"; do
  rm -rf "${skills_dst}/${skill}"
done

# Clean retired skills that were removed from the catalog so old installs do not
# leave stale directories behind.
retired_skills=(
  "install-scientific-software-playbook-home"
  "howto-functional-vs-imperative"
)
for skill in "${retired_skills[@]}"; do
  rm -rf "${skills_dst}/${skill}"
done

installed_skills=()
installed_plugins=()

for plugin in "${selected_plugins[@]}"; do
  src_plugin_dir="${plugins_src_root}/${plugin}"
  if [[ ! -d "$src_plugin_dir" ]]; then
    echo "error: missing plugin source directory: $src_plugin_dir" >&2
    exit 1
  fi

  while IFS= read -r req_path; do
    [[ -n "$req_path" ]] || continue
    if [[ ! -e "${src_plugin_dir}/${req_path}" ]]; then
      echo "error: plugin ${plugin} missing required path: ${src_plugin_dir}/${req_path}" >&2
      exit 1
    fi
  done < <(ssp_plugin_required_paths "$plugin")

  dst_plugin_dir="${plugins_dst}/${plugin}"
  copy_tree "$src_plugin_dir" "$dst_plugin_dir"
  installed_plugins+=("$plugin")

  while IFS= read -r skill; do
    [[ -n "$skill" ]] || continue
    src_skill_dir="${src_plugin_dir}/skills/${skill}"
    dst_skill_dir="${skills_dst}/${skill}"
    if [[ ! -d "$src_skill_dir" ]]; then
      echo "error: missing skill directory for plugin ${plugin}: $src_skill_dir" >&2
      exit 1
    fi
    if [[ ! -f "${src_skill_dir}/SKILL.md" ]]; then
      echo "error: missing SKILL.md for plugin ${plugin}: ${src_skill_dir}/SKILL.md" >&2
      exit 1
    fi
    copy_tree "$src_skill_dir" "$dst_skill_dir"
    installed_skills+=("$skill")
  done < <(ssp_plugin_skills "$plugin")
done

if [[ " ${selected_plugins[*]} " == *" scientific-plan-execute "* ]]; then
  plan_dst="${plugins_dst}/scientific-plan-execute"
  chmod +x \
    "${plan_dst}/scripts/hooks/session-start.sh" \
    "${plan_dst}/scripts/hooks/post-edit.sh" \
    "${plan_dst}/scripts/hooks/stop.sh" \
    "${plan_dst}/scripts/check-required-house-style-skills.sh" \
    "${plan_dst}/scripts/run-required-house-style-preflight.sh" \
    "${plan_dst}/scripts/new-design-plan.sh" \
    "${plan_dst}/scripts/set-design-plan-status.sh" \
    "${plan_dst}/scripts/validate-design-plan-readiness.sh" \
    "${plan_dst}/scripts/plugin-catalog.sh"
fi

echo "Installed plugins:"
for plugin in "${installed_plugins[@]}"; do
  echo "  - ${plugins_dst}/${plugin}"
done

echo

echo "Installed Codex skills:"
for skill in "${installed_skills[@]}"; do
  echo "  - ${skills_dst}/${skill}/SKILL.md"
done

echo
if [[ " ${selected_plugins[*]} " == *" scientific-plan-execute "* ]]; then
  echo "Next step (per downstream project):"
  echo "  Open target project root in Codex and invoke: using-plan-and-execute"
else
  echo "Plan-execute plugin not selected."
  echo "Install with --plugin scientific-plan-execute to enable workflow commands."
fi
