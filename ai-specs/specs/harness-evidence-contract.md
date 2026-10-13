# Harness Evidence Contract 1

The optional controller requires Python 3.11+ and only the standard library.
The POSIX structural validators remain independent of Python. The controller
does not generate code, grant approval, authenticate a human, or sandbox edits.

## Preparation and authority

First validate the canonical plan/spec using `validate-impl-spec.sh`. Preserve
the `SDD Evidence Contract: 1` marker and identical TDD/design table. Derive
`harness/approved-plan.json` from those documents, review its exact checks and
write scope, and obtain explicit human approval of that projection. The
projection is not permission to add requirements missing from the source specs.

`approval.json` contains exactly schema (integer 1), decision (`approve`), role
(`human`), source (actual decision reference), and plan_digest (SHA-256 of canonical
projection JSON). Do not invent a source or default approval. Resuming an unchanged
run reuses this approval. Material edits require a newly approved run; retain the
old run and its evidence rather than resetting its counters.

## Projection fields

| Field | Contract |
|---|---|
| schema | Integer 1 |
| anchor | Canonical filesystem-safe ticket identity |
| specs | Nonempty list of member, plan, spec, semantic_digest objects |
| tasks | Ordered task objects; all required member/AC pairs represented |
| budgets | attempts, operations, seconds; positive integers, never booleans |

Each task contains exactly id, member, ac, mode, check, argv, cwd, tests, sources,
identity, failure, timeout. IDs are stable alphanumeric/hyphen/underscore strings.
Paths are explicit portable paths relative to the consumer root; no traversal,
absolute paths, symlink/junction escapes, duplicate file paths or glob expansion.
Declare every source/test/config input that can influence a check. Undeclared
inputs are a cooperative limitation to review, not a complete dependency snapshot.

Mode is test-first, characterization or non-executable. Identity and failure
match the canonical table exactly; use a descriptive passing baseline/review value
in the table for non-test-first work. argv is a reviewed argument array (shell=False),
cwd is constrained to the consumer root, tests and sources are nonempty path lists.
Inline shell command strings are rejected; reviewed `sh path/to/script.sh` is valid.
For new files, prepare an empty scaffold as the declared input before the first
check; the failing assertion must still target missing behavior, not setup errors.

Use `sdd_harness.cli.semantic` and `sdd_harness.evidence.digest` to compute binding.
Semantic binding excludes the title and Completion Evidence section only;
scope, ACs, related work, check mapping and execution decisions remain bound.
Each member reference names its canonical plan/spec pair. Related in-scope members
must all appear in the projection; an omitted child blocks initialization.

## Observation fields

| Fields | Contract |
|---|---|
| schema | Integer 1 |
| run, member, task, ac, check, operation | Stable identities bound to pending operation |
| phase | red, green, verify |
| kind | machine, manual, inference, assertion |
| observer | runner for machine; named source for manual |
| argv, cwd | Exact approved check and working directory |
| test_digest, source_digest, plan_digest | SHA-256 of declared inputs/approved intent |
| started, finished, duration | Finite nonnegative seconds, consistent chronology |
| exit_code, outcome | Actual status; outcome passed, failed, unknown |
| test_identity, expected_failure | Approved test and specific assertion signature |
| output, output_digest | Bounded sanitized output and matching SHA-256 |
| retrospective | Boolean; true cannot satisfy original TDD chronology |

Unknown fields, duplicate JSON keys and nonfinite numbers are rejected. Typed
validation is implemented in `tools/sdd_harness/evidence.py` and `state.py`.
Records and state persist as `{payload, digest}` envelopes. SHA-256 protects
against accidental/stale edits; it is not a signature against a writer able to
modify all files. Keep independent host evidence when stronger trust is required.

## Execution and recovery

Commands: init, status, next, red, green, verify, resume, close. Checks require
`--task ID`; use `--root PATH` only for the approved consumer root. Default budgets
are three check attempts per task, 30 mutations per run and 1800 seconds. Reserve
an operation for closure and recovery. Each started check consumes an attempt;
timeouts and interrupted checks count. Recovery never resets attempts or deadline.
Status/next are inspection only, not permission to proceed past a blocker.

The default timeout is 120 seconds. Persist at most 64 KiB per output stream;
drain larger streams without buffering them. Known secret patterns are scrubbed
before persistence, but redaction is best-effort: never put secrets in argv or
fixtures. Timeouts yield unknown, never a qualifying RED. Windows uses a suspended
process assigned to a kill-on-close Job Object before resuming; POSIX uses a
dedicated process group. These mechanisms bound cleanup, not filesystem access.

An exclusive writer.lock prevents concurrent mutation. Atomic replacement stores
pending operation and counters before launch. A crash leaves pending/unknown work.
On resume, reconcile captured evidence by operation/digest; otherwise inspect side
effects and use `--reason` to abandon explicitly. Never blindly replay a check or
break an existing lock while the owner may still be alive. A dead-owner lock needs
operator investigation and removal, preserving the incident record.

For non-executable review, the first tests file is JSON containing kind=manual,
observer, source and verdict=passed. Its approved argv validates the artifact;
manual evidence still cannot satisfy an executable task. Inference/assertion
records may inform review but never replace a mandatory machine observation.

Closure requires every task verified and current source/test digests matching the
final evidence. Scope removal requires human reapproval; no waive operation exists.
Coverage reports, convergence and a green-only run cannot establish test-first
chronology. Before the controller exists, preserve bootstrap output as external
observations; never manufacture controller events to backfill a history.
