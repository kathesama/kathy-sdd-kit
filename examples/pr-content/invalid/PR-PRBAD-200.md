## Ticket
<!-- AUTO-TICKET-START -->
PRBAD-200 - Invalid PR content example
<!-- AUTO-TICKET-END -->

## Summary
<!-- AUTO-SUMMARY-START -->
- Demonstrates a PR content file that should fail validation.
<!-- AUTO-SUMMARY-END -->

## Tickets / References
- Issue / Task: PRBAD-200
- Suggested commit messages:
  - PRBAD-200 docs(sdd): invalid fixture

## Changes

### Files created
- `examples/pr-content/invalid/PR-PRBAD-200.md` - invalid PR content example

### Files modified
- `README.md` - documents examples

### Files deleted
- None

## Acceptance Criteria Coverage
- [x] AC-01 - Invalid PR content should fail when checked command has no evidence
  - Status: Covered
  - Evidence: This intentionally references missing evidence

## How to test

### Local
- [x] Other: `missing-command-without-evidence`

### CI (GitHub Actions)
- [ ] Python - Monorepo (Ruff + Pytest)
