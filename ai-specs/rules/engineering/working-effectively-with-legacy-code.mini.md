# Working Effectively With Legacy Code: Mini

## When to use

Use when changing weakly tested code, unclear behavior, hidden dependencies,
hard-to-instantiate classes, framework-bound code, globals, statics, or runtime
setup that blocks local feedback.

## Primary bias to correct

Gain control before improving design. Characterize what must stay, create the
smallest useful seam, break the dependency that blocks feedback, make the
requested change, then leave the touched area more testable.

## Decision rules

- Treat untested or weakly tested areas as legacy risk.
- State the requested behavior change and the current behavior that must remain
  before editing.
- Add characterization tests or another explicit observation path when behavior
  is uncertain.
- Find the change point, check existing protection, create the smallest seam,
  break the blocking dependency, change behavior, then refactor locally.
- Prefer fast focused tests around the changed slice; use broader integration
  tests only when they are the safest first observation point.
- Break hidden inputs, hard outputs, hard construction, globals, statics,
  ambient context, framework callbacks, time, randomness, files, network, or
  database writes only where they block safe change.
- Keep behavior changes, structural refactoring, and cleanup separate.
- Give temporary seams or test-only dependency-breaking tricks a cleanup path.

## Trigger rules

- When behavior may be relied on despite looking wrong, characterize before
  changing semantics.
- When tests require excessive setup or a class cannot be instantiated cheaply,
  break the first real barrier.
- When time, randomness, environment, current user/request, files, network,
  process exits, database writes, messages, or logging block repeatable tests,
  wrap or inject that boundary.
- When a large method defeats local reasoning, find interception or pinch
  points and extract pure computation first.
- When rewrite feels tempting, choose the smallest sprout, wrap, seam,
  characterization, or refactoring step that makes today's change safer.

## Final checklist

- Was untested or weakly tested code treated as legacy risk?
- Were behavior delta and behavior-to-preserve stated?
- Was uncertain current behavior characterized or explicitly observed?
- Was the smallest useful seam chosen?
- Did dependency breaking reduce risk without expanding hidden dependencies?
- Is any temporary seam documented with a cleanup path?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| WELC-01 | Current behavior that must remain must be characterized or observed | characterization, current behavior, behavior to preserve | Validation Plan, QA |
| WELC-02 | The seam or dependency-breaking choice must be explicit | seam, dependency breaking, change point | Implementation Mapping, Review |
| WELC-03 | Temporary seams or test-only hooks must have cleanup guidance | temporary seam, cleanup path, test-only | Execution Notes, PR |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books working-effectively-with-legacy-code](https://github.com/ciembor/agent-rules-books/tree/main/working-effectively-with-legacy-code),
MIT licensed. Inspired by Working Effectively with Legacy Code concepts.
