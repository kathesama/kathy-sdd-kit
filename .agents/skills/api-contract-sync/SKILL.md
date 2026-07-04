---
name: api-contract-sync
description: Use when backend/API endpoints, gateway routes, payloads, auth, OpenAPI specs, capability manifests, or API contract docs change and a frontend/UI repository must receive updated contract artifacts.
---

# Skill: API Contract Sync

## Purpose

Keep frontend/UI repositories aligned with backend API capabilities through
versioned contract artifacts. The API repository remains the source of truth;
UI repositories receive generated copies and must not edit them manually.

## Trigger

Use this skill when a task changes or reviews:

- public HTTP endpoints, gateway routes, request/response payloads, status codes, auth, scopes, or headers
- OpenAPI/spec files, API contract docs, capability manifests, or frontend API clients
- a user asks to sync backend API contracts into a UI repository

## Opt-In Configuration

The skill is disabled unless the consuming API repository contains:

`docs/contracts/api-contract-sync.json`

Minimum config:

```json
{
  "update_api_contract": true,
  "target_repo_path": "D:/projects/react/juana-pwd-ui",
  "target_base_path": ".",
  "source_files": [
    "docs/contracts/api-contract.md",
    "docs/contracts/capabilities.json",
    "docs/contracts/api-contract.yml"
  ],
  "target_required_markers": [
    "AGENTS.md",
    "package.json"
  ],
  "manifest_path": "docs/contracts/api-contract-source.json",
  "missing_source_policy": "fail"
}
```

If the config file is absent, `update_api_contract` is not `true`, or
`source_files` is empty, the sync is a no-op.

## Workflow

1. Update the source contract artifacts in the API repository.
2. Run the sync script from the consuming API repository root. Use POSIX `sh`
   when available:

   ```sh
   sh .sdd-kit/ai-specs/skills/api-contract-sync/scripts/sync-api-contract.sh \
     --config docs/contracts/api-contract-sync.json
   ```

   Or use PowerShell on Windows:

   ```powershell
   powershell -NoProfile -File .sdd-kit/ai-specs/skills/api-contract-sync/scripts/sync-api-contract.ps1 `
     -Config docs/contracts/api-contract-sync.json
   ```

   When running from a kit checkout directly, pass the consuming project root:

   ```sh
   sh ai-specs/skills/api-contract-sync/scripts/sync-api-contract.sh \
     --project-root D:/projects/ia/JuanaIA \
     --config D:/projects/ia/JuanaIA/docs/contracts/api-contract-sync.json
   ```

   ```powershell
   powershell -NoProfile -File ai-specs/skills/api-contract-sync/scripts/sync-api-contract.ps1 `
     -ProjectRoot D:/projects/ia/JuanaIA `
     -Config D:/projects/ia/JuanaIA/docs/contracts/api-contract-sync.json
   ```

3. Review the copied contract artifacts in the UI repository.
4. In the UI repository, use `consume-api-contract` before planning or
   implementing API-consuming screens from the copied artifacts.
5. If a ticket changelog is active, append sync evidence to
   `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md` in the API repository.
6. Run the smallest relevant validation for both repos:
   - API: contract/source tests or docs validation
   - UI: type generation, lint, or API-client tests when available

## Contract Artifacts

Recommended source files:

- `docs/contracts/api-contract.md` for human-readable endpoint inventory and auth notes
- `docs/contracts/capabilities.json` for machine-readable feature availability
- `docs/contracts/api-contract.yml` for OpenAPI specs or generated client inputs

Do not make the UI repository the source of truth for these files.

## Script Behavior

`sync-api-contract.sh` and `sync-api-contract.ps1`:

- exits successfully without changes when config is absent or disabled
- fails if enabled config points to a missing target repository
- validates optional `target_required_markers` before copying
- copies listed source files/directories to the same relative paths under
  `target_base_path`
- prefixes copied Markdown files with a generated-source notice
- preserves JSON validity by not inserting comments into JSON files
- writes a JSON manifest when `manifest_path` is set
- refuses to write outside the configured target repository

The POSIX `sh` script uses `python3` or `python` for JSON parsing and file-copy
logic. If neither command is available, it fails before making changes.

## Safety Rules

- Do not invent endpoint contracts. If source contract content is missing, fix
  the API contract first or set `missing_source_policy` to `warn` only for a
  temporary bootstrap.
- Endpoint, Gateway route, request/response payload, status code, auth, scope,
  header, or public API behavior changes must update all related canonical
  contract artifacts under `docs/contracts/` together when they exist.
- Do not edit generated contract files in the UI repository; change the API
  source and rerun sync.
- Do not sync secrets, environment files, tokens, local credentials, build
  outputs, or runtime logs.
- Keep source paths explicit in `source_files`; avoid broad roots such as `.`,
  `docs`, or the whole repository.
- Treat API contract changes as cross-repository changes and record validation
  evidence for both API and UI when a ticket is active.

## Validation

Before reporting sync as complete, run at least:

```powershell
sh .sdd-kit/ai-specs/skills/api-contract-sync/scripts/sync-api-contract.sh \
  --config docs/contracts/api-contract-sync.json \
  --dry-run
```

Then run the real sync if the dry run lists the expected files and target.
