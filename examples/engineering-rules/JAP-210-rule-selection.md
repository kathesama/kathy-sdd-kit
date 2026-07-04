# Engineering Rule Pack Selection Example: JAP-210

## Ticket Context

`JAP-210` adds an outbox-backed event publication flow for an order lifecycle
change. The service writes the order state, persists an outbox record, and a
background job publishes events to a broker.

## Engineering Rule Packs

| Pack | Selection | Reason | Active Obligations | Required Validation Impact |
|---|---|---|---|---|
| clean-architecture.mini.md | Not selected | Existing implementation spec already constrains ports and adapters; no new dependency direction risk is introduced. | N/A | N/A |
| clean-code.mini.md | Not selected | No naming, routine-shape, comment, or local-readability risk. | N/A | N/A |
| code-complete.mini.md | Not selected | No construction, defensive-programming, debugging, or tuning risk. | N/A | N/A |
| domain-driven-design.mini.md | Selected | Order lifecycle transitions are business concepts with invariants that should not be modeled from table shape alone. | DDD-02 | Validate lifecycle invariant behavior in the domain model. |
| domain-driven-design-distilled.mini.md | Not selected | No subdomain, bounded-context, or context-mapping decision. | N/A | N/A |
| implementing-domain-driven-design.mini.md | Not selected | No tactical DDD implementation boundary or event decision. | N/A | N/A |
| patterns-of-enterprise-application-architecture.mini.md | Not selected | No new persistence pattern or transaction script/domain model choice is being made. | N/A | N/A |
| a-philosophy-of-software-design.mini.md | Not selected | No module-depth, information-hiding, or interface-complexity decision. | N/A | N/A |
| refactoring.mini.md | Not selected | No behavior-preserving structural cleanup is planned. | N/A | N/A |
| refactoring-guru.mini.md | Not selected | No code smell diagnosis or refactoring technique selection. | N/A | N/A |
| working-effectively-with-legacy-code.mini.md | Not selected | No weakly tested legacy seam or characterization risk. | N/A | N/A |
| the-pragmatic-programmer.mini.md | Not selected | No source-of-truth drift, reversibility, automation, or feedback-loop risk. | N/A | N/A |
| release-it.mini.md | Selected | The background publisher depends on a broker and must define timeout, retry, duplicate, and observability behavior. | REL-01, REL-02 | Validate timeout, retry bounds, duplicate safety, and observability evidence. |
| data-intensive.mini.md | Selected | The write path introduces retries, replay, event schemas, idempotency, and derived downstream state. | DI-01, DI-02, DI-03 | Validate source of truth, event replay, idempotency, and schema compatibility. |

## Implementation Spec Note

The implementation spec should copy the full table into `Execution Notes for
Implementer` and use selected pack filenames plus active obligation IDs in
`Implementation Mapping`, `Validation Plan`, or `Delivery Plan`:

- AC validation must include duplicate event delivery.
- AC validation must include event replay or publisher restart behavior.
- Risk notes must name the event source of truth and consistency boundary.
- QA, review, and PR content must preserve exact selected pack filenames and
  related risk evidence.
