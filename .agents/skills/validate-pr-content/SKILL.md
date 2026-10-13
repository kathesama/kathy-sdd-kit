---
name: validate-pr-content
description: Use when PR-{TICKET}.md has been generated and must be checked against local SDD evidence before handoff.
---

# Skill: Validate PR Content

## TDD, Evidence and Design

For contract-1 reports, include the label `TDD and Design Evidence` inside an
appropriate existing report section, preserving any repository PR template.
Follow it with a table: `AC | Applicability | Evidence | Design review`, one
row per AC. Reference actual observations or explicit missing-evidence blockers;
the report label and table never prove runtime execution by themselves.

Read `ai-specs/specs/tdd-evidence-contract.md`,
`ai-specs/specs/engineering-quality-contract.md` and, when running the optional
controller, `ai-specs/specs/harness-evidence-contract.md`.

- New plans and companion specs require `SDD Evidence Contract: 1` and the
  identical per-AC `### TDD and Design Contract` table from the template.
- Require behavior-specific RED before implementation, unchanged tests at
  GREEN, and fresh regression verification. Characterization and non-executable
  reviews use the applicability rules; missing setup is not an exemption.
- Review applicable SRP, OCP, LSP, ISP and DIP without speculative abstractions.
- Preserve evidence kind, observer, command, identity, chronology and freshness.
  A structural validator or agent assertion cannot establish runtime success.
- Keep Covered / Partial / Not Covered. Required missing, stale, contradictory
  or unknown evidence blocks completion, including every in-scope child AC.
- An unchanged approved scope reuses its explicit human approval on resume;
  material scope/check changes require a revised plan and approval. Preserve
  project overrides. No approval, Git or tracker write is inferred from this skill.
- Optional `run-sdd-harness` and `converge-sdd` add bounded execution and gap
  reporting. Convergence never replaces TDD or authorizes new requirements.

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
- frontend/UI Design System Contracts are traceable through QA, review, and PR
  content when the implementation spec declares one

## Rules

- Do not mark PR content ready without running this validator.
- If validation fails, fix `PR-{TICKET}.md` or the missing evidence before handoff.
- Do not use this validator as a replacement for QA or code review; it only checks evidence consistency.
