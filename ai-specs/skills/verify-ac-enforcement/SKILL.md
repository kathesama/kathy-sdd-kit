---
name: verify-ac-enforcement
description: Use when validating changes to this SDD kit or any workflow update that might let agents skip, merge, or hide acceptance criteria coverage.
---

# Skill: Verify AC Enforcement

## Purpose

Validate that the kit still enforces acceptance criteria as delivery contract items across enrichment, planning, implementation, and PR reporting.

## Usage

Use this skill when:

- editing `enrich-user-story`
- editing planners such as `plan-backend-ticket` or `plan-frontend-ticket`
- editing agent behavior
- editing `write-pr-report`
- changing standards that affect Definition of Done

## Required Inputs

Read:

- `docs/ac-enforcement-pressure-scenarios.md`
- `ai-specs/specs/base-standards.mdc`
- the changed skills, agents, or templates

## Verification Loop

1. Choose at least one scenario that pressures planning.
2. Choose at least one scenario that pressures completion/reporting.
3. Run the affected workflow mentally or with the target agent.
4. Record whether each explicit AC survives with:
   - stable ID
   - implementation mapping
   - validation mapping
   - completion/reporting evidence
5. If the workflow can still claim "done" while dropping an AC, the kit is not ready.

## What to look for

- missing ACs
- merged ACs that should stay separate
- vague validation lines that do not prove coverage
- inferred ACs not labeled as inferred
- PR summaries that hide partial coverage

## Output

A short verification note containing:

- scenarios exercised
- pass/fail result
- any loophole or rationalization discovered
- exact file that should be tightened if the scenario failed

## Rules

- Do not say the kit is solid without exercising pressure scenarios
- At least one scenario must test planning and one must test final reporting
- If you find a loophole, document the exact failure mode before proposing a fix
