# Domain-Driven Design: Mini

## When to use

Use when the hard part is understanding, naming, and protecting complex
business behavior rather than arranging technical layers.

## Primary bias to correct

Do not let tables, controllers, DTOs, or ORM convenience define the domain
model.

## Decision rules

- Use DDD where the domain needs a deep model; do not add ceremony to simple CRUD.
- Start with language, scenarios, decisions, and invariants before choosing tactical patterns.
- Keep one ubiquitous language per bounded context.
- Make bounded contexts explicit when the same term has different meanings.
- Protect invariants inside entities, value objects, and small aggregates with valid construction.
- Use repositories, factories, domain services, specifications, and domain events only when they express domain meaning.
- Keep application services focused on orchestration, not business policy.
- Translate foreign models at context and infrastructure boundaries.

## Trigger rules

- When a business term is overloaded, refine the language before extending the model.
- When one transaction wants to touch many objects, decide whether the invariant is local, eventual, or split across contexts.
- When persistence or transport shapes dictate the model, reassert the domain boundary.
- When application services accumulate policy decisions, name the missing domain concept or invariant.

## Final checklist

- Is the model driven by domain language instead of storage shape?
- Are context boundaries explicit where meanings diverge?
- Are invariants protected inside the model?
- Is richer modeling reserved for the core domain?

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books domain-driven-design](https://github.com/ciembor/agent-rules-books/tree/main/domain-driven-design),
MIT licensed. Inspired by Domain-Driven Design concepts.
