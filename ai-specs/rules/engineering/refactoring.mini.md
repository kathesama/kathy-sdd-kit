# Refactoring: Mini

## When to use

Use when improving structure without intending to change observable behavior,
or when preparatory cleanup directly lowers the risk of the requested change.

## Primary bias to correct

Do not hide redesign, rewrite, and behavior change inside one uncontrolled
patch.

## Decision rules

- Preserve observable behavior during refactoring.
- Keep behavior changes and structural cleanup distinct whenever practical.
- Work in small, verifiable steps instead of broad rewrites.
- Establish a safety net first: tests, characterization checks, types, assertions, or another credible verification path.
- Refactor the smell that blocks the current change, such as duplication, long functions, hidden dependencies, sprawling conditionals, or primitive obsession.
- Prefer known moves: rename, extract, move, inline, simplify, split phase, and data-shape improvements.
- Stop when the requested change is safe and clear.

## Trigger rules

- When a patch mixes behavior and cleanup, split the intent unless the context makes that impossible.
- When a risky area lacks tests, characterize current behavior before major structural edits.
- When a conditional tree keeps growing, consider extraction, split phase, polymorphism, or data-driven structure.
- When the urge is to rewrite, first find the smallest transformation that restores control.

## Final checklist

- Is observable behavior preserved?
- Was each step small and verified?
- Did the refactor address the smell that affects this task?
- Did cleanup stop at the useful point?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| REF-01 | Existing behavior must be characterized before structural change | characterization, safety net, current behavior | Validation Plan, QA |
| REF-02 | Observable behavior must be preserved | behavior preserved, observable behavior, no behavior change | QA, PR |
| REF-03 | Refactor scope needs an explicit boundary | structural cleanup, refactor scope, small step | Implementation Mapping, Review |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books refactoring](https://github.com/ciembor/agent-rules-books/tree/main/refactoring),
MIT licensed. Inspired by Refactoring concepts.
