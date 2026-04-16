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

section_rows() {
  file_path=$1
  section=$2
  awk -v section="$section" '
    $0 == "## " section { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && /^\|/ { print }
  ' "$file_path" | awk 'NR > 2 { print }'
}

section_text() {
  file_path=$1
  section=$2
  awk -v section="$section" '
    $0 == "## " section { in_section = 1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$file_path"
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
  awk -F'|' -v section="$section" -v file_path="$file_path" '
    {
      ac_id = $2
      gsub(/^[ \t]+|[ \t]+$/, "", ac_id)
      if (ac_id == "") {
        next
      }
      if (ac_id !~ /^AC-[0-9][0-9]+$/) {
        printf "section \"%s\" contains invalid AC ID \"%s\" in %s\n", section, ac_id, file_path > "/dev/stderr"
        bad = 1
        next
      }
      print ac_id
    }
    END { exit bad }
  ' "$rows_file"
  status=$?
  rm -f "$rows_file"
  [ "$status" -eq 0 ] || fail "invalid acceptance criteria table in section \"$section\""
}

contains_line() {
  needle=$1
  file_path=$2
  grep -Fxq "$needle" "$file_path"
}

ensure_section_exists() {
  file_path=$1
  section=$2
  grep -Fq "## $section" "$file_path" || fail "missing required section \"$section\" in $file_path"
}

ensure_unique_ids() {
  ids_file=$1
  duplicates=$(sort "$ids_file" | uniq -d)
  [ -z "$duplicates" ] || fail "duplicate acceptance criteria IDs found:
$duplicates"
}

ensure_coverage() {
  canonical_file=$1
  other_file=$2
  section=$3
  missing=$(while IFS= read -r ac_id; do
    [ -n "$ac_id" ] || continue
    if ! contains_line "$ac_id" "$other_file"; then
      printf '%s\n' "$ac_id"
    fi
  done < "$canonical_file")
  [ -z "$missing" ] || fail "missing acceptance criteria in $section:
$missing"
}

validate_completion_statuses() {
  file_path=$1
  invalid=$(section_rows "$file_path" "Completion Evidence" | awk -F'|' '{
    ac = $2
    status = $3
    gsub(/^[ \t]+|[ \t]+$/, "", ac)
    gsub(/^[ \t]+|[ \t]+$/, "", status)
    if (status != "Covered" && status != "Partial" && status != "Not Covered") {
      print ac ": " (status == "" ? "<empty>" : status)
    }
  }')
  [ -z "$invalid" ] || fail "invalid Completion Evidence statuses in $file_path:
$invalid"
}

validate_delivery_plan_refs() {
  file_path=$1
  canonical_file=$2
  delivery=$(section_text "$file_path" "Delivery Plan")
  [ -n "$delivery" ] || fail "Delivery Plan is empty in $file_path"
  missing=$(while IFS= read -r ac_id; do
    [ -n "$ac_id" ] || continue
    printf '%s\n' "$delivery" | grep -Fq "$ac_id" || printf '%s\n' "$ac_id"
  done < "$canonical_file")
  [ -z "$missing" ] || fail "missing acceptance criteria references in Delivery Plan:
$missing"
}

validate_spec_file() {
  file_path=$1
  out_file=$2
  [ -f "$file_path" ] || fail "required implementation spec file not found: $file_path"

  for section in "Related Work Items" "Acceptance Criteria" "Implementation Mapping" "Validation Plan" "Delivery Plan" "Completion Evidence"; do
    ensure_section_exists "$file_path" "$section"
  done

  ac_ids_for_section "$file_path" "Acceptance Criteria" > "$out_file"
  ensure_unique_ids "$out_file"
  mapping_file=$(mktemp)
  validation_file=$(mktemp)
  completion_file=$(mktemp)
  ac_ids_for_section "$file_path" "Implementation Mapping" > "$mapping_file"
  ac_ids_for_section "$file_path" "Validation Plan" > "$validation_file"
  ac_ids_for_section "$file_path" "Completion Evidence" > "$completion_file"

  ensure_coverage "$out_file" "$mapping_file" "Implementation Mapping"
  ensure_coverage "$out_file" "$validation_file" "Validation Plan"
  ensure_coverage "$out_file" "$completion_file" "Completion Evidence"
  validate_completion_statuses "$file_path"
  validate_delivery_plan_refs "$file_path" "$out_file"

  rm -f "$mapping_file" "$validation_file" "$completion_file"
}

resolve_paths() {
  input=${1:-}
  repo_root=$(pwd)
  if [ -z "$input" ]; then
    input=$(extract_ticket_from_branch "$(current_branch)")
  fi
  [ -n "$input" ] || fail "usage: validate-impl-spec.sh <ticket-key-or-impl-plan-path>"

  if [ -f "$input" ]; then
    primary_path=$input
    file_name=$(basename "$primary_path")
    ticket=$(printf '%s\n' "$file_name" | sed -n 's/^\([A-Za-z0-9][A-Za-z0-9._-]*\)-impl-\(backend\|frontend\)\.md$/\1/p')
    [ -n "$ticket" ] || fail "input file must be named {TICKET}-impl-backend.md or {TICKET}-impl-frontend.md: $primary_path"
    validate_ticket "$ticket"
    ticket_dir=$(dirname "$primary_path")
  else
    ticket=$input
    validate_ticket "$ticket"
    ticket_dir="$repo_root/.ai-specs/changes/$ticket"
    [ -d "$ticket_dir" ] || fail "ticket workspace not found: $ticket_dir"
    backend_path="$ticket_dir/$ticket-impl-backend.md"
    frontend_path="$ticket_dir/$ticket-impl-frontend.md"
    backend_exists=0
    frontend_exists=0
    [ -f "$backend_path" ] && backend_exists=1
    [ -f "$frontend_path" ] && frontend_exists=1
    if [ "$backend_exists" -eq 1 ] && [ "$frontend_exists" -eq 1 ]; then
      fail "multiple implementation plans found for $ticket. Pass the exact file path instead"
    fi
    if [ "$backend_exists" -eq 1 ]; then
      primary_path=$backend_path
    elif [ "$frontend_exists" -eq 1 ]; then
      primary_path=$frontend_path
    else
      fail "no implementation plan found in $ticket_dir. Expected $ticket-impl-backend.md or $ticket-impl-frontend.md"
    fi
  fi

  implementation_spec_path="$ticket_dir/$ticket-implementation-spec.md"
}

input=${1:-}
resolve_paths "$input"

primary_ids=$(mktemp)
companion_ids=$(mktemp)
trap 'rm -f "$primary_ids" "$companion_ids"' EXIT HUP INT TERM

validate_spec_file "$primary_path" "$primary_ids"
validate_spec_file "$implementation_spec_path" "$companion_ids"

missing_in_companion=$(while IFS= read -r ac_id; do
  [ -n "$ac_id" ] || continue
  if ! contains_line "$ac_id" "$companion_ids"; then
    printf '%s\n' "$ac_id"
  fi
done < "$primary_ids")

missing_in_primary=$(while IFS= read -r ac_id; do
  [ -n "$ac_id" ] || continue
  if ! contains_line "$ac_id" "$primary_ids"; then
    printf '%s\n' "$ac_id"
  fi
done < "$companion_ids")

if [ -n "$missing_in_companion" ] || [ -n "$missing_in_primary" ]; then
  fail "acceptance criteria mismatch between implementation plan and implementation spec"
fi

criteria_count=$(wc -l < "$primary_ids" | tr -d ' ')
info "OK: implementation plan and companion spec are structurally complete"
info "Ticket: $ticket"
info "Plan: $primary_path"
info "Implementation spec: $implementation_spec_path"
info "Acceptance criteria checked: $criteria_count"
