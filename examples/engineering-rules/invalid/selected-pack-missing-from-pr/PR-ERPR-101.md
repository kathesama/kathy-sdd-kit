## Ticket

ERPR-101

## Summary

- Adds replay validation for the event consumer.

## Acceptance Criteria Coverage

- [x] AC-01 - Event consumer is idempotent under replay
  - Status: Covered
  - Evidence: Replay validation passed in QA evidence.

## How to test

### Local
- [ ] `pytest tests/test_event_replay.py`

## Risks and mitigation

- Risk: Event replay may duplicate writes.
  - Mitigation: Consumer idempotency was validated.
