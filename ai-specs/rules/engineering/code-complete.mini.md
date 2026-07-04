# Code Complete: Mini

## When to use

Use when construction discipline matters: implementation planning, production
code changes, debugging, routine design, data representation, defensive
programming, or evidence-based tuning.

## Primary bias to correct

Construction quality is deliberate. Do not treat "it runs once" as complete
when requirements, risk, boundaries, data meaning, error policy, or validation
remain unclear.

## Decision rules

- Before larger construction work, confirm requirements, architecture fit,
  major risks, coding conventions, data representation, error policy, reuse,
  integration, and validation approach.
- Build small validated slices when uncertainty remains.
- Optimize for human readers: clear names, local reasoning, visible control
  flow, explicit data meaning, and consistent conventions.
- Keep routines cohesive, hard to misuse, and small at the interface.
- Make units, ranges, ownership, status, sentinel values, and precision visible
  through names, types, constants, or structures.
- Validate input at trust boundaries; use assertions for programmer
  assumptions and recoverable errors for expected external failures.
- Keep control flow simple enough to inspect: shallow nesting, clear loop
  conditions, named predicates, and explicit exit behavior.
- Use table-driven logic only when the table is clearer and validated against
  the rules it represents.
- Debug by reproducing, isolating, explaining, fixing, and verifying the root
  cause.
- Tune performance only against a target and fresh measurements.

## Trigger rules

- When coding starts from a proposed solution, restate success constraints and
  risks before implementation.
- When a routine is hard to name or has flag arguments, redesign the interface
  or split the routine.
- When data meaning is implicit, move it into types, constants, names, or
  structure.
- When a trust boundary is crossed, state what is validated, rejected,
  recovered from, asserted, and logged.
- When performance work starts without measurement, stop and define the target
  and baseline.

## Final checklist

- Are requirements, architecture fit, risks, conventions, and validation clear?
- Do names, routines, data, modules, comments, and layout reduce reader effort?
- Are inputs, errors, assertions, contracts, and impossible states deliberate?
- Is control flow simple enough to inspect?
- Are debugging, refactoring, integration, and tuning evidence-based?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| CDC-01 | Construction risk or implementation uncertainty is in scope | construction, requirements, risk, validated slice | Implementation Mapping, Delivery Plan |
| CDC-02 | Data representation, input validation, or error policy matters | data meaning, trust boundary, validation, error policy | Implementation Mapping, Validation Plan, QA |
| CDC-03 | Debugging or performance tuning is in scope | reproduce, root cause, measure, baseline, target | Validation Plan, Review |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books code-complete](https://github.com/ciembor/agent-rules-books/tree/main/code-complete),
MIT licensed. Inspired by Code Complete concepts.
