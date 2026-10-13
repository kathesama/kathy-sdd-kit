# TDD Evidence Contract

SDD Evidence Contract: 1

New plans and their companion specs contain the literal marker above and an
identical `### TDD and Design Contract` table, with one row per AC:

| AC | Applicability | Test identity | Expected RED | Design review | Reason |
|---|---|---|---|---|---|
| AC-01 | test-first | Named test and test file | Behavior-specific assertion | Applicable SOLID principles | New observable behavior |

Applicability is `test-first`, `characterization`, or `non-executable`.
Behavior changes and bug fixes require an observed failure before implementation,
followed by the same test passing and a passing regression check after refactoring.
Derive assertions from the approved AC and independent expected behavior, never
merely mirror the implementation. Existing code still benefits from regression
tests; tests added after implementation are not evidence of a test-first sequence.

A RED must identify the intended test and expected failure. Syntax, setup,
environment, missing runner, unrelated import and fixture errors are not a RED.
A missing test runner blocks testable behavior until setup is repaired. Test-file
digests must match between RED and GREEN. Changed or weakened assertions require
a new qualifying RED before the corresponding implementation. Replaying old code
later is retrospective evidence and cannot establish original chronology.

Pure refactoring uses passing characterization before and after the change.
Documentation and purely visual changes use named non-executable review with a
reason; frontend interactions, validation and state transitions remain test-first.
Manual observation cannot satisfy a required executable check. Missing evidence
is a blocker, not a waiver or a coverage percentage.

Record actual command, time, test identity, inputs, outcome and observer in the
ticket changelog. Pre-controller bootstrap output remains labeled as such.
See [harness-evidence-contract.md](harness-evidence-contract.md) for optional
machine records and [engineering-quality-contract.md](engineering-quality-contract.md)
for design review. Structural validation alone never proves TDD.
