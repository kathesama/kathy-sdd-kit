# Implementing Domain-Driven Design: Mini

## When to use

Use when DDD decisions must become implementation details: aggregate boundaries,
domain events, repositories, application services, anti-corruption layers,
transactions, or integration with other bounded contexts.

## Primary bias to correct

Do not let infrastructure or integration convenience decide aggregate,
transaction, or domain-event boundaries.

## Decision rules

- Model aggregates around consistency boundaries, not object graphs.
- Keep invariants inside aggregate methods or construction paths.
- Keep application services thin: coordinate commands, transactions, ports, and
  policies already expressed by the domain.
- Use repositories for aggregate persistence boundaries, not arbitrary query
  dumping grounds.
- Use domain events for meaningful business facts; keep event names and payloads
  stable and explicit.
- Use anti-corruption layers when another context's model would otherwise leak
  inward.
- Choose eventual consistency deliberately when invariants cross aggregate or
  context boundaries.
- Validate commands, domain errors, event publication, transaction boundaries,
  and idempotency where relevant.

## Trigger rules

- When one transaction touches many aggregates, decide whether the invariant is
  local, eventual, or incorrectly modeled.
- When an application service contains business policy, move the policy into
  the domain model.
- When an event is emitted, verify the fact name, payload, ordering, replay, and
  consumer expectations.
- When integrating another context, add translation rather than spreading its
  names and statuses through the domain.

## Final checklist

- Are aggregate and transaction boundaries justified by invariants?
- Are application services orchestration-only?
- Are repositories and events aligned with domain concepts?
- Are anti-corruption translations explicit at context boundaries?
- Are consistency and idempotency expectations validated?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| IDDD-01 | Aggregate or transaction boundaries are changed | aggregate boundary, invariant, transaction | Implementation Mapping, Validation Plan |
| IDDD-02 | Domain events or eventual consistency are in scope | domain event, business fact, eventual consistency, idempotency | Implementation Mapping, QA, Review |
| IDDD-03 | External bounded contexts or anti-corruption are in scope | anti-corruption, translation, context boundary | Implementation Mapping, Review |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books implementing-domain-driven-design](https://github.com/ciembor/agent-rules-books/tree/main/implementing-domain-driven-design),
MIT licensed. Inspired by Implementing Domain-Driven Design concepts.
