#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)

printf '%s\n' "sync-codex-skills.sh is kept for compatibility; use sync-agent-skills.sh."
exec sh "$script_dir/sync-agent-skills.sh" "$@"
