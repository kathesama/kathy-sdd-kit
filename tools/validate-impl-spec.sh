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

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
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

validate_completion_evidence() {
  file_path=$1
  invalid=$(section_rows "$file_path" "Completion Evidence" | awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      ac = trim($2)
      status = trim($3)
      evidence = trim($4)
      normalized = tolower(evidence)
      if (evidence == "") {
        print ac ": empty evidence"
      } else if (status == "Covered" && normalized ~ /^(done|implemented|complete|completed|covered|n\/a|-|tbd|todo|pending)$/) {
        print ac ": weak covered evidence: " evidence
      } else if ((status == "Partial" || status == "Not Covered") && normalized !~ /(block|decision|out of scope|follow[- ]?up|pending implementation|pending approval|not started|planned)/) {
        print ac ": missing blocker or decision evidence: " evidence
      }
    }
  ')
  [ -z "$invalid" ] || fail "invalid Completion Evidence details in $file_path:
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

expected_engineering_rule_packs() {
  cat <<'EOF'
clean-architecture.mini.md
domain-driven-design.mini.md
patterns-of-enterprise-application-architecture.mini.md
refactoring.mini.md
release-it.mini.md
data-intensive.mini.md
EOF
}

engineering_rule_pack_rows() {
  file_path=$1
  section_text "$file_path" "Execution Notes for Implementer" | awk '
    $0 == "### Engineering Rule Packs" { in_table = 1; next }
    in_table && /^### / { exit }
    in_table && /^\|/ { print }
  ' | awk 'NR > 2 { print }'
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

validate_engineering_rule_packs() {
  file_path=$1
  rows_file=$(mktemp)
  engineering_rule_pack_rows "$file_path" > "$rows_file"
  [ -s "$rows_file" ] || {
    rm -f "$rows_file"
    fail "Execution Notes for Implementer must contain an Engineering Rule Packs table in $file_path"
  }

  row_packs=$(mktemp)
  expected_packs=$(mktemp)
  expected_engineering_rule_packs > "$expected_packs"

  awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      pack = trim($2)
      if (pack != "") {
        print pack
      }
    }
  ' "$rows_file" > "$row_packs"

  missing=$(while IFS= read -r pack; do
    [ -n "$pack" ] || continue
    if ! contains_line "$pack" "$row_packs"; then
      printf '%s\n' "$pack"
    fi
  done < "$expected_packs")
  [ -z "$missing" ] || {
    rm -f "$rows_file" "$row_packs" "$expected_packs"
    fail "Engineering Rule Packs table is missing required packs in $file_path:
$missing"
  }

  unexpected=$(while IFS= read -r pack; do
    [ -n "$pack" ] || continue
    if ! contains_line "$pack" "$expected_packs"; then
      printf '%s\n' "$pack"
    fi
  done < "$row_packs")
  [ -z "$unexpected" ] || {
    rm -f "$rows_file" "$row_packs" "$expected_packs"
    fail "Engineering Rule Packs table contains unknown packs in $file_path:
$unexpected"
  }

  duplicates=$(sort "$row_packs" | uniq -d)
  [ -z "$duplicates" ] || {
    rm -f "$rows_file" "$row_packs" "$expected_packs"
    fail "Engineering Rule Packs table contains duplicate packs in $file_path:
$duplicates"
  }

  invalid=$(awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      pack = trim($2)
      selection = trim($3)
      reason = trim($4)
      impact = trim($5)
      normalized_reason = tolower(reason)
      normalized_impact = tolower(impact)
      if (pack == "") {
        next
      }
      if (selection != "Selected" && selection != "Not selected") {
        print pack ": invalid Selection \"" selection "\""
      }
      if (reason == "" || reason == "-" || normalized_reason == "n/a") {
        print pack ": missing selection reason"
      }
      if (selection == "Selected" && (impact == "" || impact == "-" || normalized_impact == "n/a")) {
        print pack ": selected pack requires validation impact"
      }
    }
  ' "$rows_file")
  [ -z "$invalid" ] || {
    rm -f "$rows_file" "$row_packs" "$expected_packs"
    fail "invalid Engineering Rule Packs table in $file_path:
$invalid"
  }

  plan_text=$(mktemp)
  {
    section_text "$file_path" "Implementation Mapping"
    section_text "$file_path" "Validation Plan"
    section_text "$file_path" "Delivery Plan"
  } > "$plan_text"

  missing_selected_refs=$(selected_engineering_rule_packs "$file_path" | while IFS= read -r pack; do
    [ -n "$pack" ] || continue
    if ! grep -Fq "$pack" "$plan_text"; then
      printf '%s\n' "$pack"
    fi
  done)
  rm -f "$rows_file" "$row_packs" "$expected_packs" "$plan_text"
  [ -z "$missing_selected_refs" ] || fail "selected Engineering Rule Packs must be referenced in Implementation Mapping, Validation Plan, or Delivery Plan in $file_path:
$missing_selected_refs"
}

validate_related_work_items() {
  file_path=$1
  canonical_ticket=$2
  section_file=$(mktemp)
  section_rows "$file_path" "Related Work Items" > "$section_file"
  [ -s "$section_file" ] || {
    rm -f "$section_file"
    fail "Related Work Items must contain at least one row in $file_path"
  }

  parent_found=$(awk -F'|' -v ticket="$canonical_ticket" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    trim($2) == ticket { found = 1 }
    END { print found ? "yes" : "no" }
  ' "$section_file")
  [ "$parent_found" = "yes" ] || {
    rm -f "$section_file"
    fail "Related Work Items must include parent ticket $canonical_ticket in $file_path"
  }

  invalid_scope=$(awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      key = trim($2)
      scope = trim($5)
      if (key == "") {
        print "<empty key>: empty key"
      } else if (scope == "Needs clarification") {
        print key ": Needs clarification must be resolved before validation"
      } else if (scope != "In scope" && scope != "Out of scope" && scope != "No implementation impact" && scope != "Blocked") {
        print key ": invalid Scope Decision \"" scope "\""
      }
    }
  ' "$section_file")
  [ -z "$invalid_scope" ] || {
    rm -f "$section_file"
    fail "invalid Related Work Items scope decisions in $file_path:
$invalid_scope"
  }

  plan_text=$(mktemp)
  {
    section_text "$file_path" "Acceptance Criteria"
    section_text "$file_path" "Implementation Mapping"
    section_text "$file_path" "Validation Plan"
    section_text "$file_path" "Delivery Plan"
  } > "$plan_text"

  missing_in_scope=$(awk -F'|' -v ticket="$canonical_ticket" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    {
      key = trim($2)
      scope = trim($5)
      if (key != "" && key != ticket && scope == "In scope") {
        print key
      }
    }
  ' "$section_file" | while IFS= read -r related_key; do
    [ -n "$related_key" ] || continue
    if ! grep -Fq "$related_key" "$plan_text"; then
      printf '%s\n' "$related_key"
    fi
  done)

  rm -f "$section_file" "$plan_text"
  [ -z "$missing_in_scope" ] || fail "in-scope Related Work Items missing from ACs, mapping, validation, or delivery plan in $file_path:
$missing_in_scope"
}

validate_spec_file() {
  file_path=$1
  out_file=$2
  canonical_ticket=$3
  [ -f "$file_path" ] || fail "required implementation spec file not found: $file_path"

  for section in "Related Work Items" "Acceptance Criteria" "Implementation Mapping" "Validation Plan" "Delivery Plan" "Execution Notes for Implementer" "Completion Evidence"; do
    ensure_section_exists "$file_path" "$section"
  done

  validate_related_work_items "$file_path" "$canonical_ticket"
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
  validate_completion_evidence "$file_path"
  validate_delivery_plan_refs "$file_path" "$out_file"
  validate_engineering_rule_packs "$file_path"

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

validate_spec_file "$primary_path" "$primary_ids" "$ticket"
validate_spec_file "$implementation_spec_path" "$companion_ids" "$ticket"

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

primary_selected=$(mktemp)
companion_selected=$(mktemp)
selected_engineering_rule_packs "$primary_path" | sort > "$primary_selected"
selected_engineering_rule_packs "$implementation_spec_path" | sort > "$companion_selected"
if ! cmp -s "$primary_selected" "$companion_selected"; then
  rm -f "$primary_selected" "$companion_selected"
  fail "selected Engineering Rule Packs mismatch between implementation plan and implementation spec"
fi
rm -f "$primary_selected" "$companion_selected"

criteria_count=$(wc -l < "$primary_ids" | tr -d ' ')
info "OK: implementation plan and companion spec are structurally complete"
info "Ticket: $ticket"
info "Plan: $primary_path"
info "Implementation spec: $implementation_spec_path"
info "Acceptance criteria checked: $criteria_count"
