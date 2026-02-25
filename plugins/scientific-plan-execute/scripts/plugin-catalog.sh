#!/usr/bin/env bash

ssp_valid_plugins() {
  cat <<'EOF'
scientific-plan-execute
scientific-research
scientific-house-style
EOF
}

ssp_plugin_skills() {
  local plugin="$1"
  case "$plugin" in
    scientific-plan-execute)
      cat <<'EOF'
new-design-plan
validate-design-plan
set-design-plan-status
start-scientific-implementation-plan
execute-scientific-implementation-plan
scientific-software-architecture
simulation-for-inference-validation
validation-first-pipeline-api
scientific-cli-thin-shell
EOF
      ;;
    scientific-research)
      cat <<'EOF'
scientific-internet-research-pass
scientific-codebase-investigation-pass
EOF
      ;;
    scientific-house-style)
      cat <<'EOF'
jax-equinox-numerics
project-engineering
coding-effectively
howto-functional-vs-imperative
property-based-testing
writing-for-a-technical-audience
writing-good-tests
EOF
      ;;
    *)
      return 1
      ;;
  esac
}

ssp_plugin_required_paths() {
  local plugin="$1"
  case "$plugin" in
    scientific-plan-execute)
      cat <<'EOF'
.claude-plugin/plugin.json
agents
commands
hooks
scripts
docs/design-plans/templates
docs/implementation-plans/templates
docs/reviews/review-template.md
docs/checklists/skill-agent-io-checklist.md
EOF
      ;;
    scientific-research)
      cat <<'EOF'
.claude-plugin/plugin.json
agents
skills
docs
EOF
      ;;
    scientific-house-style)
      cat <<'EOF'
.claude-plugin/plugin.json
skills
docs
EOF
      ;;
    *)
      return 1
      ;;
  esac
}
