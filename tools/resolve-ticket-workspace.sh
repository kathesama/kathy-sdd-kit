#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
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

ticket_input=${1:-}
repo_root=$(pwd)
branch_name=$(current_branch)

if [ -n "$ticket_input" ]; then
  ticket=$ticket_input
else
  ticket=$(extract_ticket_from_branch "$branch_name")
fi

[ -n "$ticket" ] || fail "could not resolve ticket key from input or current branch"
validate_ticket "$ticket"

ticket_dir="$repo_root/.ai-specs/changes/$ticket"
enriched_path="$ticket_dir/$ticket-enriched.md"
impl_backend_path="$ticket_dir/$ticket-impl-backend.md"
impl_frontend_path="$ticket_dir/$ticket-impl-frontend.md"
implementation_spec_path="$ticket_dir/$ticket-implementation-spec.md"
changelog_path="$ticket_dir/$ticket-CHANGELOG.md"
pr_path="$ticket_dir/PR-$ticket.md"

existing_files=""
for file_path in \
  "$enriched_path" \
  "$impl_backend_path" \
  "$impl_frontend_path" \
  "$implementation_spec_path" \
  "$changelog_path" \
  "$pr_path"
do
  if [ -f "$file_path" ]; then
    if [ -n "$existing_files" ]; then
      existing_files="$existing_files,"
    fi
    existing_files="$existing_files
    \"$(json_escape "$file_path")\""
  fi
done

if [ -n "$branch_name" ]; then
  branch_json="\"$(json_escape "$branch_name")\""
else
  branch_json="null"
fi

cat <<EOF
{
  "repoRoot": "$(json_escape "$repo_root")",
  "ticket": "$(json_escape "$ticket")",
  "ticketDir": "$(json_escape "$ticket_dir")",
  "enrichedPath": "$(json_escape "$enriched_path")",
  "implBackendPath": "$(json_escape "$impl_backend_path")",
  "implFrontendPath": "$(json_escape "$impl_frontend_path")",
  "implementationSpecPath": "$(json_escape "$implementation_spec_path")",
  "changelogPath": "$(json_escape "$changelog_path")",
  "prPath": "$(json_escape "$pr_path")",
  "existingFiles": [${existing_files}
  ],
  "branchName": $branch_json
}
EOF
