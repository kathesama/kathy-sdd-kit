---
name: validate-impl-spec
description: Use when an implementation spec exists and you need an automated structural check that every acceptance criterion is mapped across implementation, validation, and completion evidence.
---

# Skill: Validate Implementation Spec

## TDD, Evidence and Design

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

Run the POSIX `sh` validator that enforces structural completeness of an implementation spec before implementation, QA, or PR reporting.

## Usage

Preferred inputs:

- a ticket key like `JAP-418`
- or an explicit file path like `.ai-specs/changes/JAP-418/JAP-418-impl-frontend.md`

## Tool

Run:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh <ticket-key-or-impl-plan-path>
```

Run it from the consumer repository root.

## What the validator checks

- required sections exist:
  - `Related Work Items`
  - `Acceptance Criteria`
  - `Implementation Mapping`
  - `Validation Plan`
  - `Delivery Plan`
  - `Execution Notes for Implementer`
  - `Completion Evidence`
- every `AC-XX` from `Acceptance Criteria` appears in:
  - `Implementation Mapping`
  - `Validation Plan`
  - `Completion Evidence`
- acceptance criteria IDs are unique
- `Completion Evidence` statuses are one of:
  - `Covered`
  - `Partial`
  - `Not Covered`
- the companion `{TICKET}-implementation-spec.md` has the same AC set as the primary implementation plan

## Ticket resolution behavior

If the input is a ticket key, the validator resolves:

- `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md`
- or `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`

If both files exist, require the exact path to avoid ambiguity.

## Rules

- Do not claim the plan is structurally complete without running the validator
- If validation fails, report the exact missing AC IDs and section names
- If `sh` is not on `PATH` on Windows, use Git for Windows `sh.exe`
- Use the validator before:
  - implementation starts
  - final QA
  - PR content generation
