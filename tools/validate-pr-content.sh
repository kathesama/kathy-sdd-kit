#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
kit_root=$(dirname "$script_dir")

validate_ticket() {
  ticket=$1
  case "$ticket" in
    ""|*/*|*\\*|*" "*|*..*)
      fail "invalid ticket key \"$ticket\""
      ;;
  esac
  printf '%s\n' "$ticket" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$' || fail "invalid ticket key \"$ticket\""
}

section_rows() {
  file_path=$1
  section=$2
  awk -v section="$section" '
    $0 == "## " section { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && /^\|/ { print }
  ' "$file_path" | awk 'NR > 2 { print }'
}

ac_ids_for_section() {
  file_path=$1
  section=$2
  rows_file=$(mktemp)
  section_rows "$file_path" "$section" > "$rows_file"
  [ -s "$rows_file" ] || {
    rm -f "$rows_file"
    fail "section \"$section\" does not contain a valid markdown table in $file_path"
  }
  awk -F'|' '
    {
      ac_id = $2
      gsub(/^[ \t]+|[ \t]+$/, "", ac_id)
      if (ac_id ~ /^AC-[0-9][0-9]+$/) {
        print ac_id
      }
    }
  ' "$rows_file"
  rm -f "$rows_file"
}

completion_problem_statuses() {
  file_path=$1
  section_rows "$file_path" "Completion Evidence" | awk -F'|' '
    {
      ac = $2
      status = $3
      gsub(/^[ \t]+|[ \t]+$/, "", ac)
      gsub(/^[ \t]+|[ \t]+$/, "", status)
      if (status == "Partial" || status == "Not Covered" || status == "Blocked") {
        print ac ":" status
      }
    }
  '
}

engineering_rule_pack_rows() {
  file_path=$1
  awk '
    $0 == "## Engineering Rule Packs" || $0 == "### Engineering Rule Packs" { in_table = 1; next }
    in_table && /^## / { exit }
    in_table && /^### / { exit }
    in_table && /^\|/ { print }
  ' "$file_path" | awk 'NR > 2 { print }'
}

selected_engineering_rule_packs() {
  file_path=$1
  engineering_rule_pack_rows "$file_path" | awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      pack = trim($2)
      selection = trim($3)
      if (selection == "Selected") {
        print pack
      }
    }
  '
}

split_obligations() {
  printf '%s\n' "$1" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed '/^$/d'
}

active_engineering_obligations() {
  file_path=$1
  engineering_rule_pack_rows "$file_path" | while IFS= read -r row; do
    pack=$(printf '%s\n' "$row" | awk -F'|' '{ value=$2; gsub(/^[ \t]+|[ \t]+$/, "", value); print value }')
    selection=$(printf '%s\n' "$row" | awk -F'|' '{ value=$3; gsub(/^[ \t]+|[ \t]+$/, "", value); print value }')
    active=$(printf '%s\n' "$row" | awk -F'|' '{ value=$5; gsub(/^[ \t]+|[ \t]+$/, "", value); print value }')
    [ "$selection" = "Selected" ] || continue
    split_obligations "$active" | while IFS= read -r obligation; do
      [ -n "$obligation" ] || continue
      printf '%s|%s\n' "$pack" "$obligation"
    done
  done
}

obligation_keyword_regex() {
  pack=$1
  obligation=$2
  contract_path="$kit_root/ai-specs/rules/engineering/$pack"
  [ -f "$contract_path" ] || fail "engineering rule pack contract not found: $contract_path"
  keywords=$(awk -v obligation="$obligation" '
    $0 == "## Enforcement Contract" { in_contract = 1; next }
    in_contract && /^## / { exit }
    in_contract && /^\|/ { print }
  ' "$contract_path" | awk 'NR > 2 { print }' | awk -F'|' -v obligation="$obligation" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    trim($2) == obligation {
      print trim($4)
    }
  ')
  [ -n "$keywords" ] || fail "active obligation $obligation not found in $contract_path"
  printf '%s\n' "$keywords" | awk -F',' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      for (idx = 1; idx <= NF; idx++) {
        keyword = trim($idx)
        if (keyword != "") {
          print keyword
        }
      }
    }
  ' | paste -sd'|' -
}

resolve_paths() {
  input=${1:-}
  [ -n "$input" ] || fail "usage: validate-pr-content.sh <ticket-key-or-pr-path>"

  if [ -f "$input" ]; then
    pr_path=$input
    file_name=$(basename "$pr_path")
    ticket=$(printf '%s\n' "$file_name" | sed -n 's/^PR-\([A-Za-z0-9][A-Za-z0-9._-]*\)\.md$/\1/p')
    [ -n "$ticket" ] || fail "input file must be named PR-{TICKET}.md: $pr_path"
    validate_ticket "$ticket"
    ticket_dir=$(dirname "$pr_path")
  else
    ticket=$input
    validate_ticket "$ticket"
    ticket_dir="$(pwd)/.ai-specs/changes/$ticket"
    pr_path="$ticket_dir/PR-$ticket.md"
  fi

  changelog_path="$ticket_dir/$ticket-CHANGELOG.md"
  implementation_spec_path="$ticket_dir/$ticket-implementation-spec.md"
  qa_path="$ticket_dir/QA-$ticket.md"
  review_path="$ticket_dir/REVIEW-$ticket.md"
}

require_file() {
  path=$1
  label=$2
  [ -f "$path" ] || fail "required $label not found: $path"
}

evidence_contains() {
  needle=$1
  grep -Fq "$needle" "$changelog_path" ||
    grep -Fq "$needle" "$qa_path" ||
    grep -Fq "$needle" "$review_path" ||
    grep -Fq "$needle" "$implementation_spec_path"
}

validate_no_mojibake() {
  bad=$(grep -nE 'â|Ã|�' "$pr_path" || true)
  [ -z "$bad" ] || fail "PR content contains mojibake:
$bad"
}

validate_ac_coverage() {
  ids_file=$(mktemp)
  ac_ids_for_section "$implementation_spec_path" "Acceptance Criteria" > "$ids_file"
  [ -s "$ids_file" ] || {
    rm -f "$ids_file"
    fail "no acceptance criteria found in implementation spec"
  }
  missing=$(while IFS= read -r ac_id; do
    [ -n "$ac_id" ] || continue
    if ! grep -Fq "$ac_id" "$pr_path"; then
      printf '%s\n' "$ac_id"
    fi
  done < "$ids_file")
  rm -f "$ids_file"
  [ -z "$missing" ] || fail "PR content is missing acceptance criteria:
$missing"
}

validate_problem_status_visibility() {
  problems=$(completion_problem_statuses "$implementation_spec_path")
  [ -z "$problems" ] && return 0
  missing=$(printf '%s\n' "$problems" | while IFS=: read -r ac_id status; do
    [ -n "$ac_id" ] || continue
    if ! grep -Fq "$ac_id" "$pr_path" || ! grep -Fq "$status" "$pr_path"; then
      printf '%s %s\n' "$ac_id" "$status"
    fi
  done)
  [ -z "$missing" ] || fail "PR content hides partial/not covered/blocked AC statuses:
$missing"
}

validate_checked_commands_have_evidence() {
  checked_commands=$(awk '
    /\[x\]/ && /`/ {
      line = $0
      while (match(line, /`[^`]+`/)) {
        command = substr(line, RSTART + 1, RLENGTH - 2)
        print command
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$pr_path")

  missing=$(printf '%s\n' "$checked_commands" | while IFS= read -r command; do
    [ -n "$command" ] || continue
    if ! evidence_contains "$command"; then
      printf '%s\n' "$command"
    fi
  done)
  [ -z "$missing" ] || fail "checked PR commands lack matching local evidence:
$missing"
}

validate_ci_not_invented() {
  checked_ci=$(awk '
    /^### CI/ { in_ci = 1; next }
    /^## / || /^### / { if (in_ci) exit }
    in_ci && /\[x\]/ { print }
  ' "$pr_path")
  [ -z "$checked_ci" ] && return 0
  if grep -Eiq 'github actions|ci .*passed|ci logs|workflow run|actions run' "$changelog_path" "$qa_path" "$review_path" "$implementation_spec_path"; then
    return 0
  fi
  fail "checked CI items require explicit CI evidence:
$checked_ci"
}

validate_key_commits() {
  key_commits=$(awk '
    /^- Key commits:/ { in_commits = 1; next }
    in_commits && /^## / { exit }
    in_commits && /^- / { print }
  ' "$pr_path")
  [ -z "$key_commits" ] && return 0
  if printf '%s\n' "$key_commits" | grep -Eq '[0-9a-f]{7,40}'; then
    return 0
  fi
  fail "Key commits contains entries without commit hashes; use suggested commit messages or N/A:
$key_commits"
}

validate_referenced_files_exist() {
  missing=$(awk '
    /^### Files created/ || /^### Files modified/ { in_files = 1; next }
    /^### Files deleted/ || /^## / { in_files = 0 }
    in_files && /^- `[^`]+`/ {
      line = $0
      sub(/^- `/, "", line)
      sub(/`.*/, "", line)
      print line
    }
  ' "$pr_path" | while IFS= read -r file_path; do
    [ -n "$file_path" ] || continue
    case "$file_path" in
      *"*"*|http://*|https://*)
        continue
        ;;
    esac
    [ -e "$file_path" ] || printf '%s\n' "$file_path"
  done)
  [ -z "$missing" ] || fail "PR content references files that do not exist:
$missing"
}

validate_qa_review_status() {
  if grep -Eiq 'Status:\*\* *(Fail|Blocked)|Verdict[[:space:]]*$[[:space:]]*(Fail|Blocked)' "$qa_path"; then
    fail "QA report is not passing: $qa_path"
  fi
  if grep -Eiq 'Status:\*\* *(Request changes|Not ready)|Verdict[[:space:]]*$[[:space:]]*(Request changes|Not ready)' "$review_path"; then
    fail "Review report is not ready: $review_path"
  fi
}

validate_engineering_rule_pack_traceability() {
  rows_file=$(mktemp)
  engineering_rule_pack_rows "$implementation_spec_path" > "$rows_file"
  [ -s "$rows_file" ] || {
    rm -f "$rows_file"
    fail "implementation spec must contain an Engineering Rule Packs table: $implementation_spec_path"
  }
  rm -f "$rows_file"

  selected=$(selected_engineering_rule_packs "$implementation_spec_path")
  [ -n "$selected" ] || return 0

  missing=$(printf '%s\n' "$selected" | while IFS= read -r pack; do
    [ -n "$pack" ] || continue
    grep -Fq "$pack" "$qa_path" || printf '%s missing from QA report\n' "$pack"
    grep -Fq "$pack" "$review_path" || printf '%s missing from review report\n' "$pack"
    grep -Fq "$pack" "$pr_path" || printf '%s missing from PR content\n' "$pack"
  done)
  [ -z "$missing" ] || fail "selected Engineering Rule Packs must be traceable through QA, review, and PR content:
$missing"

  weak=$(printf '%s\n' "$selected" | while IFS= read -r pack; do
    [ -n "$pack" ] || continue
    if ! grep -Fq "$pack" "$implementation_spec_path"; then
      printf '%s missing from implementation spec\n' "$pack"
    fi
  done)
  [ -z "$weak" ] || fail "selected Engineering Rule Packs lack risk or validation evidence:
$weak"

  obligation_gaps=$(active_engineering_obligations "$implementation_spec_path" | while IFS='|' read -r pack obligation; do
    [ -n "$obligation" ] || continue
    grep -Fq "$obligation" "$qa_path" || printf '%s %s missing from QA report\n' "$pack" "$obligation"
    grep -Fq "$obligation" "$review_path" || printf '%s %s missing from review report\n' "$pack" "$obligation"
    grep -Fq "$obligation" "$pr_path" || printf '%s %s missing from PR content\n' "$pack" "$obligation"
    regex=$(obligation_keyword_regex "$pack" "$obligation")
    if ! grep -Eiq "$regex" "$qa_path" "$review_path" "$pr_path"; then
      printf '%s %s lacks matching contract evidence keywords\n' "$pack" "$obligation"
    fi
  done)
  [ -z "$obligation_gaps" ] || fail "active Engineering Rule Pack obligations must be evidenced in QA, review, and PR content:
$obligation_gaps"
}

input=${1:-}
resolve_paths "$input"

require_file "$pr_path" "PR content"
require_file "$changelog_path" "changelog"
require_file "$implementation_spec_path" "implementation spec"
require_file "$qa_path" "QA report"
require_file "$review_path" "review report"

validate_no_mojibake
validate_ac_coverage
validate_problem_status_visibility
validate_checked_commands_have_evidence
validate_ci_not_invented
validate_key_commits
validate_referenced_files_exist
validate_qa_review_status
validate_engineering_rule_pack_traceability

info "OK: PR content is consistent with local SDD evidence"
info "Ticket: $ticket"
info "PR content: $pr_path"
