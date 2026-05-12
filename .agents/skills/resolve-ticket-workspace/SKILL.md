---
name: resolve-ticket-workspace
description: Use when working on a ticket in a consumer repository and you need the current .ai-specs workspace paths resolved from a ticket key or the active git branch.
---

# Skill: Resolve Ticket Workspace

## Purpose

Resolve the local `.ai-specs/changes/{TICKET}/` workspace for the current repository so other skills can use the correct enriched spec, implementation spec, and PR output paths.

## Usage

Preferred inputs:

- a ticket key like `JAP-418`
- or no input, which falls back to the current git branch name

## Tool

Run:

```bash
sh .sdd-kit/tools/resolve-ticket-workspace.sh [ticket-key]
```

Run it from the consumer repository root.

## Output

The tool returns JSON containing:

- `ticket`
- `branchName`
- `ticketDir`
- `enrichedPath`
- `implBackendPath`
- `implFrontendPath`
- `implementationSpecPath`
- `changelogPath`
- `prPath`
- `existingFiles`

## Rules

- Prefer branch-derived ticket resolution when the branch already contains the consuming project's canonical ticket key
- If the branch does not contain a ticket key, require explicit ticket input
- If `sh` is not on `PATH` on Windows, use Git for Windows `sh.exe`
- Use this resolver before planning, validation, and PR generation when the workspace path is ambiguous
