#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

require_file() {
  path=$1
  label=$2
  [ -f "$path" ] || fail "missing $label: $path"
}

require_text() {
  path=$1
  text=$2
  grep -Fq -- "$text" "$path" || fail "$path must contain: $text"
}

validate_rule_pack() {
  path=$1
  require_file "$path" "engineering rule pack"

  for heading in \
    "## When to use" \
    "## Primary bias to correct" \
    "## Decision rules" \
    "## Trigger rules" \
    "## Final checklist" \
    "## Enforcement Contract" \
    "## Source and Attribution"
  do
    require_text "$path" "$heading"
  done

  contract_rows=$(awk '
    $0 == "## Enforcement Contract" { in_contract = 1; next }
    in_contract && /^## / { exit }
    in_contract && /^\|/ { print }
  ' "$path" | awk 'NR > 2 { print }')
  [ -n "$contract_rows" ] || fail "$path must contain Enforcement Contract rows"

  invalid_contract=$(printf '%s\n' "$contract_rows" | awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      check_id = trim($2)
      required = trim($3)
      keywords = trim($4)
      applies_to = trim($5)
      if (check_id !~ /^[A-Z]+-[0-9][0-9]$/) {
        print check_id ": invalid Check ID"
      }
      if (required == "" || keywords == "" || applies_to == "") {
        print check_id ": empty contract cell"
      }
      if (keywords !~ /,/) {
        print check_id ": Evidence Keywords must be comma-separated"
      }
    }
  ')
  [ -z "$invalid_contract" ] || fail "invalid Enforcement Contract in $path:
$invalid_contract"

  if grep -Eq 'TODO|TBD|fill in|placeholder' "$path"; then
    fail "$path contains placeholder text"
  fi
}

validate_skill() {
  path=$1
  expected_name=$2
  require_file "$path" "skill"
  require_text "$path" "---"
  require_text "$path" "name: $expected_name"
  require_text "$path" "description:"

  if grep -Eq 'TODO|TBD|fill in|placeholder' "$path"; then
    fail "$path contains placeholder text"
  fi
}

validate_rule_pack "ai-specs/rules/engineering/clean-architecture.mini.md"
validate_rule_pack "ai-specs/rules/engineering/domain-driven-design.mini.md"
validate_rule_pack "ai-specs/rules/engineering/patterns-of-enterprise-application-architecture.mini.md"
validate_rule_pack "ai-specs/rules/engineering/refactoring.mini.md"
validate_rule_pack "ai-specs/rules/engineering/release-it.mini.md"
validate_rule_pack "ai-specs/rules/engineering/data-intensive.mini.md"

require_file "ai-specs/rules/engineering/README.md" "engineering rules README"
require_text "ai-specs/rules/engineering/README.md" "select-engineering-rules"
require_text "ai-specs/rules/engineering/README.md" "agent-rules-books"

require_file "ai-specs/specs/agent-behavior-standards.mdc" "agent behavior standards"
require_text "ai-specs/specs/agent-behavior-standards.mdc" "## Required Agent Behavior"
require_text "ai-specs/specs/agent-behavior-standards.mdc" "## Verification Discipline"

validate_skill "ai-specs/skills/select-engineering-rules/SKILL.md" "select-engineering-rules"
validate_skill "ai-specs/skills/agent-work-discipline/SKILL.md" "agent-work-discipline"

require_text "AGENTS.md" "agent-behavior-standards.mdc"
require_text "CLAUDE.md" "agent-behavior-standards.mdc"
require_text "CODEX.md" "agent-behavior-standards.mdc"
require_text "README.md" "ai-specs/rules/engineering/"
require_file ".cursor/rules/agent-behavior-standards.mdc" "Cursor agent behavior rule"
require_text ".cursor/rules/agent-behavior-standards.mdc" "alwaysApply: true"

info "OK: engineering rule packs and agent behavior standards are present"
