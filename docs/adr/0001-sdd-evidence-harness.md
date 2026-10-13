# ADR 0001: Optional cooperative evidence harness

Status: accepted for implementation by the explicit approval of task-20260909-01.

## Context

Markdown validators establish structure, not observed behavior, approval identity
or test chronology. The approved upgrade requires TDD and design-quality evidence
while preserving the portable POSIX workflow.

## Decision

Use an optional Python 3.11+ standard-library controller. Keep evidence/state
rules pure and isolate process/filesystem operations. Persist versioned JSON,
atomic state, exclusive ownership and bounded checks. No service, database,
agent SDK or generic workflow engine is needed. Existing unmarked documents
remain structurally valid but cannot start contract-1 runs without migration.

The agent performs edits. The controller checks observed operations; it is not
an OS sandbox or authenticated human-approval system. A user able to rewrite
all inputs and records can forge cooperative evidence. Host restrictions and
independent review remain necessary for stronger trust.

## Consequences

Scope changes invalidate approval. Interrupted operations remain unknown until
explicit recovery. No missing runtime evidence becomes Covered. Release 0.7.0
depends on complete evaluation and platform evidence; blocked evaluation leaves
VERSION at 0.7.0. Scope and thresholds are defined in the approved ticket plan.
