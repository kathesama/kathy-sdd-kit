# Refactoring Guru: Mini

## When to use

Use when existing code has named smells, refactoring technique choice matters,
or cleanup scope must stay behavior-preserving and tightly bounded.

## Primary bias to correct

Refactoring is not generic cleanup or pattern application. It is a
smell-driven, behavior-preserving treatment with verification and a stop
condition.

## Decision rules

- Diagnose the smell before choosing a technique: symptom, maintenance cost,
  scope, expected cleaner state, verification path, and stop condition.
- Prefer the smallest treatment that directly reduces the diagnosed smell.
- Keep behavior changes separate from structural edits whenever practical.
- Use known moves such as extract, inline, move, rename, parameter object,
  preserve whole object, hide delegate, replace conditional, or replace
  inheritance with delegation when they match the smell.
- Check public compatibility, state flow, construction paths, side effects,
  ordering, and invariants before extraction, movement, or algorithm changes.
- Stop when the named smell is gone or materially reduced. Record new smells as
  follow-up unless they block the current change.
- Avoid speculative abstractions, mechanical pattern use, and cleanup that keeps
  expanding beyond the diagnosed smell.

## Trigger rules

- When a method needs scrolling, comments, or local-state reconstruction,
  consider extraction or temp/query simplification.
- When a class has multiple reasons to change, consider extracting ownership
  before adding more behavior.
- When primitives, arrays, magic numbers, or type codes carry meaning, model the
  concept only if the model adds validation, naming, behavior, or safer
  variation handling.
- When client code navigates object chains, move behavior closer to the data or
  hide the delegate without adding pure forwarding.
- When deleting dead or speculative code, verify external, generated,
  reflected, serialized, plugin-facing, framework, and test-only reachability.

## Final checklist

- Is the change clearly refactoring, feature work, or bug fixing?
- Which smell was diagnosed, and what cost did it create?
- Was the smallest suitable treatment used before riskier structure?
- Did behavior stay preserved under relevant checks?
- Did the change avoid speculative abstraction and mechanical pattern use?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| RFG-01 | The targeted smell and chosen treatment must be named | code smell, treatment, refactoring technique | Implementation Mapping, Review |
| RFG-02 | Behavior preservation must have a verification path | behavior preserved, relevant checks, no behavior change | Validation Plan, QA |
| RFG-03 | Cleanup scope must stop at the diagnosed smell | stop condition, scope boundary, follow-up smell | Execution Notes, PR |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books refactoring-guru](https://github.com/ciembor/agent-rules-books/tree/main/refactoring-guru),
MIT licensed. Inspired by Refactoring.Guru concepts.
