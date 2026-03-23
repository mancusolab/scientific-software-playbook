#!/usr/bin/env bash
# Check that all plugin versions are consistent and valid semver.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

TMPFILE=/tmp/plugin-versions-$$

cleanup() {
  rm -f $TMPFILE
}

trap cleanup EXIT

errors=0

check_semver() {
  local version=$1
  local name=$2
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: $name has invalid semver: $version" >&2
    errors=$((errors + 1))
  fi
}

# Extract versions from all plugin manifests
for manifest in $(find $repo_root/plugins -name "plugin.json" -type f); do
  plugin_name=$(basename $(dirname $(dirname $manifest)))
  version=$(python3 -c "import json; print(json.load(open('$manifest'))['version'])")
  echo "$plugin_name=$version" >> $TMPFILE
  check_semver $version $plugin_name
done

# Extract marketplace versions
marketplace="${repo_root}/.claude-plugin/marketplace.json"
if [ -f "$marketplace" ]; then
  python3 -c "
import json
data = json.load(open('$marketplace'))
for p in data.get('plugins', []):
    print(f\"{p['name']}={p['version']}\")
" >> $TMPFILE
fi

# Check all versions match
versions=$(cat $TMPFILE | cut -d= -f2 | sort -u)
count=$(echo "$versions" | wc -l | tr -d ' ')

if [ "$count" -ne 1 ]; then
  echo "error: version mismatch detected:" >&2
  cat $TMPFILE | sort >&2
  errors=$((errors + 1))
fi

if [ $errors -gt 0 ]; then
  echo "FAIL: $errors version errors found" >&2
  exit 1
fi

echo "OK: all plugin versions consistent ($(head -1 $TMPFILE | cut -d= -f2))"
