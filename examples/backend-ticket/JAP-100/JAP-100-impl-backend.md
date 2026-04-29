# JAP-100 Backend Implementation Plan

## Story Context

- **Story / Ticket**: JAP-100
- **Objective**: Add a backend audit event publisher for completed exports.
- **Related Technical Contract**: Example only.
- **SDD Kit Version**: 0.4.1

## Related Work Items

| Key | Type | Status | Scope Decision | Plan Impact |
|---|---|---|---|---|
| JAP-100 | Parent | Ready for planning | In scope | Defines AC-01 and AC-02 |
| JAP-101 | Subtask | Ready for planning | In scope | JAP-101 maps to AC-02 validation |
| JAP-102 | Subtask | Done | No implementation impact | Documentation-only tracker cleanup |

## Scope

### In Scope

- Publish an audit event after successful export completion.
- Add validation for the published payload.

### Out of Scope

- Creating broker topics.
- Changing export API contracts.

## Acceptance Criteria

| ID | Criterion | Validation Type | Source |
|---|---|---|---|
| AC-01 | Export completion publishes an audit event | automated_test | explicit |
| AC-02 | JAP-101 event payload includes export ID, actor ID, and timestamp | automated_test | child work item |

## Implementation Mapping

| AC | Files / Modules | Planned Change | Risk Notes |
|---|---|---|---|
| AC-01 | `app/application/export_service.py`, `app/infrastructure/events/audit_publisher.py` | Publish audit event after successful export completion | Must not publish on failed export |
| AC-02 | `tests/test_export_audit.py` | Verify JAP-101 required payload fields | Timestamp should be deterministic in tests |

## Validation Plan

| AC | Test / Check | Command or Method | Expected Evidence |
|---|---|---|---|
| AC-01 | Export event test | `python -m pytest -q tests/test_export_audit.py` | Event published once after success |
| AC-02 | JAP-101 payload test | `python -m pytest -q tests/test_export_audit.py` | Payload includes export ID, actor ID, timestamp |

## Delivery Plan

1. Add failing audit publisher tests (`AC-01`, `AC-02`, `JAP-101`).
2. Implement event publisher port and adapter (`AC-01`).
3. Wire export service event publication (`AC-01`).
4. Validate payload fields from JAP-101 (`AC-02`, `JAP-101`).

## Execution Notes for Implementer

### Engineering Rule Packs

| Pack | Selection | Reason | Required Validation Impact |
|---|---|---|---|
| clean-architecture.mini.md | Not selected | Example follows existing event publisher conventions without a new boundary decision. | N/A |
| domain-driven-design.mini.md | Not selected | Example does not change domain language or invariants. | N/A |
| patterns-of-enterprise-application-architecture.mini.md | Not selected | Example does not introduce a persistence or transaction pattern choice. | N/A |
| refactoring.mini.md | Not selected | Example does not include structural cleanup. | N/A |
| release-it.mini.md | Not selected | Example excludes broker provisioning and production rollout behavior. | N/A |
| data-intensive.mini.md | Not selected | Example validates payload shape only and does not model retry, replay, or consistency semantics. | N/A |

- Use the existing export service event publisher conventions from the consuming repository.
- Keep JAP-101 payload validation scoped to export ID, actor ID, and timestamp.
- Do not create broker topics or change export API contracts in this example.

## Completion Evidence

| AC | Status | Evidence |
|---|---|---|
| AC-01 | Not Covered | Pending implementation approval |
| AC-02 | Not Covered | Pending implementation approval |
