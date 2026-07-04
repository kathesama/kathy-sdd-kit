# Domain-Driven Design Distilled: Mini

## When to use

Use when the task needs lightweight DDD judgment: deciding whether a richer
model is warranted, naming bounded contexts, clarifying subdomains, or keeping
language aligned across teams and code.

## Primary bias to correct

Do not apply tactical DDD patterns before the domain, subdomain, bounded
context, and language problem is clear.

## Decision rules

- Separate core, supporting, and generic subdomains before choosing modeling
  effort.
- Keep bounded contexts explicit and small enough to preserve one language.
- Use context mapping when teams, systems, or models meet at a boundary.
- Prefer collaborative language discovery before inventing class names.
- Use aggregates, entities, value objects, domain events, repositories, or
  services only when they make the model clearer or safer.
- Keep integration contracts from smuggling another context's model into the
  current one.
- Avoid DDD ceremony for simple CRUD or generic utility behavior.

## Trigger rules

- When the same term means different things to different stakeholders, create
  or update a bounded-context note before coding.
- When a model feels overbuilt, check whether the behavior belongs to core,
  supporting, or generic subdomain work.
- When a foreign payload enters the domain, translate it at the boundary.
- When domain events are proposed, state the business fact they represent and
  the consistency expectation.

## Final checklist

- Is the subdomain classification explicit enough for the modeling effort?
- Does each bounded context keep one language?
- Are context boundaries and translations visible?
- Are tactical DDD patterns justified by behavior or invariants?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| DDDX-01 | Subdomain or bounded-context scope is in question | core subdomain, supporting subdomain, bounded context | Implementation Mapping, Review |
| DDDX-02 | Cross-context translation or integration is in scope | context map, translation, foreign model, boundary | Implementation Mapping, Validation Plan |
| DDDX-03 | Tactical DDD patterns are proposed | aggregate, value object, domain event, repository | Delivery Plan, Review |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books domain-driven-design-distilled](https://github.com/ciembor/agent-rules-books/tree/main/domain-driven-design-distilled),
MIT licensed. Inspired by Domain-Driven Design Distilled concepts.
