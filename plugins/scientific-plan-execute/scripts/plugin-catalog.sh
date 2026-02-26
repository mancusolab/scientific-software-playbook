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
asking-clarifying-questions
brainstorming
using-plan-and-execute
scientific-kickoff
starting-a-design-plan
new-design-plan
validate-design-plan
set-design-plan-status
writing-design-plans
starting-an-implementation-plan
writing-implementation-plans
executing-an-implementation-plan
simulation-for-inference-validation
validation-first-pipeline-api
requesting-code-review
verification-before-completion
systematic-debugging
test-driven-development
using-git-worktrees
finishing-a-development-branch
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
jax-project-engineering
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
