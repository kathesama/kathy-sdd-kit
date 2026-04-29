# Clean Architecture: Mini

## When to use

Use when a change depends on keeping business policy independent from
frameworks, databases, transports, SDKs, or UI details.

## Primary bias to correct

Do not let framework convenience or adapter shape become the system
architecture.

## Decision rules

- Keep dependencies pointing inward toward policy and use cases.
- Keep domain code free of HTTP, ORM, queue, framework, and vendor payload types.
- Put orchestration, transactions, and port calls in the application layer.
- Keep adapters responsible for translation between external shapes and core models.
- Treat databases, frameworks, SDKs, mailers, queues, and storage as replaceable details.
- Define the use case boundary before wiring delivery or persistence details.
- Prefer feature-oriented boundaries when they keep the use case visible.
- Test core policy without real infrastructure; test adapters where translation or integration is the risk.

## Trigger rules

- When framework or ORM types appear in domain or use-case code, move translation outward.
- When a controller, handler, or job carries business rules, move policy inward.
- When adding an external dependency, add a port if the core would otherwise learn vendor details.
- When a shortcut bypasses a boundary, repair the boundary instead of normalizing the shortcut.

## Final checklist

- Could the core behavior survive replacing database, UI, or framework details?
- Is the use case visible as a plain input/output boundary?
- Do dependencies still point toward policy?
- Are risky integrations isolated to adapters or infrastructure code?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| CA-01 | Dependency direction or boundary risk is in scope | dependency, inward, boundary, port, adapter | Implementation Mapping, Review |
| CA-02 | Framework or vendor details may leak into core policy | framework, vendor, infrastructure, adapter | Implementation Mapping, QA, Review |
| CA-03 | A use case boundary is added or changed | use case, input, output, application layer | Implementation Mapping, Validation Plan |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books clean-architecture](https://github.com/ciembor/agent-rules-books/tree/main/clean-architecture),
MIT licensed. Inspired by Clean Architecture concepts.
