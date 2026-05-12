#!/usr/bin/env sh
set -eu

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

usage() {
  cat <<'USAGE'
usage: sync-agent-skills.sh [--write|--check]

Exposes kathy-sdd-kit SDD skills from ai-specs/skills into tool-specific skill
directories without creating editable duplicate sources.

Targets:
  .agents/skills  Codex
  .claude/skills  Claude Code
  .cursor/skills  Cursor

Run from the consuming repository root:
  sh .sdd-kit/tools/sync-agent-skills.sh --write

Run inside the kit repository itself:
  sh tools/sync-agent-skills.sh --write
USAGE
}

mode=${1:---write}
case "$mode" in
  --write|--check)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    fail "unknown mode: $mode"
    ;;
esac

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
kit_root=$(dirname "$script_dir")
source_dir="$kit_root/ai-specs/skills"
target_root=$(pwd)
target_dirs=".agents/skills .claude/skills .cursor/skills"

[ -d "$source_dir" ] || fail "source skills directory not found: $source_dir"

physical_dir() {
  path=$1
  [ -d "$path" ] || return 1
  CDPATH= cd "$path" && pwd -P
}

same_dir() {
  left=$1
  right=$2
  left_physical=$(physical_dir "$left") || return 1
  right_physical=$(physical_dir "$right") || return 1
  [ "$left_physical" = "$right_physical" ]
}

same_skill_content() {
  source_skill=$1
  target_skill=$2
  [ -f "$target_skill/SKILL.md" ] || return 1
  cmp -s "$source_skill/SKILL.md" "$target_skill/SKILL.md"
}

remove_existing_target() {
  target_skill=$1
  case "$target_skill" in
    "$target_root"/.agents/skills/*|"$target_root"/.claude/skills/*|"$target_root"/.cursor/skills/*)
      rm -rf "$target_skill"
      ;;
    *)
      fail "refusing to remove unexpected path: $target_skill"
      ;;
  esac
}

create_dir_link() {
  source_skill=$1
  target_skill=$2
  target_parent=$(dirname "$target_skill")
  mkdir -p "$target_parent"

  if command -v cygpath >/dev/null 2>&1 && command -v cmd.exe >/dev/null 2>&1; then
    source_win=$(cygpath -w "$source_skill")
    target_win=$(cygpath -w "$target_skill")
    cmd.exe //c mklink //J "$target_win" "$source_win" >/dev/null 2>&1 && return 0
  fi

  ln -s "$source_skill" "$target_skill"
}

found=0
out_of_sync=0

for source_skill in "$source_dir"/*; do
  [ -d "$source_skill" ] || continue
  [ -f "$source_skill/SKILL.md" ] || continue
  found=1
  skill_name=$(basename "$source_skill")

  for target_dir in $target_dirs; do
    target_skill="$target_root/$target_dir/$skill_name"

    if [ "$mode" = "--check" ]; then
      if [ ! -d "$target_skill" ]; then
        printf 'missing skill exposure: %s\n' "$target_skill" >&2
        out_of_sync=1
        continue
      fi
      if same_dir "$source_skill" "$target_skill"; then
        continue
      fi
      if same_skill_content "$source_skill" "$target_skill"; then
        printf 'duplicate skill exposure should be linked: %s\n' "$target_skill" >&2
      else
        printf 'out-of-sync skill exposure: %s\n' "$target_skill" >&2
      fi
      out_of_sync=1
      continue
    fi

    if [ -e "$target_skill" ]; then
      if same_dir "$source_skill" "$target_skill"; then
        continue
      fi
      same_skill_content "$source_skill" "$target_skill" ||
        fail "target skill differs from source; review before replacing: $target_skill"
      remove_existing_target "$target_skill"
    fi

    create_dir_link "$source_skill" "$target_skill"
  done
done

[ "$found" -eq 1 ] || fail "no source skills found in: $source_dir"

if [ "$mode" = "--check" ]; then
  [ "$out_of_sync" -eq 0 ] || fail "agent skill exposures are out of sync; run sync-agent-skills.sh --write"
  info "OK: agent skill exposures point to ai-specs/skills"
else
  info "OK: agent skills exposed from $source_dir"
fi
