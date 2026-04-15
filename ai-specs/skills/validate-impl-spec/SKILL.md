---
name: validate-impl-spec
description: Use when an implementation spec exists and you need an automated structural check that every acceptance criterion is mapped across implementation, validation, and completion evidence.
---

# Skill: Validate Implementation Spec

## Purpose

Run the TypeScript validator that enforces structural completeness of an implementation spec before implementation, QA, or PR reporting.

## Usage

Preferred inputs:

- a ticket key like `JAP-418`
- or an explicit file path like `.ai-specs/changes/JAP-418/JAP-418-impl-frontend.md`

## Tool

Run:

```bash
npx tsx .sdd-kit/tools/validate-impl-spec.ts <ticket-key-or-impl-spec-path>
```

Run it from the consumer repository root.

## What the validator checks

- required sections exist:
  - `Acceptance Criteria`
  - `Implementation Mapping`
  - `Validation Plan`
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

## Ticket resolution behavior

If the input is a ticket key, the validator resolves:

- `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md`
- or `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`

If both files exist, require the exact path to avoid ambiguity.

## Rules

- Do not claim the plan is structurally complete without running the validator
- If validation fails, report the exact missing AC IDs and section names
- Use the validator before:
  - implementation starts
  - final QA
  - PR content generation
