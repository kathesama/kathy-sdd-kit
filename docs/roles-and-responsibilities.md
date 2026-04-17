# SDD Roles And Responsibilities

This document defines the human and agent roles used by the kit. A single
person may play multiple roles, but the responsibilities stay separate.

## Human Approver

- Owns the final product and scope decision.
- Reviews the planning gate summary.
- Answers exactly one planning gate decision:
  - `approve` to execute the plan.
  - `change` to revise the plan/spec before execution.
  - `deny` to stop execution.
- Decides whether `Partial`, `Not Covered`, `Blocked`, or out-of-scope items are acceptable.

## Analyst / Planner Agent

- Resolves `{TICKET}` according to the consuming project's ticket policy.
- Reads the parent work item and linked child work items when available.
- Produces the implementation plan, companion spec, and changelog before code changes.
- Maps every in-scope child work item to ACs, validation, or blockers.
- Runs `validate-impl-spec.sh`.
- Stops at the approval gate.

## Developer Agent

- Starts only after explicit `approve`.
- Reads the approved plan and companion spec before editing.
- Implements in the order described by the Delivery Plan.
- Keeps changes scoped to the ticket.
- Uses TDD or the closest practical validation loop.
- Appends factual changelog entries after subtasks.
- Updates Completion Evidence only with real validation results.

## QA Agent

- Validates implementation evidence against the parent ticket, in-scope child work items, and ACs.
- Checks behavior, edge cases, regressions, and validation gaps.
- Produces `QA-{TICKET}.md`.
- Does not approve code quality by itself; QA focuses on delivery contract and behavior.

## Code Review Agent

- Reviews correctness, reliability, security, architecture, maintainability, tests, and PR readiness.
- Prioritizes actionable findings with file/line evidence.
- Does not duplicate QA; references QA results and focuses on technical risk.
- Produces or updates `REVIEW-{TICKET}.md`.

## PR Report Agent

- Generates `PR-{TICKET}.md` from local `.ai-specs/changes/{TICKET}/` evidence.
- Preserves the consuming repository's PR template.
- Does not invent commands, CI status, commits, screenshots, links, or AC evidence.
- Runs `validate-pr-content.sh` before claiming PR content is ready.

## Boundaries

- Validators check structure and evidence consistency.
- QA checks behavior against the delivery contract.
- Code review checks technical quality.
- The human approver decides scope and release readiness.

Do not use one role's output as a substitute for another. A passing validator is
not QA, and QA is not code review.
