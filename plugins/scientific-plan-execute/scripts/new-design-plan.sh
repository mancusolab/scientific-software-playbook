#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/new-design-plan.sh <slug> [title]

Creates:
- .plans/design-plans/YYYY-MM-DD-<slug>.md
- .plans/design-plans/artifacts/YYYY-MM-DD-<slug>/model-symbol-table.md
- .plans/design-plans/artifacts/YYYY-MM-DD-<slug>/equation-to-code-map.md
- .plans/design-plans/artifacts/YYYY-MM-DD-<slug>/solver-feasibility-matrix.md
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

slug="$1"
if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: slug must be lowercase-hyphenated (a-z, 0-9, -)." >&2
  exit 1
fi

title="${2:-${slug//-/ }}"
date_str="$(date +%F)"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bundle_plan_template="${script_dir}/../docs/design-plans/templates/scientific-architecture-plan-template.md"
bundle_artifact_templates_dir="${script_dir}/../docs/design-plans/templates/artifacts"
local_plan_template=".plans/design-plans/templates/scientific-architecture-plan-template.md"
local_artifact_templates_dir=".plans/design-plans/templates/artifacts"

if [[ -f "$local_plan_template" && -d "$local_artifact_templates_dir" ]]; then
  plan_template="$local_plan_template"
  artifact_templates_dir="$local_artifact_templates_dir"
elif [[ -f "$bundle_plan_template" && -d "$bundle_artifact_templates_dir" ]]; then
  plan_template="$bundle_plan_template"
  artifact_templates_dir="$bundle_artifact_templates_dir"
else
  echo "error: could not resolve design-plan templates" >&2
  echo "checked local: $local_plan_template" >&2
  echo "checked bundle: $bundle_plan_template" >&2
  exit 1
fi

plan_path=".plans/design-plans/${date_str}-${slug}.md"
artifact_dir=".plans/design-plans/artifacts/${date_str}-${slug}"

if [[ -e "$plan_path" ]]; then
  echo "error: plan already exists at $plan_path" >&2
  exit 2
fi

mkdir -p "$(dirname "$plan_path")" "$artifact_dir"

render_template() {
  local src="$1"
  local dst="$2"
  awk \
    -v date_str="$date_str" \
    -v slug="$slug" \
    -v title="$title" \
    -v artifact_dir="$artifact_dir" \
    '{
      gsub(/__DATE__/, date_str);
      gsub(/__SLUG__/, slug);
      gsub(/__TITLE__/, title);
      gsub(/__ARTIFACT_DIR__/, artifact_dir);
      print;
    }' "$src" > "$dst"
}

render_template "$plan_template" "$plan_path"

for src in "$artifact_templates_dir"/*.md; do
  [[ -f "$src" ]] || continue
  filename="$(basename "$src")"
  dst="${artifact_dir}/${filename/-template/}"
  render_template "$src" "$dst"
done

echo "Created plan:"
echo "  $plan_path"
echo "Created artifacts:"
echo "  $artifact_dir/model-symbol-table.md"
echo "  $artifact_dir/equation-to-code-map.md"
echo "  $artifact_dir/solver-feasibility-matrix.md"
