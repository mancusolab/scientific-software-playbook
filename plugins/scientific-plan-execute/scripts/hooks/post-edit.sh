#!/usr/bin/env bash
set -euo pipefail

paths="${CLAUDE_FILE_PATHS:-}"

if [[ "$paths" == *"docs/design-plans/"* ]]; then
  echo "[scientific-software-playbook] Design artifacts changed. Re-check model path, solver strategy, simulation scope, and mathematical sanity checks." >&2
  echo "[scientific-software-playbook] If existing-codebase-port is selected, ensure codebase investigation findings are complete with file-level evidence." >&2
  echo "[scientific-software-playbook] Re-run validate-design-plan before approval." >&2
fi

if [[ "$paths" == *"docs/implementation-plans/"* ]]; then
  echo "[scientific-software-playbook] Implementation artifacts changed. Ensure source design path + model/solver/simulation decisions remain traceable." >&2
  echo "[scientific-software-playbook] Ensure simulation mappings/phases exist when in scope and AC-to-task-to-test traceability is complete." >&2
  echo "[scientific-software-playbook] Ensure selected architecture profile is documented and validation/conversion happens before numerics execution." >&2
fi
