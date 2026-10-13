---
name: verify-ac-enforcement
description: Use when validating changes to this SDD kit or any workflow update that might let agents skip, merge, or hide acceptance criteria coverage.
---

# Skill: Verify AC Enforcement

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
- `ai-specs/specs/agent-behavior-standards.mdc`
- `ai-specs/specs/design-system-standards.mdc` when frontend/UI workflow changed
- `ai-specs/rules/engineering/README.md` when rule pack selection changed
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
- selected engineering rule packs when they affect risk or validation
- design-system contract evidence when frontend/UI scope depends on
  `DESIGN.md`, tokens, Storybook, screenshots, or visual checks
5. If the workflow can still claim "done" while dropping an AC, the kit is not ready.

## What to look for

- missing ACs
- merged ACs that should stay separate
- vague validation lines that do not prove coverage
- inferred ACs not labeled as inferred
- PR summaries that hide partial coverage
- selected rule packs that become untraceable between planning, QA, review, and PR reporting
- design-system changes that bypass ACs, validation, or visible review evidence
- agent behavior rules that allow speculative or unrelated changes to bypass AC evidence

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
