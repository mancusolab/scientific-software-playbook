#!/usr/bin/env bash
set -euo pipefail

changed_plan_files="$(git diff --name-only -- docs/design-plans docs/implementation-plans 2>/dev/null || true)"

if [[ -n "$changed_plan_files" ]]; then
  echo "[scientific-software-playbook] Plan artifacts changed in this session. Run readiness checks before merge." >&2
fi
