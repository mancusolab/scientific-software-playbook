#!/usr/bin/env bash

ssp_valid_plugins() {
  cat <<'EOF'
scientific-plan-execute
scientific-research
scientific-house-style
scientific-agent-tools
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
polars-data-engineering
functional-core-imperative-shell
property-based-testing
python-module-design
writing-for-a-technical-audience
writing-good-tests
EOF
      ;;
    scientific-agent-tools)
      cat <<'EOF'
creating-a-plugin
creating-an-agent
maintaining-project-context
testing-skills-with-subagents
writing-claude-directives
writing-claude-md-files
writing-skills
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
    scientific-agent-tools)
      cat <<'EOF'
.claude-plugin/plugin.json
agents
skills
docs
LICENSE
LICENSE.ed3d
EOF
      ;;
    *)
      return 1
      ;;
  esac
}
