#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/new-design-plan.sh <slug> [title]

Creates:
- docs/design-plans/YYYY-MM-DD-<slug>.md
- docs/design-plans/artifacts/YYYY-MM-DD-<slug>/model-symbol-table.md
- docs/design-plans/artifacts/YYYY-MM-DD-<slug>/equation-to-code-map.md
- docs/design-plans/artifacts/YYYY-MM-DD-<slug>/solver-feasibility-matrix.md
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

plan_template="docs/design-plans/templates/scientific-architecture-plan-template.md"
artifact_templates_dir="docs/design-plans/templates/artifacts"
plan_path="docs/design-plans/${date_str}-${slug}.md"
artifact_dir="docs/design-plans/artifacts/${date_str}-${slug}"

if [[ ! -f "$plan_template" ]]; then
  echo "error: missing plan template at $plan_template" >&2
  exit 1
fi

if [[ ! -d "$artifact_templates_dir" ]]; then
  echo "error: missing artifact templates directory at $artifact_templates_dir" >&2
  exit 1
fi

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
