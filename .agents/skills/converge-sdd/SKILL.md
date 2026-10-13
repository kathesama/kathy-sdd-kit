---
name: converge-sdd
description: Report source-linked gaps against approved SDD intent without changing scope or implementation.
---

# Skill: Converge SDD

## Required Inputs

Read approved plan/spec, current scoped source, test/evidence records and related
work items. Apply `tdd-evidence-contract.md` and `engineering-quality-contract.md`.

## Workflow

1. Review each member/AC against actual source and fresh evidence. Report missing,
   partial, contradicting and unrequested work, including evidence limitations.
2. Record observations with member, AC, stable source location, status and evidence.
   `sdd_harness.evidence.converge` normalizes these reviewed observations; it is
   not an automatic semantic code reviewer or a substitute for runtime tests.
3. Write `harness/convergence.json` and `CONVERGENCE-{TICKET}.md` in the ticket
   workspace. Identify findings by member + AC + gap type + source location;
   update existing findings rather than creating duplicate tasks.
4. Recommend remediation only inside existing approved scope and remaining
   budgets. Route new requirements to planning. Do not edit source/spec, remove
   unrequested code, grant approval or mark an AC Covered from a finding alone.
5. A no-gap pass leaves approved artifacts unchanged. Missing TDD evidence remains
   a blocker even when current code appears correct. Record method and observer.
