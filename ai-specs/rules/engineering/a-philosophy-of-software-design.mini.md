# A Philosophy Of Software Design: Mini

## When to use

Use when module boundaries, interface shape, helper extraction, wrappers,
configuration knobs, hidden dependencies, or cognitive load are central to the
change.

## Primary bias to correct

Working code is not necessarily simple. A design is simpler when it hides
knowledge, lowers change amplification, and reduces the facts a maintainer must
hold at once.

## Decision rules

- Prefer deep modules: small semantic interfaces that hide meaningful internal
  complexity.
- Reject pass-through services, thin wrappers, and tiny split-outs that add
  names without hiding complexity.
- Design interfaces around what callers need to know, not how the
  implementation works.
- Hide volatile decisions, representations, protocols, storage shape, and edge
  handling inside the module that owns the knowledge.
- Pull complexity downward when it makes common callers simpler.
- Avoid flags, staged setup, temporal coupling, and configuration knobs unless
  they are part of the real domain contract.
- Use comments for interface contracts, invariants, rationale, and hidden
  decisions, not narration.
- Optimize only with evidence, and hide the optimization behind stable
  interfaces.

## Trigger rules

- When a change spreads across files, look for missing information hiding or a
  shallow module.
- When adding a helper, wrapper, facade, service, option, callback, or argument,
  prove that it hides more complexity than it adds.
- When an API forces callers to know ordering, storage, transport, caching,
  protocol, or setup details, redesign the interface before adding more caller
  ceremony.
- When comments explain confusing usage or exposed internals, move the missing
  contract to the interface or redesign the abstraction.

## Final checklist

- Did the change reduce the effort required to understand and modify the
  system?
- Does each new interface, helper, wrapper, option, and name hide enough
  complexity to justify itself?
- Are volatile decisions localized and caller-needed constraints documented?
- Did common cases become simpler while rare controls stayed out of the common
  path?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| APOSD-01 | Interface or module choices must explain complexity hidden from callers | information hiding, deep module, caller knowledge | Implementation Mapping, Review |
| APOSD-02 | New wrappers, helpers, services, or options must justify their existence | wrapper justification, helper boundary, cognitive load | Execution Notes, PR |
| APOSD-03 | Volatile decisions must be localized behind the owning module | volatile decision, representation hidden, localized knowledge | Validation Plan, QA |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books a-philosophy-of-software-design](https://github.com/ciembor/agent-rules-books/tree/main/a-philosophy-of-software-design),
MIT licensed. Inspired by A Philosophy of Software Design concepts.
