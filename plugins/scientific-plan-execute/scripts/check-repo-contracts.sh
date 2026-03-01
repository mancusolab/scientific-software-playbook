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
[[ -f "LICENSE" ]] || fail "missing root LICENSE"
[[ -f "NOTICE" ]] || fail "missing root NOTICE"
[[ -f "LICENSE.superpowers" ]] || fail "missing root LICENSE.superpowers"

# AGENTS contract: global-install-only.
grep -Fq "supports one operational mode" AGENTS.md || fail "AGENTS.md missing single-mode contract text"
if grep -qi "Local repository mode" AGENTS.md; then
  fail "AGENTS.md still references local repository mode"
fi

# Runtime compatibility blocks are centrally managed and must remain synchronized.
[[ -f "docs/runtime-compatibility.md" ]] || fail "missing runtime compatibility source: docs/runtime-compatibility.md"
[[ -f "docs/installed-path-resolution.md" ]] || fail "missing installed path contract: docs/installed-path-resolution.md"
[[ -x "plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py" ]] \
  || fail "missing executable runtime compatibility sync script"
python3 "plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py" --check \
  || fail "runtime compatibility sections are out of sync"

# AGENTS skill path references must resolve.
while IFS= read -r skill_path; do
  [[ -n "$skill_path" ]] || continue
  [[ -f "$skill_path" ]] || fail "AGENTS skill path missing: $skill_path"
done < <(grep -oE 'plugins/[a-z0-9-]+/skills/[a-z0-9-]+/SKILL\.md' AGENTS.md | sort -u)

# Plugin manifest and hook paths must resolve.
[[ -f "plugins/scientific-plan-execute/.claude-plugin/plugin.json" ]] || fail "missing plan-execute plugin manifest"
[[ -f "plugins/scientific-research/.claude-plugin/plugin.json" ]] || fail "missing scientific-research plugin manifest"
[[ -f "plugins/scientific-house-style/.claude-plugin/plugin.json" ]] || fail "missing house-style plugin manifest"
[[ -f "plugins/scientific-plan-execute/LICENSE" ]] || fail "missing plan-execute LICENSE"
[[ -f "plugins/scientific-plan-execute/LICENSE.superpowers" ]] || fail "missing plan-execute LICENSE.superpowers"
[[ -f "plugins/scientific-research/LICENSE" ]] || fail "missing scientific-research LICENSE"
[[ -f "plugins/scientific-house-style/LICENSE" ]] || fail "missing house-style LICENSE"
[[ -f "plugins/scientific-plan-execute/hooks/hooks.json" ]] || fail "missing plan-execute hooks manifest"
[[ -f "plugins/scientific-research/skills/scientific-internet-research-pass/SKILL.md" ]] || fail "missing scientific research skill"
[[ -f "plugins/scientific-research/skills/scientific-codebase-investigation-pass/SKILL.md" ]] || fail "missing codebase research skill"
[[ ! -e "plugins/scientific-plan-execute/skills/scientific-internet-research-pass" ]] || fail "research skill must not live in plan-execute plugin"
python3 - <<'PY'
import json
import sys

with open("plugins/scientific-plan-execute/.claude-plugin/plugin.json", "r", encoding="utf-8") as fh:
    plan_manifest = json.load(fh)
with open("plugins/scientific-research/.claude-plugin/plugin.json", "r", encoding="utf-8") as fh:
    research_manifest = json.load(fh)
with open("plugins/scientific-house-style/.claude-plugin/plugin.json", "r", encoding="utf-8") as fh:
    house_manifest = json.load(fh)
with open(".claude-plugin/marketplace.json", "r", encoding="utf-8") as fh:
    marketplace = json.load(fh)

manifest_versions = {
    "scientific-plan-execute": plan_manifest.get("version"),
    "scientific-research": research_manifest.get("version"),
    "scientific-house-style": house_manifest.get("version"),
}
for name, version in manifest_versions.items():
    if not version:
        print(f"error: {name} plugin manifest missing version", file=sys.stderr)
        sys.exit(1)

marketplace_versions = {}
for plugin in marketplace.get("plugins", []):
    name = plugin.get("name")
    if name:
        marketplace_versions[name] = plugin.get("version")

for name, version in manifest_versions.items():
    market_version = marketplace_versions.get(name)
    if not market_version:
        print(f"error: marketplace missing {name} version entry", file=sys.stderr)
        sys.exit(1)
    if version != market_version:
        print(
            f"error: {name} version mismatch: manifest={version} marketplace={market_version}",
            file=sys.stderr,
        )
        sys.exit(1)

if manifest_versions["scientific-plan-execute"] != manifest_versions["scientific-house-style"]:
    print(
        "error: scientific-plan-execute and scientific-house-style versions must match "
        f"(found {manifest_versions['scientific-plan-execute']} vs "
        f"{manifest_versions['scientific-house-style']})",
        file=sys.stderr,
    )
    sys.exit(1)
PY
for research_agent in \
  "codebase-investigator" \
  "internet-researcher" \
  "remote-code-researcher" \
  "combined-researcher" \
  "scientific-literature-researcher"; do
  [[ -f "plugins/scientific-research/agents/${research_agent}.md" ]] || fail "missing scientific-research agent: ${research_agent}"
  grep -Fq "./agents/${research_agent}.md" "plugins/scientific-research/.claude-plugin/plugin.json" \
    || fail "scientific-research manifest missing agent entry: ${research_agent}"
done

# Plan-execute agents must reference skills by skill ID, not repo-local skill file paths.
if find "plugins/scientific-plan-execute/agents" -type f -name '*.md' -print0 | xargs -0 grep -nE 'skills/[a-z0-9-]+/SKILL\.md' >/dev/null 2>&1; then
  fail "plan-execute agents contain forbidden repo-local skill file references"
fi

# Shared runtime-path resolver must exist and be executable.
[[ -x "plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh" ]] \
  || fail "missing resolver utility: plugins/scientific-plan-execute/scripts/resolve-plugin-path.sh"
[[ -x "plugins/scientific-plan-execute/scripts/lib/runtime-paths.sh" ]] \
  || fail "missing resolver library: plugins/scientific-plan-execute/scripts/lib/runtime-paths.sh"
[[ -x "plugins/scientific-plan-execute/scripts/check-required-house-style-skills.sh" ]] \
  || fail "missing executable house-style dependency checker: plugins/scientific-plan-execute/scripts/check-required-house-style-skills.sh"
[[ -x "plugins/scientific-plan-execute/scripts/run-required-house-style-preflight.sh" ]] \
  || fail "missing executable house-style preflight wrapper: plugins/scientific-plan-execute/scripts/run-required-house-style-preflight.sh"
grep -Fq "depends on scientific-house-style; adding scientific-house-style automatically." "scripts/install-codex-home.sh" \
  || fail "installer must auto-add scientific-house-style when scientific-plan-execute is selected"

# Skills must resolve utility scripts through shared resolver.
for skill_file in \
  "plugins/scientific-plan-execute/skills/new-design-plan/SKILL.md" \
  "plugins/scientific-plan-execute/skills/validate-design-plan/SKILL.md" \
  "plugins/scientific-plan-execute/skills/set-design-plan-status/SKILL.md"; do
  grep -Fq 'scripts/resolve-plugin-path.sh' "$skill_file" \
    || fail "skill missing shared resolver path contract: $skill_file"
  grep -Fq -- '--plan-execute-script' "$skill_file" \
    || fail "skill missing resolver usage contract: $skill_file"
  grep -Fq 'do not use repository-local `scripts/...` paths.' "$skill_file" \
    || fail "skill missing repository-local script prohibition: $skill_file"
  if grep -Fq 'SCRIPT_PATH="scripts/' "$skill_file"; then
    fail "skill contains forbidden local script path: $skill_file"
  fi
done

grep -Fq -- '--plan-execute-script "new-design-plan.sh"' \
  "plugins/scientific-plan-execute/skills/new-design-plan/SKILL.md" \
  || fail "new-design-plan skill missing resolver call for new-design-plan.sh"
grep -Fq -- '--plan-execute-script "validate-design-plan-readiness.sh"' \
  "plugins/scientific-plan-execute/skills/validate-design-plan/SKILL.md" \
  || fail "validate-design-plan skill missing resolver call for validate-design-plan-readiness.sh"
grep -Fq -- '--plan-execute-script "set-design-plan-status.sh"' \
  "plugins/scientific-plan-execute/skills/set-design-plan-status/SKILL.md" \
  || fail "set-design-plan-status skill missing resolver call for set-design-plan-status.sh"

echo "repo_contracts_ok"
