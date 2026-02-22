#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/bootstrap-scientific-software-playbook.sh [project-root] [--force]

Copies playbook assets into a downstream project and writes AGENTS.md that
references globally installed skills in CODEX_HOME.

Options:
  --force   Overwrite existing destination files/directories
EOF
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
bundle_root="$(cd "${script_dir}/.." && pwd)"
codex_home="$(cd "${bundle_root}/.." && pwd)"

target_parent="$(dirname "$target_root_input")"
mkdir -p "$target_parent"
target_base="$(basename "$target_root_input")"
if [[ "$target_base" == "." ]]; then
  target_root="$(cd "$target_parent" && pwd)"
else
  target_root="$(cd "$target_parent" && pwd)/$target_base"
fi
mkdir -p "$target_root"

copy_path() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "error: missing source path: $src" >&2
    exit 1
  fi

  if [[ -e "$dst" && "$force" -ne 1 ]]; then
    echo "error: destination already exists: $dst (re-run with --force)" >&2
    exit 1
  fi

  if [[ -e "$dst" ]]; then
    rm -rf "$dst"
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -d "$src" ]]; then
    if command -v rsync >/dev/null 2>&1; then
      mkdir -p "$dst"
      rsync -a --delete "${src}/" "${dst}/"
    else
      cp -R "$src" "$dst"
    fi
  else
    cp -f "$src" "$dst"
  fi
}

copy_path "${bundle_root}/agents" "${target_root}/agents"
copy_path "${bundle_root}/commands" "${target_root}/commands"

copy_path "${bundle_root}/scripts/new-design-plan.sh" "${target_root}/scripts/new-design-plan.sh"
copy_path "${bundle_root}/scripts/set-design-plan-status.sh" "${target_root}/scripts/set-design-plan-status.sh"
copy_path "${bundle_root}/scripts/validate-design-plan-readiness.sh" "${target_root}/scripts/validate-design-plan-readiness.sh"

copy_path "${bundle_root}/docs/design-plans/templates" "${target_root}/docs/design-plans/templates"
copy_path "${bundle_root}/docs/reviews/review-template.md" "${target_root}/docs/reviews/review-template.md"
copy_path "${bundle_root}/docs/checklists/skill-agent-io-checklist.md" "${target_root}/docs/checklists/skill-agent-io-checklist.md"

chmod +x \
  "${target_root}/scripts/new-design-plan.sh" \
  "${target_root}/scripts/set-design-plan-status.sh" \
  "${target_root}/scripts/validate-design-plan-readiness.sh"

agents_path="${target_root}/AGENTS.md"
if [[ -e "$agents_path" && "$force" -ne 1 ]]; then
  echo "error: destination already exists: $agents_path (re-run with --force)" >&2
  exit 1
fi

cat > "$agents_path" <<EOF
## Scientific Software Playbook (Codex Native)

This project was bootstrapped from:
\`${bundle_root}\`

### Global skills (installed in CODEX_HOME)
- \`bootstrap-scientific-software-playbook\`: \`${codex_home}/skills/bootstrap-scientific-software-playbook/SKILL.md\`
- \`scientific-software-architecture\`: \`${codex_home}/skills/scientific-software-architecture/SKILL.md\`
- \`ingress-to-canonical-jax\`: \`${codex_home}/skills/ingress-to-canonical-jax/SKILL.md\`
- \`validation-first-pipeline-api\`: \`${codex_home}/skills/validation-first-pipeline-api/SKILL.md\`
- \`jax-equinox-core-numerics-shell\`: \`${codex_home}/skills/jax-equinox-core-numerics-shell/SKILL.md\`
- \`scientific-cli-thin-shell\`: \`${codex_home}/skills/scientific-cli-thin-shell/SKILL.md\`

### Local playbook assets (this repository)
- Agents: \`agents/\`
- Commands: \`commands/\`
- Scripts: \`scripts/\`
- Templates: \`docs/design-plans/templates/\`
- Review template: \`docs/reviews/review-template.md\`
- IO checklist: \`docs/checklists/skill-agent-io-checklist.md\`

### Workflow
1. Start with \`scientific-software-architecture\`.
   - Note: \`bootstrap-scientific-software-playbook\` is only for one-time project initialization.
2. Create a plan:
   - \`bash scripts/new-design-plan.sh <slug>\`
3. Validate draft readiness:
   - \`bash scripts/validate-design-plan-readiness.sh <plan-path> --phase in-review\`
4. Approve after explicit user sign-off:
   - \`bash scripts/set-design-plan-status.sh <plan-path> approved-for-implementation\`
5. Implement in order:
   - \`ingress-to-canonical-jax\`
   - \`validation-first-pipeline-api\`
   - \`jax-equinox-core-numerics-shell\`
   - \`scientific-cli-thin-shell\`
EOF

echo "Bootstrapped playbook assets into:"
echo "  ${target_root}"
echo
echo "Created:"
echo "  ${target_root}/AGENTS.md"
echo "  ${target_root}/agents/"
echo "  ${target_root}/commands/"
echo "  ${target_root}/scripts/"
echo "  ${target_root}/docs/design-plans/templates/"
