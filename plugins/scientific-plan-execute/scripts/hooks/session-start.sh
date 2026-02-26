#!/usr/bin/env bash
set -euo pipefail

echo "[scientific-software-playbook] Internal hooks active (agent-invoked scripts only)." >&2
echo "[scientific-software-playbook] Gate check: select and record model path (provided-model vs suggested-model vs existing-codebase-port)." >&2
echo "[scientific-software-playbook] Gate check: if existing-codebase-port, run scientific-codebase-investigation-pass and record file-level findings." >&2
echo "[scientific-software-playbook] Gate check: record solver strategy (custom updates vs existing solver path, e.g. Optimistix)." >&2
echo "[scientific-software-playbook] Gate check: select architecture profile (compact-workflow vs modular-domain) and enforce validation/conversion before numerics." >&2
