---
name: run-sdd-harness
description: Run optional bounded SDD checks with explicit approval, TDD evidence and durable recovery.
---

# Skill: Run SDD Harness

## Required Inputs

Read the approved plan/spec, `tdd-evidence-contract.md`,
`engineering-quality-contract.md`, `harness-evidence-contract.md` and
`docs/tool-runtime.md`. Require Python 3.11+. Existing POSIX-only workflows
remain available; their claims must still satisfy the evidence policy.

## Workflow

1. Validate both canonical specs with the existing shell validator. Derive the
   execution projection from their AC/TDD table; preserve every required member.
2. Record the actual explicit human approval reference and projection digest.
   Never generate approval from an agent conclusion or successful validation.
3. Run `python .sdd-kit/tools/sdd-harness.py init {TICKET}` from the consumer.
4. Inspect `next`. Run `red --task {ID}` before changing behavior; inspect the
   specific failure. A failed command alone is insufficient.
5. Implement only approved scope, then run `green --task {ID}` and
   `verify --task {ID}`. Pure refactors use passing characterization for red.
   Non-executable tasks use the named manual review and verify only.
6. Append actual evidence to the changelog. QA/review examine both current
   source and evidence. `close` cannot waive uncovered work.

## Recovery and limits

Inspect `status` after interruption. Do not remove a writer lock while its owner
may be alive. After verifying no owner remains, retain the lock as incident
evidence before operator removal. `resume --reason` explicitly acknowledges
unknown side effects when abandoning a pending operation; captured evidence is
reconciled instead of replayed. Budgets do not reset. Changed scope requires a
new approved projection, never editing counters to continue.

This is cooperative control, not native hook parity or an OS sandbox. Agents
still need host permission boundaries. Preserve project Git/tracker restrictions.
