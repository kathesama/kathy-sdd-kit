# Harness evaluation and promotion

The fixture inventory is `examples/harness-evals/scenarios.json`: ten families,
three fresh trials per family per variant, 60 scheduled trials. Each family
includes a positive control. Preserve the inventory digest before any tuning.

## Execution protocol

1. Preserve a canonical baseline source/fixture copy and SHA-256 manifest.
   Exclude .git, skill exposures, secrets and unrelated local data. Never use
   worktrees or run Git as part of a fixture trial.
2. Freeze candidate source, model, agent version, permissions, input, fixture
   digest, checks and grading rubric. Use disposable copies for each trial.
3. Verify an existing authenticated CLI and confinement with both positive and
   negative controls. An executable or successful text reply is insufficient.
   Stop when the existing runtime cannot perform permitted fixture work safely.
4. Execute sequentially: at most 60 attempts, 600 seconds each, 7200 seconds total.
   Never extend caps or weaken host policy to make a benchmark pass. Preserve
   all failed/interrupted outcomes; remaining trial IDs become unexecuted.
5. Grade actual artifacts and host traces independently of the agent's claim.
   Check per-member AC preservation, command/test chronology, unchanged test
   digests, approval binding, counters, recovery, and false closure. A model
   judgment or deterministic fixture test is not a live agent trial.
6. Import independently graded live receipts with `tools/evaluate-sdd-harness.py`.
   The tool validates identity, trace digests, shared configuration and limits;
   it aggregates supplied judgments, not source semantics. Its cooperative
   inputs are not authenticated host attestation.

## Receipt and report

Each executed receipt has id (`variant/family/1..3`), status
(passed/failed/interrupted), kind=live, first_pass, completed, omitted_ac, approval_bypass,
false_covered, tdd_bypass (booleans), interventions (integer), seconds, cost
(observed number or null), trace (host file path), trace_digest and
configuration_digest. Do not set unknown cost to zero. Preserve rubric/check
details in each host trace. Treat omitted trial IDs as unexecuted, never passed.

Run the reporter with `--results receipts.json --output report.json`. With a
blocked preflight use `--blocked-reason "observed reason" --output report.json`;
the report lists all 60 pending outcomes. Do not relabel preflight calls as trials.

Promotion needs all 60 executed receipts, zero candidate approval/TDD bypass or
false coverage, no per-family completion regression and no greater median human
interventions. A median runtime or measured cost increase above 20% requires an
explicit tradeoff decision. Three trials per family do not establish statistical
superiority; after tuning, use a separately frozen holdout.

The current upgrade keeps VERSION at 0.7.0 until its ticket's full promotion
evidence is available. Unit tests, coverage, platform execution and configured CI
are reported separately. A workflow file alone is not evidence that CI ran.

## Current local preflight

The local CLI 0.136.0 authenticated successfully outside the restricted tool
environment and returned a text smoke response. With workspace-write and apps,
plugins, hooks, browser, computer-use, memories and multi-agent features disabled,
its policy rejected even an inside-fixture shell write. No policy bypass was
attempted. The live pilot remains blocked by that positive-control failure.
The initial restricted `Not logged in` result was superseded by the authenticated
check; do not diagnose this as missing user credentials.
