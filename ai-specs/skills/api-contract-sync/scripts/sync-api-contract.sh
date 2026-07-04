#!/usr/bin/env sh
set -eu

usage() {
  cat <<'USAGE'
usage: sync-api-contract.sh [--project-root PATH] [--config PATH] [--dry-run]

Synchronizes API contract artifacts from an API repository into a UI repository.

Options:
  --project-root, -ProjectRoot  API repository root. Defaults to current directory.
  --config, -Config            Config path. Defaults to docs/contracts/api-contract-sync.json.
  --dry-run, -DryRun           Print planned writes without changing files.
  --help, -h                   Show this help.
USAGE
}

project_root=$(pwd)
config_path="docs/contracts/api-contract-sync.json"
dry_run=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot)
      [ "$#" -ge 2 ] || {
        usage >&2
        exit 2
      }
      project_root=$2
      shift 2
      ;;
    --config|-Config)
      [ "$#" -ge 2 ] || {
        usage >&2
        exit 2
      }
      config_path=$2
      shift 2
      ;;
    --dry-run|-DryRun)
      dry_run=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      printf 'FAIL: unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

if command -v python3 >/dev/null 2>&1; then
  python_cmd=python3
elif command -v python >/dev/null 2>&1; then
  python_cmd=python
else
  printf 'FAIL: python3 or python is required for JSON config parsing\n' >&2
  exit 1
fi

"$python_cmd" - "$project_root" "$config_path" "$dry_run" <<'PY'
import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any


def info(message: str) -> None:
    print(f"api-contract-sync: {message}")


def msys_to_windows_path(value: str) -> str:
    if os.name != "nt":
        return value

    match = re.match(r"^/([a-zA-Z])(?:/(.*))?$", value)
    if match:
        drive = match.group(1).upper()
        tail = match.group(2) or ""
        return f"{drive}:/{tail}"

    match = re.match(r"^/cygdrive/([a-zA-Z])(?:/(.*))?$", value)
    if match:
        drive = match.group(1).upper()
        tail = match.group(2) or ""
        return f"{drive}:/{tail}"

    return value


def full_path(base_path: Path, raw_path: str) -> Path:
    expanded = os.path.expanduser(os.path.expandvars(str(raw_path)))
    expanded = msys_to_windows_path(expanded)
    candidate = Path(expanded)
    if not candidate.is_absolute():
        candidate = base_path / expanded
    return candidate.resolve()


def normalized(path: Path) -> str:
    resolved = str(path.resolve()).replace("\\", "/").rstrip("/")
    if os.name == "nt":
        return resolved.lower()
    return resolved


def path_within(child_path: Path, parent_path: Path) -> bool:
    child = normalized(child_path)
    parent = normalized(parent_path)
    return child == parent or child.startswith(parent + "/")


def config_value(config: dict[str, Any], name: str, default: Any) -> Any:
    return config[name] if name in config else default


def string_array(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value] if value.strip() else []
    return [str(item) for item in value if item is not None and str(item).strip()]


def bool_value(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.strip().lower() == "true"
    return False


def relative_to_base(base_path: Path, path: Path) -> str:
    return os.path.relpath(path, base_path).replace("\\", "/")


def copy_contract_file(
    source_path: Path,
    destination_path: Path,
    source_relative_path: str,
    source_root: Path,
    markdown_header_enabled: bool,
    dry_run_mode: bool,
) -> None:
    if dry_run_mode:
        info(f"would copy {source_relative_path} -> {destination_path}")
        return

    destination_path.parent.mkdir(parents=True, exist_ok=True)

    if markdown_header_enabled and source_path.suffix.lower() == ".md":
        relative_from_root = relative_to_base(source_root, source_path)
        header = f"<!-- Generated from API source: {relative_from_root}. Do not edit in target repo. -->\n\n"
        content = source_path.read_text(encoding="utf-8-sig")
        destination_path.write_text(header + content, encoding="utf-8")
        return

    shutil.copy2(source_path, destination_path)


project_root = full_path(Path.cwd(), sys.argv[1])
config_path = full_path(project_root, sys.argv[2])
dry_run = sys.argv[3].lower() == "true"

if not config_path.exists():
    info(f"config not found; no-op ({config_path})")
    sys.exit(0)

with config_path.open("r", encoding="utf-8-sig") as handle:
    config_object = json.load(handle)

if not bool_value(config_value(config_object, "update_api_contract", False)):
    info("update_api_contract is not true; no-op")
    sys.exit(0)

target_repo_raw = str(config_value(config_object, "target_repo_path", "")).strip()
if not target_repo_raw:
    raise RuntimeError("target_repo_path is required when update_api_contract is true")

target_repo = full_path(project_root, target_repo_raw)
if not target_repo.is_dir():
    raise RuntimeError(f"target_repo_path does not exist or is not a directory: {target_repo}")
if normalized(target_repo) == normalized(project_root):
    raise RuntimeError("target_repo_path must not be the same as ProjectRoot")

target_base_raw = str(config_value(config_object, "target_base_path", "."))
target_base = full_path(target_repo, target_base_raw)
if not path_within(target_base, target_repo):
    raise RuntimeError(f"target_base_path resolves outside target_repo_path: {target_base}")

source_files = string_array(config_value(config_object, "source_files", []))
if not source_files:
    info("source_files is empty; no-op")
    sys.exit(0)

for marker in string_array(config_value(config_object, "target_required_markers", [])):
    marker_path = full_path(target_repo, marker)
    if not path_within(marker_path, target_repo):
        raise RuntimeError(f"target_required_markers entry resolves outside target repo: {marker}")
    if not marker_path.exists():
        raise RuntimeError(f"target repository marker is missing: {marker}")

missing_policy = str(config_value(config_object, "missing_source_policy", "fail")).strip().lower()
if missing_policy not in ("fail", "warn"):
    raise RuntimeError("missing_source_policy must be 'fail' or 'warn'")

clean_target_directories = bool_value(config_value(config_object, "clean_target_directories", False))
markdown_header_enabled = bool_value(config_value(config_object, "markdown_header_enabled", True))
manifest_path_raw = str(config_value(config_object, "manifest_path", "docs/contracts/api-contract-source.json"))

copied_files: list[str] = []
missing_sources: list[str] = []

for source_relative in source_files:
    source_relative = source_relative.replace("\\", "/")
    source_candidate = Path(msys_to_windows_path(source_relative))
    if source_candidate.is_absolute() or re.match(r"^[A-Za-z]:[\\/]", source_relative):
        raise RuntimeError(f"source_files entries must be relative to ProjectRoot: {source_relative}")

    source_path = full_path(project_root, source_relative)
    if not path_within(source_path, project_root):
        raise RuntimeError(f"source path resolves outside ProjectRoot: {source_relative}")

    if not source_path.exists():
        missing_sources.append(source_relative)
        message = f"source not found: {source_relative}"
        if missing_policy == "fail":
            raise RuntimeError(message)
        print(f"WARNING: api-contract-sync: {message}", file=sys.stderr)
        continue

    destination_path = full_path(target_base, source_relative)
    if not path_within(destination_path, target_repo):
        raise RuntimeError(f"destination path resolves outside target repo: {destination_path}")

    if source_path.is_dir():
        if clean_target_directories and destination_path.exists():
            if not path_within(destination_path, target_repo):
                raise RuntimeError(f"refusing to clean unsafe target directory: {destination_path}")
            if dry_run:
                info(f"would clean target directory {destination_path}")
            else:
                shutil.rmtree(destination_path)

        for source_file in sorted(path for path in source_path.rglob("*") if path.is_file()):
            relative_inside = source_file.relative_to(source_path)
            destination_file = destination_path / relative_inside
            source_log_path = f"{source_relative}/{relative_inside.as_posix()}"
            copy_contract_file(
                source_file,
                destination_file,
                source_log_path,
                project_root,
                markdown_header_enabled,
                dry_run,
            )
            copied_files.append(source_log_path)
        continue

    copy_contract_file(
        source_path,
        destination_path,
        source_relative,
        project_root,
        markdown_header_enabled,
        dry_run,
    )
    copied_files.append(source_relative)

if manifest_path_raw.strip():
    manifest_path = full_path(target_base, manifest_path_raw)
    if not path_within(manifest_path, target_repo):
        raise RuntimeError(f"manifest_path resolves outside target repo: {manifest_path}")

    manifest = {
        "schema_version": 1,
        "generated_by": "api-contract-sync",
        "source_root": str(project_root),
        "target_repo_path": str(target_repo),
        "source_files": source_files,
        "copied_files": copied_files,
        "missing_sources": missing_sources,
    }

    if dry_run:
        info(f"would write manifest {manifest_path}")
    else:
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

info(f"completed; copied={len(copied_files)} missing={len(missing_sources)} dry_run={dry_run}")
PY
