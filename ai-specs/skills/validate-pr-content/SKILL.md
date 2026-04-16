---
name: validate-pr-content
description: Use when PR-{TICKET}.md has been generated and must be checked against local SDD evidence before handoff.
---

# Skill: Validate PR Content

## Purpose

Run the POSIX `sh` validator that checks generated PR content against local SDD evidence so agents do not invent tests, CI status, commits, or AC coverage.

## Usage

Preferred inputs:

- a ticket key like `JAP-418`
- or an explicit file path like `.ai-specs/changes/JAP-418/PR-JAP-418.md`

## Tool

Run:

```bash
sh .sdd-kit/tools/validate-pr-content.sh <ticket-key-or-pr-path>
```

Run it from the consumer repository root. If `sh` is not on `PATH` on Windows, use Git for Windows `sh.exe`.

## What the validator checks

- required local evidence files exist:
  - `PR-{TICKET}.md`
  - `{TICKET}-CHANGELOG.md`
  - `{TICKET}-implementation-spec.md`
  - `QA-{TICKET}.md`
  - `REVIEW-{TICKET}.md`
- every AC from the implementation spec appears in PR content
- partial/not-covered/blocked AC statuses are not hidden
- checked PR commands have matching evidence in the ticket folder
- checked CI items have explicit CI evidence
- `Key commits` entries use real commit hashes, otherwise they must not be presented as commits
- referenced created/modified files exist
- PR content has no mojibake markers
- QA and review reports are not in failing/request-changes states

## Rules

- Do not mark PR content ready without running this validator.
- If validation fails, fix `PR-{TICKET}.md` or the missing evidence before handoff.
- Do not use this validator as a replacement for QA or code review; it only checks evidence consistency.
