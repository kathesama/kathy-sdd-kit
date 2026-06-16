---
name: debt-harvest
description: Scan ticket-scoped files for sdd-simplification markers and append a structured debt ledger to the ticket changelog.
---

# Debt Harvest Skill

## Purpose

Scan the current ticket's touched files for `sdd-simplification:` markers and
append a structured debt ledger to the ticket changelog.

## When to Use

Use only when explicitly requested, such as:

- `harvest debt`
- `/debt-harvest`

`close-ticket-workflow` may recommend running `/debt-harvest` if
`sdd-simplification:` markers are detected in ticket scope, but it must never
execute this skill automatically.

## Required Inputs

Read:

- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
- ticket-scoped files listed in changelog `### Files created` and
  `### Files modified` sections
- `ai-specs/specs/changelog-template.md`

If the ticket cannot be resolved or the changelog is missing, stop and report
the blocker.

## Scope

Only scan files touched by the current ticket, based on the ticket changelog's
created and modified file lists. Never scan unrelated files.

## Marker Format

Use this inline marker only for intentional, bounded simplifications:

```text
# sdd-simplification: <what was skipped> - upgrade path: <what replaces this when needed>
```

The upgrade path must name a concrete mechanism or trigger. A
`sdd-simplification:` marker does not exempt the line from acceptance-criteria
validation, tests, security, accessibility, error handling, or architecture
rules.

## Output Format

Append to `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md` as a new valid
entry:

```md
## {TICKET}-DEBT-HARVEST: Harvest intentional simplification markers
**Status:** Done
**Commit message:** Not committed; repository rules forbid agent commits unless explicitly requested.
### Files created
- None
### Files modified
- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
### Summary
- Scanned ticket scope for `sdd-simplification:` markers.

### Notes
| Marker location | What was skipped | Upgrade path | Trigger condition |
|---|---|---|---|
| `path/to/file.py:42` | no cache layer | Redis via cache-service | p95 > 200ms |
---
```

If no markers are found, the `### Notes` section must state:

`No sdd-simplification: markers in ticket scope.`

## Rules

- Modify only the ticket changelog.
- Do not modify implementation files.
- Preserve existing changelog sections exactly and append only.
- The appended section must pass `tools/validate-changelog.sh` or
  `.sdd-kit/tools/validate-changelog.sh`, depending on whether the kit or a
  consuming repository is being edited.
- Output in English.

## Source and Attribution

This intentional-simplification ledger is adapted from ideas in
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), MIT
licensed, and rewritten for SDD ticket scope, changelog validation, and
acceptance-criteria evidence rules.
