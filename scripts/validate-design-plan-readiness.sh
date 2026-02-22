#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/validate-design-plan-readiness.sh <plan-path> [--phase in-review|approval]

Validates whether a design plan is ready to transition to
"Approved for Implementation".
EOF
}

phase="approval"
if [[ $# -eq 3 ]]; then
  if [[ "$2" != "--phase" ]]; then
    usage
    exit 1
  fi
  phase="$3"
elif [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

plan_path="$1"
case "$phase" in
  in-review|approval) ;;
  *)
    echo "error: invalid phase: $phase (expected in-review or approval)" >&2
    exit 1
    ;;
esac

if [[ ! -f "$plan_path" ]]; then
  echo "error: plan not found: $plan_path" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
plan_path="$(cd "$(dirname "$plan_path")" && pwd)/$(basename "$plan_path")"

required_sections=(
  "## Status"
  "## Handoff Decision"
  "## Problem Statement"
  "## Definition of Done"
  "## Goals and Non-Goals"
  "## Model Specification Sources"
  "## Mathematical Sanity Checks"
  "## Solver Strategy Decision"
  "## Solver Translation Feasibility"
  "## Layer Contracts"
  "## Data Conversion and Copy Strategy"
  "## Validation Strategy"
  "## Testing and Verification Strategy"
  "## Risks and Open Questions"
  "## Acceptance Criteria"
)

missing_sections=()
for section in "${required_sections[@]}"; do
  if ! rg -Fq "$section" "$plan_path"; then
    missing_sections+=("$section")
  fi
done

if [[ ${#missing_sections[@]} -gt 0 ]]; then
  echo "error: missing required sections:" >&2
  for section in "${missing_sections[@]}"; do
    echo "  - $section" >&2
  done
  exit 1
fi

plan_file="$(basename "$plan_path")"
if [[ ! "$plan_file" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.+)\.md$ ]]; then
  echo "error: plan filename must match YYYY-MM-DD-<slug>.md" >&2
  exit 1
fi

date_part="${BASH_REMATCH[1]}"
slug_part="${BASH_REMATCH[2]}"
artifact_dir="${repo_root}/docs/design-plans/artifacts/${date_part}-${slug_part}"

required_artifacts=(
  "${artifact_dir}/model-symbol-table.md"
  "${artifact_dir}/equation-to-code-map.md"
  "${artifact_dir}/solver-feasibility-matrix.md"
)

missing_artifacts=()
for artifact in "${required_artifacts[@]}"; do
  if [[ ! -f "$artifact" ]]; then
    missing_artifacts+=("$artifact")
  fi
done

if [[ ${#missing_artifacts[@]} -gt 0 ]]; then
  echo "error: missing required artifact files:" >&2
  for artifact in "${missing_artifacts[@]}"; do
    echo "  - $artifact" >&2
  done
  exit 1
fi

placeholder_checks=(
  "Goal placeholder|^[[:space:]]*- Goal 1[[:space:]]*$"
  "Non-goal placeholder|^[[:space:]]*- Non-goal 1[[:space:]]*$"
  "Acceptance criteria placeholder|^[[:space:]]*1\\. AC1[[:space:]]*$"
  "Model source placeholder row|^[[:space:]]*\\| SRC-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Risk placeholder row|^[[:space:]]*\\| R1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Math summary placeholder|^[[:space:]]*- Summary:[[:space:]]*$"
  "Math blocking issues placeholder|^[[:space:]]*- Blocking issues:[[:space:]]*$"
  "Solver preference placeholder|^[[:space:]]*- User preference:[[:space:]]*$"
  "Solver chosen strategy placeholder|^[[:space:]]*- Chosen strategy:[[:space:]]*$"
  "Section contract placeholder|^[[:space:]]*- Contract:[[:space:]]*$"
  "TDD scope placeholder|^[[:space:]]*- TDD scope:[[:space:]]*$"
)

placeholder_hits=()
for check in "${placeholder_checks[@]}"; do
  label="${check%%|*}"
  pattern="${check#*|}"
  if rg -n -e "$pattern" "$plan_path" > /dev/null; then
    placeholder_hits+=("$label")
  fi
done

if [[ "$phase" == "approval" ]]; then
  if [[ ${#placeholder_hits[@]} -gt 0 ]]; then
    echo "error: plan contains unresolved placeholder content:" >&2
    for hit in "${placeholder_hits[@]}"; do
      echo "  - $hit" >&2
    done
    exit 1
  fi
else
  if [[ ${#placeholder_hits[@]} -gt 0 ]]; then
    echo "info: plan still contains placeholders (expected during in-review):"
    for hit in "${placeholder_hits[@]}"; do
      echo "  - $hit"
    done
  fi
fi

echo "Design plan readiness check passed."
echo "Plan: ${plan_path}"
echo "Artifact directory: ${artifact_dir}"
echo "Phase: ${phase}"
