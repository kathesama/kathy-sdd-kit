#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

extract_ticket_from_branch() {
  printf '%s\n' "$1" | sed -n 's/.*\([A-Za-z][A-Za-z0-9._-]*-[0-9][0-9]*\).*/\1/p' | head -n 1
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

resolve_path() {
  input=${1:-}
  repo_root=$(pwd)
  if [ -z "$input" ]; then
    input=$(extract_ticket_from_branch "$(current_branch)")
  fi
  [ -n "$input" ] || fail "usage: validate-changelog.sh <ticket-key-or-changelog-path>"

  if [ -f "$input" ]; then
    changelog_path=$input
    file_name=$(basename "$changelog_path")
    ticket=$(printf '%s\n' "$file_name" | sed -n 's/^\([A-Za-z0-9][A-Za-z0-9._-]*\)-CHANGELOG\.md$/\1/p')
    [ -n "$ticket" ] || fail "input file must be named {TICKET}-CHANGELOG.md: $changelog_path"
    validate_ticket "$ticket"
  else
    ticket=$input
    validate_ticket "$ticket"
    changelog_path="$repo_root/.ai-specs/changes/$ticket/$ticket-CHANGELOG.md"
  fi

  [ -f "$changelog_path" ] || fail "required changelog file not found: $changelog_path"
}

validate_header() {
  first_line=$(sed -n '1p' "$changelog_path" | sed 's/^\xef\xbb\xbf//')
  printf '%s\n' "$first_line" | grep -Eq "^# $ticket([[:space:]].*)?$" || fail "first heading must start with \"# $ticket\" in $changelog_path"
}

validate_sections() {
  sections_file=$(mktemp)
  body_file=$(mktemp)
  trap 'rm -f "$sections_file" "$body_file"' EXIT HUP INT TERM

  grep -n '^## ' "$changelog_path" > "$sections_file" || true
  [ -s "$sections_file" ] || fail "changelog must contain at least one subtask section starting with ## in $changelog_path"

  while IFS=: read -r start_line heading; do
    next_line=$(awk -F: -v start="$start_line" '$1 > start { print $1; exit }' "$sections_file")
    if [ -n "$next_line" ]; then
      end_line=$((next_line - 1))
      sed -n "${start_line},${end_line}p" "$changelog_path" > "$body_file"
    else
      sed -n "${start_line},\$p" "$changelog_path" > "$body_file"
    fi

    printf '%s\n' "$heading" | grep -Eq "^## [A-Za-z0-9._-]+: .+" || fail "invalid changelog section heading at line $start_line: $heading"

    for required in "**Status:** " "**Commit message:** " "### Files created" "### Files modified" "### Summary" "### Notes" "---"; do
      grep -Fq -- "$required" "$body_file" || fail "section \"$heading\" missing required line \"$required\""
    done

    status_line=$(grep -F "**Status:** " "$body_file" | head -n 1)
    status_value=$(printf '%s\n' "$status_line" | sed 's/^\*\*Status:\*\*[[:space:]]*//')
    case "$status_value" in
      Done|Partial|Blocked|Not\ Started)
        ;;
      *)
        fail "section \"$heading\" has invalid Status \"$status_value\". Use Done, Partial, Blocked, or Not Started"
        ;;
    esac

    for forbidden in "### Key Planning Decisions" "### Changes by Component" "### Acceptance Criteria Mapping" "### Next Steps" "## Acceptance Criteria Coverage" "## Validation Evidence"; do
      if grep -Fq -- "$forbidden" "$body_file"; then
        fail "section \"$heading\" contains forbidden planning/report section \"$forbidden\""
      fi
    done
  done < "$sections_file"
}

input=${1:-}
resolve_path "$input"
validate_header
validate_sections

info "OK: changelog structure is valid"
info "Ticket: $ticket"
info "Changelog: $changelog_path"
