## Ticket
<!-- AUTO-TICKET-START -->
PRX-200 - Example valid SDD kit PR content
<!-- AUTO-TICKET-END -->

**Target branch**
- [ ] develop (feature integration)
- [x] main (release merge from develop / production hotfix)
- [ ] release/* (release stabilization)
- [ ] hotfix/* (urgent production fix branch)

## Summary
<!-- AUTO-SUMMARY-START -->
- Adds a documentation-only example for validating generated PR content against local SDD evidence.
- Demonstrates checked commands, AC coverage, QA/review evidence, and suggested commit messages without inventing commits.
<!-- AUTO-SUMMARY-END -->

## Change Type
- [ ] Bugfix
- [ ] Feature
- [ ] Refactor
- [x] Docs / Chore
- [ ] Infrastructure / CI

## Scope
- [ ] Java
- [ ] Python
- [ ] Docker / Compose
- [ ] CI / CD
- [x] Documentation

## Tickets / References
- Issue / Task: PRX-200
- Suggested commit messages:
  - PRX-200 docs(sdd): add valid PR content example

## What was done
- Added a valid PR content example mapped to AC-01.
- Added matching local QA, review, changelog, and implementation spec evidence.

## Changes

### Files created
- `examples/pr-content/valid/PR-PRX-200.md` - valid PR content example

### Files modified
- `README.md` - documents the examples folder

### Files deleted
- None

## Testing
- Tests written: validator fixture for generated PR content
- Scenarios covered: AC coverage and checked command evidence

## Acceptance Criteria Coverage
- [x] AC-01 - Valid PR content maps AC coverage to local evidence
  - Status: Covered
  - Evidence: `sh tools/validate-pr-content.sh examples/pr-content/valid/PR-PRX-200.md` passed

## Screenshots
N/A

## How to test

### Local
- [ ] `mvn -B -ntp verify`
- [ ] `python scripts/run_pytests_monorepo.py`
- [x] Other: `sh tools/validate-pr-content.sh examples/pr-content/valid/PR-PRX-200.md`

### CI (GitHub Actions)
- [ ] Java - Maven verify
- [ ] Python - Monorepo (Ruff + Pytest)

## Risks and mitigation
- Risk: Example PR content may drift from validator rules.
  - Mitigation: GitHub Actions validates this example.

## Related
- TC: PRX-200
- IMPL: `examples/pr-content/valid/PRX-200-implementation-spec.md`
- Confluence: N/A

## Pre-merge checklist
- [x] No secrets or credentials in the change
- [x] Tests cover the change or it is a safe refactor
- [ ] CI logs reviewed if failures occurred
- [x] Documentation updated if applicable
- [ ] Commits are signed (Verified)

## Definition of Done checklist
- [x] Acceptance criteria are fully covered or documented as partial/blocked
- [x] Tests and validation evidence are included
- [x] Documentation is updated where applicable
- [x] Risks and mitigations are documented
- [x] Related TC/IMPL/Confluence links are included
