# Engineering Rule Packs

This directory contains optional technical rule packs for SDD planning,
implementation, QA, and review. They are not global instructions. Load them
only when the current ticket needs the specific lens.

Use `select-engineering-rules` before writing a plan, validating QA evidence,
or reviewing implementation changes that touch architecture, domain modeling,
data consistency, production reliability, or refactoring.

## Available Packs

| Pack | Use When |
|---|---|
| `clean-architecture.mini.md` | Dependency direction, ports, adapters, boundaries, and framework isolation matter. |
| `domain-driven-design.mini.md` | Business language, invariants, bounded contexts, or aggregates are central to the change. |
| `patterns-of-enterprise-application-architecture.mini.md` | Service layer, persistence pattern, transaction boundary, DTO, or integration pattern choices matter. |
| `refactoring.mini.md` | The task improves structure or requires preparatory cleanup before behavior changes. |
| `release-it.mini.md` | Production failure modes, overload, retries, deployment, or observability are in scope. |
| `data-intensive.mini.md` | Correctness depends on data ownership, consistency, events, jobs, caches, schemas, or projections. |

## Selection Rules

- Prefer one or two packs per ticket. Load more only when they materially reduce risk.
- Prefer DDD for business model questions and Clean Architecture for dependency direction questions.
- Prefer Patterns of Enterprise Application Architecture for concrete enterprise pattern choices.
- Add Data Intensive when writes, events, retries, caches, or derived views can diverge.
- Add Release It when external dependencies, jobs, queues, or critical production paths are touched.
- Add Refactoring when the change includes structural cleanup or legacy risk reduction.

## Attribution

These packs are adapted for `kathy-sdd-kit` from ideas and structure in
[ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books),
which is MIT licensed. They are lightweight working instructions for AI coding
agents, not official summaries of the referenced books.
