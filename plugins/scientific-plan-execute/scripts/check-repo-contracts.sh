#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../.." && pwd)"
cd "$repo_root"

fail() {
  echo "error: $1" >&2
  exit 1
}

# Broken compatibility links/wrappers must stay removed.
for path in \
  "agents" \
  "commands" \
  "hooks" \
  "skills" \
  "scripts/bootstrap-scientific-software-playbook.sh" \
  "scripts/new-design-plan.sh" \
  "scripts/set-design-plan-status.sh" \
  "scripts/validate-design-plan-readiness.sh" \
  "scripts/hooks"; do
  [[ ! -e "$path" ]] || fail "forbidden compatibility path exists: $path"
done

# One user-facing installer entrypoint only.
[[ -x "scripts/install-codex-home.sh" ]] || fail "missing executable installer: scripts/install-codex-home.sh"
[[ ! -e "plugins/scientific-plan-execute/scripts/install-codex-home.sh" ]] || fail "forbidden plugin-local installer exists"

# Root manifest contract.
[[ -f ".claude-plugin/marketplace.json" ]] || fail "missing marketplace manifest"
[[ ! -e ".claude-plugin/plugin.json" ]] || fail "forbidden legacy plugin manifest exists"

# AGENTS contract: global-install-only.
grep -Fq "supports one operational mode" AGENTS.md || fail "AGENTS.md missing single-mode contract text"
if grep -qi "Local repository mode" AGENTS.md; then
  fail "AGENTS.md still references local repository mode"
fi

# AGENTS skill path references must resolve.
while IFS= read -r skill_path; do
  [[ -n "$skill_path" ]] || continue
  [[ -f "$skill_path" ]] || fail "AGENTS skill path missing: $skill_path"
done < <(grep -oE 'plugins/[a-z0-9-]+/skills/[a-z0-9-]+/SKILL\.md' AGENTS.md | sort -u)

# Plugin manifest and hook paths must resolve.
[[ -f "plugins/scientific-plan-execute/.claude-plugin/plugin.json" ]] || fail "missing plan-execute plugin manifest"
[[ -f "plugins/scientific-house-style/.claude-plugin/plugin.json" ]] || fail "missing house-style plugin manifest"
[[ -f "plugins/scientific-plan-execute/hooks/hooks.json" ]] || fail "missing plan-execute hooks manifest"

# Skills must resolve script paths from installed plugin location only.
for skill_file in \
  "plugins/scientific-plan-execute/skills/new-design-plan/SKILL.md" \
  "plugins/scientific-plan-execute/skills/validate-design-plan/SKILL.md" \
  "plugins/scientific-plan-execute/skills/set-design-plan-status/SKILL.md"; do
  grep -Fq '$CODEX_ROOT/scientific-software-playbook/plugins/scientific-plan-execute/scripts/' "$skill_file" \
    || fail "skill missing plugin-script path contract: $skill_file"
  if grep -Fq 'SCRIPT_PATH="scripts/' "$skill_file"; then
    fail "skill contains forbidden local script path: $skill_file"
  fi
done

echo "repo_contracts_ok"
