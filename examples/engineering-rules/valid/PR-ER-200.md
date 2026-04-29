## Ticket

ER-200

## Summary

- Adds a replay-safe event consumer fixture.
- Demonstrates selected engineering rule pack traceability through QA, review, and PR content.

## Acceptance Criteria Coverage

- [x] AC-01 - Event consumer is idempotent under replay
  - Status: Covered
  - Evidence: Replay and idempotency validation passed.
- [x] AC-02 - Broker publication uses bounded timeout and retry behavior
  - Status: Covered
  - Evidence: Timeout and retry validation passed.

## Engineering Rule Packs

- `data-intensive.mini.md`: DI-01 source of truth and DI-02 replay/idempotency risks were validated.
- `release-it.mini.md`: REL-01 timeout and REL-02 retry/duplicate safety risks were reviewed.

## How to test

### Local
- [ ] `pytest tests/test_event_consumer.py`

## Risks and mitigation

- Risk: Event replay may duplicate writes.
  - Mitigation: Consumer idempotency was validated.
- Risk: Broker dependency may stall or retry.
  - Mitigation: Timeout and retry bounds were validated.
