# Clean Code: Mini

## When to use

Use when readability, naming, local reasoning, function shape, comments, or test
clarity are material to the change.

## Primary bias to correct

Working code is not automatically clean code. A change is not ready if a reader
must reconstruct intent from hidden state, vague names, tangled control flow, or
comments that compensate for unclear structure.

## Decision rules

- Use one precise term per concept and prefer names that reveal intent.
- Keep routines focused, cohesive, and at one level of abstraction.
- Separate setup, validation, computation, and side effects when they represent
  different responsibilities.
- Avoid boolean flags, output parameters, hidden mutation, and grab-bag
  parameter lists.
- Keep the happy path visible; isolate error handling and cleanup without hiding
  required behavior.
- Prefer small behavior-bearing types or argument objects when primitive
  clusters carry domain meaning.
- Keep comments for rationale, external constraints, warnings, and non-obvious
  contracts. Do not narrate mechanics that clearer code could express.
- Treat tests as production code: deterministic, readable, and named after the
  behavior or contract they protect.
- Improve only the touched area and stop before cleanup expands beyond the
  ticket scope.

## Trigger rules

- When a comment explains ordinary control flow, improve names or structure
  before keeping the comment.
- When a routine mutates and answers, split the command from the query.
- When duplicated conditionals or primitive clusters recur, name the concept
  only if it reduces misuse or clarifies behavior.
- When framework, persistence, or vendor details leak into business behavior,
  move translation to a boundary.
- When cleanup starts spreading to unrelated modules, record a follow-up instead
  of widening the current change.

## Final checklist

- Can a reviewer follow the changed path locally?
- Do names and APIs carry intent without narration?
- Are mutation, side effects, and error handling visible at the right level?
- Did the change improve the touched area without broad cleanup?
- Do tests clearly protect the changed behavior or contract?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| CLC-01 | Naming, routine shape, or local readability is in scope | naming, readability, local reasoning, routine | Implementation Mapping, Review |
| CLC-02 | Mutation, side effects, or error handling affect clarity | side effect, mutation, error handling, happy path | Implementation Mapping, QA, Review |
| CLC-03 | Test clarity or comments are part of the change | test readability, behavior name, rationale comment | Validation Plan, QA |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books clean-code](https://github.com/ciembor/agent-rules-books/tree/main/clean-code),
MIT licensed. Inspired by Clean Code concepts.
