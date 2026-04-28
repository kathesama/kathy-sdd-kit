# Engineering Rule Pack Selection Example: JAP-210

## Ticket Context

`JAP-210` adds an outbox-backed event publication flow for an order lifecycle
change. The service writes the order state, persists an outbox record, and a
background job publishes events to a broker.

## Engineering Rule Packs

- `domain-driven-design.mini.md`: selected because order lifecycle transitions
  are business concepts with invariants that should not be modeled from table
  shape alone.
- `data-intensive.mini.md`: selected because the write path introduces retries,
  replay, event schemas, idempotency, and derived downstream state.
- `release-it.mini.md`: selected because the background publisher depends on a
  broker and must define timeout, retry, duplicate, and observability behavior.

## Packs Not Selected

- `clean-architecture.mini.md`: not selected separately because the existing
  implementation spec already constrains ports and adapters, and no new
  dependency direction risk is introduced.
- `patterns-of-enterprise-application-architecture.mini.md`: not selected
  because no new persistence pattern or transaction script/domain model choice
  is being made.
- `refactoring.mini.md`: not selected because no behavior-preserving structural
  cleanup is planned.

## Implementation Spec Note

The implementation spec should copy the selected packs into `Execution Notes for
Implementer` and use them to shape validation:

- AC validation must include duplicate event delivery.
- AC validation must include event replay or publisher restart behavior.
- Risk notes must name the event source of truth and consistency boundary.
- QA and PR review must preserve these risks in their evidence.
