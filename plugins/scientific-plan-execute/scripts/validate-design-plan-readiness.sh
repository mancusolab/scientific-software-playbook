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

plan_path="$(cd "$(dirname "$plan_path")" && pwd)/$(basename "$plan_path")"

required_sections=(
  "## Status"
  "## Handoff Decision"
  "## Problem Statement"
  "## Definition of Done"
  "## Goals and Non-Goals"
  "## Model Acquisition Path"
  "## Required Workflow States"
  "## Model Specification Sources"
  "## Model Option Analysis (Required When \`suggested-model\`)"
  "## Existing Codebase Port Contract (Required When \`existing-codebase-port\`)"
  "## Codebase Investigation Findings (Required When \`existing-codebase-port\`)"
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
    echo "error: model acquisition path is ambiguous (multiple paths detected)" >&2
    exit 1
  fi
  model_path="suggested-model"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*Path:[[:space:]]*`existing-codebase-port`' "$plan_path" > /dev/null; then
  if [[ -n "$model_path" ]]; then
    echo "error: model acquisition path is ambiguous (multiple paths detected)" >&2
    exit 1
  fi
  model_path="existing-codebase-port"
fi

if [[ -z "$model_path" ]]; then
  echo "error: model acquisition path must be explicit: \`provided-model\`, \`suggested-model\`, or \`existing-codebase-port\`" >&2
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

workflow_model_state=""
if rg -n -e '^[[:space:]]*-[[:space:]]*model_path_decided:[[:space:]]*yes[[:space:]]*$' "$plan_path" > /dev/null; then
  workflow_model_state="yes"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*model_path_decided:[[:space:]]*no[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$workflow_model_state" ]]; then
    echo "error: required workflow state model_path_decided is ambiguous (multiple values detected)" >&2
    exit 1
  fi
  workflow_model_state="no"
fi
if [[ -z "$workflow_model_state" ]]; then
  echo "error: required workflow state model_path_decided must be explicit (yes or no)" >&2
  exit 1
fi

workflow_port_state=""
if rg -n -e '^[[:space:]]*-[[:space:]]*codebase_investigation_complete_if_port:[[:space:]]*yes[[:space:]]*$' "$plan_path" > /dev/null; then
  workflow_port_state="yes"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*codebase_investigation_complete_if_port:[[:space:]]*no[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$workflow_port_state" ]]; then
    echo "error: required workflow state codebase_investigation_complete_if_port is ambiguous (multiple values detected)" >&2
    exit 1
  fi
  workflow_port_state="no"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*codebase_investigation_complete_if_port:[[:space:]]*n/a[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$workflow_port_state" ]]; then
    echo "error: required workflow state codebase_investigation_complete_if_port is ambiguous (multiple values detected)" >&2
    exit 1
  fi
  workflow_port_state="n/a"
fi
if [[ -z "$workflow_port_state" ]]; then
  echo "error: required workflow state codebase_investigation_complete_if_port must be explicit (yes, no, or n/a)" >&2
  exit 1
fi

workflow_simulation_state=""
if rg -n -e '^[[:space:]]*-[[:space:]]*simulation_contract_complete_if_in_scope:[[:space:]]*yes[[:space:]]*$' "$plan_path" > /dev/null; then
  workflow_simulation_state="yes"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*simulation_contract_complete_if_in_scope:[[:space:]]*no[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$workflow_simulation_state" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope is ambiguous (multiple values detected)" >&2
    exit 1
  fi
  workflow_simulation_state="no"
fi
if rg -n -e '^[[:space:]]*-[[:space:]]*simulation_contract_complete_if_in_scope:[[:space:]]*n/a[[:space:]]*$' "$plan_path" > /dev/null; then
  if [[ -n "$workflow_simulation_state" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope is ambiguous (multiple values detected)" >&2
    exit 1
  fi
  workflow_simulation_state="n/a"
fi
if [[ -z "$workflow_simulation_state" ]]; then
  echo "error: required workflow state simulation_contract_complete_if_in_scope must be explicit (yes, no, or n/a)" >&2
  exit 1
fi

plan_file="$(basename "$plan_path")"
if [[ ! "$plan_file" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.+)\.md$ ]]; then
  echo "error: plan filename must match YYYY-MM-DD-<slug>.md" >&2
  exit 1
fi

date_part="${BASH_REMATCH[1]}"
slug_part="${BASH_REMATCH[2]}"
plan_dir="$(cd "$(dirname "$plan_path")" && pwd)"
artifact_dir="${plan_dir}/artifacts/${date_part}-${slug_part}"

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
  "Model acquisition path placeholder|^[[:space:]]*-[[:space:]]*Path:[[:space:]]*\`provided-model\` \\| \`suggested-model\` \\| \`existing-codebase-port\`[[:space:]]*$"
  "Workflow model path state placeholder|^[[:space:]]*-[[:space:]]*model_path_decided:[[:space:]]*yes\\|no[[:space:]]*$"
  "Workflow port investigation state placeholder|^[[:space:]]*-[[:space:]]*codebase_investigation_complete_if_port:[[:space:]]*yes\\|no\\|n/a[[:space:]]*$"
  "Workflow simulation contract state placeholder|^[[:space:]]*-[[:space:]]*simulation_contract_complete_if_in_scope:[[:space:]]*yes\\|no\\|n/a[[:space:]]*$"
  "Model selection confirmation placeholder|^[[:space:]]*-[[:space:]]*User selection confirmation:[[:space:]]*$"
  "Port source selection placeholder|^[[:space:]]*-[[:space:]]*Source selection confirmation:[[:space:]]*$"
  "Port investigation mode placeholder|^[[:space:]]*-[[:space:]]*Investigation mode:[[:space:]]*\`local-directory\` \\| \`github-url\`[[:space:]]*$"
  "Port investigation completion placeholder|^[[:space:]]*-[[:space:]]*Investigation completion:[[:space:]]*yes\\|no[[:space:]]*$"
  "Simulation scope placeholder|^[[:space:]]*-[[:space:]]*In scope:[[:space:]]*yes\\|no[[:space:]]*$"
  "Model source placeholder row|^[[:space:]]*\\| SRC-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Model option placeholder row|^[[:space:]]*\\| MOD-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\| selected/rejected \\|[[:space:]]*$"
  "Port source placeholder row|^[[:space:]]*\\| PORT-SRC-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Port behavior placeholder row|^[[:space:]]*\\| PORT-BHV-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*$"
  "Port investigation placeholder row|^[[:space:]]*\\| PORT-INV-1 \\|[[:space:]]*\\|[[:space:]]*\\|[[:space:]]*\\| confirmed \\|[[:space:]]*$"
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
  if [[ "$workflow_model_state" != "yes" ]]; then
    echo "error: required workflow state model_path_decided must be yes for approval" >&2
    exit 1
  fi
  if [[ "$workflow_port_state" != "n/a" ]]; then
    echo "error: required workflow state codebase_investigation_complete_if_port must be n/a when model path is not existing-codebase-port" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "yes" && "$workflow_simulation_state" != "yes" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be yes when simulation scope is yes" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "no" && "$workflow_simulation_state" != "n/a" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be n/a when simulation scope is no" >&2
    exit 1
  fi

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
  if [[ "$workflow_model_state" != "yes" ]]; then
    echo "error: required workflow state model_path_decided must be yes for approval" >&2
    exit 1
  fi
  if [[ "$workflow_port_state" != "n/a" ]]; then
    echo "error: required workflow state codebase_investigation_complete_if_port must be n/a when model path is not existing-codebase-port" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "yes" && "$workflow_simulation_state" != "yes" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be yes when simulation scope is yes" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "no" && "$workflow_simulation_state" != "n/a" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be n/a when simulation scope is no" >&2
    exit 1
  fi

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

if [[ "$phase" == "approval" && "$model_path" == "existing-codebase-port" ]]; then
  if [[ "$workflow_model_state" != "yes" ]]; then
    echo "error: required workflow state model_path_decided must be yes for approval" >&2
    exit 1
  fi
  if [[ "$workflow_port_state" != "yes" ]]; then
    echo "error: required workflow state codebase_investigation_complete_if_port must be yes when model path is existing-codebase-port" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "yes" && "$workflow_simulation_state" != "yes" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be yes when simulation scope is yes" >&2
    exit 1
  fi
  if [[ "$simulation_scope" == "no" && "$workflow_simulation_state" != "n/a" ]]; then
    echo "error: required workflow state simulation_contract_complete_if_in_scope must be n/a when simulation scope is no" >&2
    exit 1
  fi

  port_source_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*PORT-SRC-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$port_source_rows" ]]; then
    echo "error: existing-codebase-port path requires at least one source pin row (PORT-SRC-*) in Existing Codebase Port Contract" >&2
    exit 1
  fi

  has_populated_port_source=0
  while IFS='|' read -r _ col_source_id col_source_type col_source_path col_source_pin _; do
    source_id="$(echo "$col_source_id" | xargs)"
    source_type="$(echo "$col_source_type" | xargs)"
    source_path="$(echo "$col_source_path" | xargs)"
    source_pin="$(echo "$col_source_pin" | xargs)"

    if [[ "$source_id" != PORT-SRC-* || -z "$source_type" || -z "$source_path" || -z "$source_pin" ]]; then
      continue
    fi

    if [[ "$source_type" != "local-directory" && "$source_type" != "github-url" ]]; then
      continue
    fi

    if [[ "$source_type" == "local-directory" && "$source_path" != /* ]]; then
      continue
    fi

    if [[ "$source_type" == "github-url" ]]; then
      if [[ ! "$source_path" =~ ^https?://github\.com/ ]] && [[ ! "$source_path" =~ ^git@github\.com: ]]; then
        continue
      fi
    fi

    has_populated_port_source=1
    break
  done <<< "$port_source_rows"

  if [[ "$has_populated_port_source" -ne 1 ]]; then
    echo "error: existing-codebase-port path requires one source pin row with source type (\`local-directory\` or \`github-url\`), valid source locator, and commit/tag" >&2
    exit 1
  fi

  port_behavior_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*PORT-BHV-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$port_behavior_rows" ]]; then
    echo "error: existing-codebase-port path requires at least one behavior inventory row (PORT-BHV-*) in Existing Codebase Port Contract" >&2
    exit 1
  fi

  has_populated_port_behavior=0
  while IFS='|' read -r _ col_behavior_id col_surface col_current col_target col_evidence _; do
    behavior_id="$(echo "$col_behavior_id" | xargs)"
    surface="$(echo "$col_surface" | xargs)"
    current_behavior="$(echo "$col_current" | xargs)"
    target_behavior="$(echo "$col_target" | xargs)"
    evidence_plan="$(echo "$col_evidence" | xargs)"

    if [[ "$behavior_id" == PORT-BHV-* && -n "$surface" && -n "$current_behavior" && -n "$target_behavior" && -n "$evidence_plan" ]]; then
      has_populated_port_behavior=1
      break
    fi
  done <<< "$port_behavior_rows"

  if [[ "$has_populated_port_behavior" -ne 1 ]]; then
    echo "error: existing-codebase-port path requires one populated behavior inventory row with surface, current behavior, target behavior, and evidence plan" >&2
    exit 1
  fi

  if ! rg -n -e '^[[:space:]]*-[[:space:]]*Investigation completion:[[:space:]]*yes[[:space:]]*$' "$plan_path" > /dev/null; then
    echo "error: existing-codebase-port path requires codebase investigation completion set to yes" >&2
    exit 1
  fi

  if ! rg -Fq -- '- Investigator: `scientific-codebase-investigation-pass`' "$plan_path"; then
    echo "error: existing-codebase-port path requires investigator to be \`scientific-codebase-investigation-pass\`" >&2
    exit 1
  fi

  port_investigation_rows="$(awk -F'|' '/^[[:space:]]*\|[[:space:]]*PORT-INV-[^|]*\|/ {print}' "$plan_path")"
  if [[ -z "$port_investigation_rows" ]]; then
    echo "error: existing-codebase-port path requires at least one investigation findings row (PORT-INV-*) in Codebase Investigation Findings" >&2
    exit 1
  fi

  has_populated_port_investigation=0
  while IFS='|' read -r _ col_finding_id col_scope col_summary col_evidence col_status _; do
    finding_id="$(echo "$col_finding_id" | xargs)"
    source_scope="$(echo "$col_scope" | xargs)"
    summary="$(echo "$col_summary" | xargs)"
    evidence="$(echo "$col_evidence" | xargs)"
    status="$(echo "$col_status" | xargs)"

    if [[ "$finding_id" != PORT-INV-* || -z "$source_scope" || -z "$summary" || -z "$evidence" ]]; then
      continue
    fi

    if [[ "$status" != "confirmed" && "$status" != "discrepancy" && "$status" != "addition" && "$status" != "missing" ]]; then
      continue
    fi

    has_populated_port_investigation=1
    break
  done <<< "$port_investigation_rows"

  if [[ "$has_populated_port_investigation" -ne 1 ]]; then
    echo "error: existing-codebase-port path requires one populated investigation row with scope, summary, evidence, and valid status" >&2
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
