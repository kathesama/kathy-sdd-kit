#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

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

info "OK: PR content is consistent with local SDD evidence"
info "Ticket: $ticket"
info "PR content: $pr_path"
