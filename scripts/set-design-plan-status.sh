#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/set-design-plan-status.sh <plan-path> <draft|in-review|approved-for-implementation>
EOF
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

plan_path="$1"
status_token="$2"

if [[ ! -f "$plan_path" ]]; then
  echo "error: plan not found: $plan_path" >&2
  exit 1
fi

to_status() {
  case "$1" in
    draft) echo "Draft" ;;
    in-review) echo "In Review" ;;
    approved-for-implementation) echo "Approved for Implementation" ;;
    *) return 1 ;;
  esac
}

if ! new_status="$(to_status "$status_token")"; then
  echo "error: invalid status token: $status_token" >&2
  usage
  exit 1
fi

current_status="$(awk '
  /^## Status$/ { in_status = 1; next }
  in_status && NF { print; exit }
' "$plan_path")"

if [[ -z "$current_status" ]]; then
  echo "error: could not locate current status under \"## Status\" in $plan_path" >&2
  exit 1
fi

if [[ "$current_status" == "$new_status" ]]; then
  echo "No change: status already \"$current_status\""
  exit 0
fi

is_valid_transition() {
  local from="$1"
  local to="$2"
  case "$from|$to" in
    "Draft|In Review") return 0 ;;
    "In Review|Draft") return 0 ;;
    "In Review|Approved for Implementation") return 0 ;;
    "Approved for Implementation|In Review") return 0 ;;
    *) return 1 ;;
  esac
}

if ! is_valid_transition "$current_status" "$new_status"; then
  echo "error: invalid status transition: \"$current_status\" -> \"$new_status\"" >&2
  echo "allowed transitions:" >&2
  echo "  Draft -> In Review" >&2
  echo "  In Review -> Draft" >&2
  echo "  In Review -> Approved for Implementation" >&2
  echo "  Approved for Implementation -> In Review" >&2
  exit 1
fi

# Hard stop before approval: plan must pass readiness validation.
if [[ "$new_status" == "Approved for Implementation" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "${script_dir}/validate-design-plan-readiness.sh" "$plan_path" --phase approval
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

awk -v new_status="$new_status" '
  BEGIN { in_status = 0; replaced = 0 }
  {
    if ($0 == "## Status") {
      print
      in_status = 1
      next
    }
    if (in_status && !replaced) {
      if ($0 ~ /^[[:space:]]*$/) {
        print
        next
      }
      print new_status
      replaced = 1
      in_status = 0
      next
    }
    print
  }
  END {
    if (!replaced) {
      exit 2
    }
  }
' "$plan_path" > "$tmp_file"

mv "$tmp_file" "$plan_path"

echo "Updated status: \"$current_status\" -> \"$new_status\""
