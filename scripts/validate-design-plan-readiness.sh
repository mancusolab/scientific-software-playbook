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
  "## Model Acquisition Path"
  "## Model Specification Sources"
  "## Model Option Analysis (Required When \`suggested-model\`)"
  "## External Research Findings (When Triggered)"
  "## Mathematical Sanity Checks"
  "## Solver Strategy Decision"
  "## Solver Translation Feasibility"
  "## Layer Contracts"
  "## Data Conversion and Copy Strategy"
  "## Validation Strategy"
  "## Testing and Verification Strategy"
  "## Simulation And Inference-Consistency Validation"
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

model_path=""
if rg -n -e '^[[:space:]]*-[[:space:]]*Path:[[:space:]]*`provided-model`' "$plan_path" > /dev/null; then
  model_path="provided-model"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*Path:[[:space:]]*`suggested-model`' "$plan_path" > /dev/null; then
  if [[ -n "$model_path" ]]; then
    echo "error: model acquisition path is ambiguous (both provided-model and suggested-model detected)" >&2
    exit 1
  fi
  model_path="suggested-model"
fi

if [[ -z "$model_path" ]]; then
  echo "error: model acquisition path must be explicit: \`provided-model\` or \`suggested-model\`" >&2
  exit 1
fi

simulation_scope=""
if rg -n -e '^[[:space:]]*-[[:space:]]*In scope:[[:space:]]*yes[[:space:]]*$' "$plan_path" > /dev/null; then
  simulation_scope="yes"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*In scope:[[:space:]]*no[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$simulation_scope" ]]; then
    echo "error: simulation scope is ambiguous (both yes and no detected)" >&2
    exit 1
  fi
  simulation_scope="no"
fi

if [[ -z "$simulation_scope" ]]; then
  echo "error: simulation scope must be explicit in Simulation And Inference-Consistency Validation section (yes or no)" >&2
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
  "Model acquisition path placeholder|^[[:space:]]*-[[:space:]]*Path:[[:space:]]*\\`provided-model\\` \\| \\`suggested-model\\`[[:space:]]*$"
  "Model selection confirmation placeholder|^[[:space:]]*-[[:space:]]*User selection confirmation:[[:space:]]*$"
  "Simulation scope placeholder|^[[:space:]]*-[[:space:]]*In scope:[[:space:]]*yes\\|no[[:space:]]*$"
  "Model source placeholder row|^[[:space:]]*\\| SRC-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Model option placeholder row|^[[:space:]]*\\| MOD-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\| selected/rejected \\|[[:space:]]*$"
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

if [[ "$phase" == "approval" && "$model_path" == "suggested-model" ]]; then
  suggested_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*MOD-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$suggested_rows" ]]; then
    echo "error: suggested-model path requires populated model candidate rows (MOD-*) in Model Option Analysis" >&2
    exit 1
  fi

  has_selected_with_citation=0
  while IFS='|' read -r _ col_candidate _ _ _ _ col_citation col_status _; do
    candidate="$(echo "$col_candidate" | xargs)"
    citation="$(echo "$col_citation" | xargs)"
    status="$(echo "$col_status" | xargs)"
    if [[ "$candidate" == MOD-* && "$status" == "selected" && -n "$citation" ]]; then
      has_selected_with_citation=1
      break
    fi
  done <<< "$suggested_rows"

  if [[ "$has_selected_with_citation" -ne 1 ]]; then
    echo "error: suggested-model path requires at least one selected model row with non-empty supporting citation(s)" >&2
    exit 1
  fi
fi

if [[ "$phase" == "approval" && "$model_path" == "provided-model" ]]; then
  source_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*SRC-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$source_rows" ]]; then
    echo "error: provided-model path requires at least one populated model source row (SRC-*) in Model Specification Sources" >&2
    exit 1
  fi

  has_populated_source=0
  while IFS='|' read -r _ col_source_id col_path col_type _ _ _; do
    source_id="$(echo "$col_source_id" | xargs)"
    source_path="$(echo "$col_path" | xargs)"
    source_type="$(echo "$col_type" | xargs)"
    if [[ "$source_id" == SRC-* && -n "$source_path" && -n "$source_type" ]]; then
      has_populated_source=1
      break
    fi
  done <<< "$source_rows"

  if [[ "$has_populated_source" -ne 1 ]]; then
    echo "error: provided-model path requires at least one model source row with non-empty path/link and type" >&2
    exit 1
  fi
fi

if [[ "$phase" == "approval" && "$simulation_scope" == "yes" ]]; then
  if rg -n -e '^[[:space:]]*-[[:space:]]*Simulate entrypoint/signature:[[:space:]]*$' "$plan_path" > /dev/null; then
    echo "error: simulation scope is yes but simulate entrypoint/signature is empty" >&2
    exit 1
  fi

  experiment_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*SIM-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$experiment_rows" ]]; then
    echo "error: simulation scope is yes but no simulation experiment rows (SIM-*) were provided" >&2
    exit 1
  fi

  has_populated_experiment=0
  while IFS='|' read -r _ col_id col_type col_success _; do
    row_id="$(echo "$col_id" | xargs)"
    row_type="$(echo "$col_type" | xargs)"
    row_success="$(echo "$col_success" | xargs)"
    if [[ "$row_id" == SIM-* && -n "$row_type" && -n "$row_success" ]]; then
      has_populated_experiment=1
      break
    fi
  done <<< "$experiment_rows"

  if [[ "$has_populated_experiment" -ne 1 ]]; then
    echo "error: simulation scope is yes but simulation experiments are placeholders (type/success criterion missing)" >&2
    exit 1
  fi
fi

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
