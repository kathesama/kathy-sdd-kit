# The Pragmatic Programmer: Mini

## When to use

Use when a task needs pragmatic delivery judgment: avoiding knowledge
duplication, keeping decisions reversible, making change easy, improving
feedback loops, or preventing accidental complexity.

## Primary bias to correct

Do not optimize for local convenience while spreading duplicated knowledge,
irreversible decisions, hidden assumptions, or weak feedback loops.

## Decision rules

- Keep knowledge single-sourced. Avoid duplicating rules across code, tests,
  docs, config, schemas, and generated artifacts without a synchronization path.
- Prefer reversible decisions when requirements or technology choices are still
  uncertain.
- Make assumptions explicit and validate the risky ones early.
- Use small automation or scripts when manual repetition can drift or hide
  errors.
- Keep interfaces narrow, observable, and easy to replace when the dependency is
  volatile.
- Use tracer-bullet slices to prove architecture, integration, and feedback
  loops before filling in breadth.
- Treat broken windows as scope signals: repair touched damage that raises the
  current change risk, but record unrelated repairs separately.
- Keep tests, logs, assertions, and diagnostics close to the risks they reduce.

## Trigger rules

- When the same rule appears in multiple places, identify the source of truth
  and synchronization path.
- When a decision is expensive to reverse, document the trigger and mitigation.
- When feedback is slow or manual, add the smallest reliable check.
- When a dependency is volatile, hide it behind the narrowest useful boundary.
- When a task starts expanding, separate current risk repair from future cleanup.

## Final checklist

- Is knowledge duplicated, or is there a clear source of truth?
- Are costly decisions reversible or explicitly justified?
- Were risky assumptions validated early?
- Did automation reduce drift or manual error where it mattered?
- Is the feedback loop close enough to the change risk?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| TPP-01 | Duplicate knowledge or source-of-truth drift is in scope | source of truth, duplication, synchronization | Implementation Mapping, Review |
| TPP-02 | Reversible decision or uncertainty management matters | reversible, assumption, tracer bullet, mitigation | Delivery Plan, Review |
| TPP-03 | Feedback loop, automation, or diagnostics are part of the change | feedback loop, automation, diagnostics, drift | Validation Plan, QA |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books the-pragmatic-programmer](https://github.com/ciembor/agent-rules-books/tree/main/the-pragmatic-programmer),
MIT licensed. Inspired by The Pragmatic Programmer concepts.
