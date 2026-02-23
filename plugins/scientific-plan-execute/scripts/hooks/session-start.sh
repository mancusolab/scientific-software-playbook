#!/usr/bin/env bash
set -euo pipefail

echo "[scientific-software-playbook] Internal hooks active (agent-invoked scripts only)." >&2
echo "[scientific-software-playbook] Gate check: select and record model path (provided-model vs suggested-model)." >&2
echo "[scientific-software-playbook] Gate check: record solver strategy (custom updates vs existing solver path, e.g. Optimistix)." >&2
echo "[scientific-software-playbook] Gate check: enforce ingress->canonical JAX conversion and validation-first pipeline before numerics." >&2
