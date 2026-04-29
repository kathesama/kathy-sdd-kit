# ER-200 Implementation Spec

## Story Context

- **Story / Ticket**: ER-200
- **Objective**: Add a replay-safe event consumer with production failure handling.
- **Related Technical Contract**: Example only.
- **SDD Kit Version**: 0.4.1

## Related Work Items

| Key | Type | Status | Scope Decision | Plan Impact |
|---|---|---|---|
| ER-200 | Parent | Ready for planning | In scope | Defines AC-01 and AC-02 |

## Scope

### In Scope

- Validate duplicate event replay behavior.
- Validate timeout and retry handling for broker calls.

### Out of Scope

- Broker provisioning.

## Acceptance Criteria

| ID | Criterion | Validation Type | Source |
|---|---|---|---|
| AC-01 | Event consumer is idempotent under replay | automated_test | explicit |
| AC-02 | Broker publication uses bounded timeout and retry behavior | automated_test | explicit |

## Implementation Mapping

| AC | Files / Modules | Planned Change | Risk Notes |
|---|---|---|---|
| AC-01 | `app/events/consumer.py` | Track processed event IDs before applying writes | `data-intensive.mini.md`: DI-01 source of truth and DI-02 replay/idempotency must be explicit |
| AC-02 | `app/events/broker.py` | Bound broker timeout and retry attempts | `release-it.mini.md`: REL-01 timeout and REL-02 retry/duplicate safety must be validated |

## Validation Plan

| AC | Test / Check | Command or Method | Expected Evidence |
|---|---|---|---|
| AC-01 | `data-intensive.mini.md` DI-01 DI-02 replay test | `pytest tests/test_event_consumer.py` | Source of truth is named and duplicate replay does not duplicate writes |
| AC-02 | `release-it.mini.md` REL-01 REL-02 failure handling test | `pytest tests/test_event_consumer.py` | Timeout and retry attempts are bounded with duplicate safety |

## Delivery Plan

1. Add source of truth, replay, and idempotency tests for `data-intensive.mini.md` DI-01 DI-02 (`AC-01`).
2. Add timeout, retry, and duplicate safety tests for `release-it.mini.md` REL-01 REL-02 (`AC-02`).
3. Implement consumer idempotency and broker failure handling (`AC-01`, `AC-02`).

## Execution Notes for Implementer

### Engineering Rule Packs

| Pack | Selection | Reason | Active Obligations | Required Validation Impact |
|---|---|---|---|---|
| clean-architecture.mini.md | Not selected | Existing consumer and broker boundaries are unchanged. | N/A | N/A |
| domain-driven-design.mini.md | Not selected | No domain language or invariant change. | N/A | N/A |
| patterns-of-enterprise-application-architecture.mini.md | Not selected | No new persistence or transaction pattern choice. | N/A | N/A |
| refactoring.mini.md | Not selected | No behavior-preserving structural cleanup. | N/A | N/A |
| release-it.mini.md | Selected | Broker dependency can fail, stall, or retry. | REL-01, REL-02 | Validate bounded timeout, retry, and duplicate safety. |
| data-intensive.mini.md | Selected | Event replay can duplicate writes if the consumer is not idempotent. | DI-01, DI-02 | Validate source of truth, replay, and idempotency behavior. |

- Keep the example scoped to event consumer behavior.
- Do not provision broker infrastructure.

## Completion Evidence

| AC | Status | Evidence |
|---|---|---|
| AC-01 | Covered | `pytest tests/test_event_consumer.py` passed with replay/idempotency scenario. |
| AC-02 | Covered | `pytest tests/test_event_consumer.py` passed with timeout/retry scenario. |
