## Ticket

ERPR-102

## Summary

- Adds event replay validation.

## Acceptance Criteria Coverage

- [x] AC-01 - Event consumer handles replay
  - Status: Covered
  - Evidence: Replay validation passed.

## Engineering Rule Packs

- `data-intensive.mini.md`: DI-01 replay behavior was checked.

## Risks and mitigation

- Risk: Event replay may duplicate writes.
  - Mitigation: Replay validation was added.
