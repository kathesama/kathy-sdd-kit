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
| `clean-code.mini.md` | Naming, local readability, routine shape, comments, or test clarity matter. |
| `code-complete.mini.md` | Construction discipline, data representation, defensive programming, debugging, or tuning matter. |
| `domain-driven-design.mini.md` | Business language, invariants, bounded contexts, or aggregates are central to the change. |
| `domain-driven-design-distilled.mini.md` | Lightweight DDD scoping, subdomains, bounded contexts, or context mapping need clarification. |
| `implementing-domain-driven-design.mini.md` | Aggregate boundaries, domain events, repositories, anti-corruption layers, or DDD transactions matter. |
| `patterns-of-enterprise-application-architecture.mini.md` | Service layer, persistence pattern, transaction boundary, DTO, or integration pattern choices matter. |
| `a-philosophy-of-software-design.mini.md` | Module depth, information hiding, interface complexity, or cognitive load matters. |
| `refactoring.mini.md` | The task improves structure or requires preparatory cleanup before behavior changes. |
| `refactoring-guru.mini.md` | The task diagnoses code smells or chooses a specific refactoring technique. |
| `working-effectively-with-legacy-code.mini.md` | The task changes weakly tested legacy code and needs characterization, seams, or dependency breaking. |
| `the-pragmatic-programmer.mini.md` | Source-of-truth drift, reversibility, automation, assumptions, or feedback-loop quality matter. |
| `release-it.mini.md` | Production failure modes, overload, retries, deployment, or observability are in scope. |
| `data-intensive.mini.md` | Correctness depends on data ownership, consistency, events, jobs, caches, schemas, or projections. |

## Selection Rules

- Prefer one or two packs per ticket. Load more only when they materially reduce risk.
- Prefer DDD for business model questions and Clean Architecture for dependency direction questions.
- Prefer Clean Code when local readability or naming is the main review risk.
- Prefer Code Complete when construction, defensive checks, debugging, or tuning discipline is the main risk.
- Prefer DDD Distilled when the main decision is whether and where DDD should apply.
- Prefer Implementing DDD when tactical DDD choices must become code, transactions, or events.
- Prefer Patterns of Enterprise Application Architecture for concrete enterprise pattern choices.
- Prefer A Philosophy of Software Design for module-boundary and interface
  complexity questions.
- Prefer Refactoring Guru when smell diagnosis and technique selection are the
  main risk.
- Prefer Working Effectively with Legacy Code when safety depends on
  characterization tests, seams, or breaking hard dependencies.
- Add Data Intensive when writes, events, retries, caches, or derived views can diverge.
- Add Release It when external dependencies, jobs, queues, or critical production paths are touched.
- Add Refactoring when the change includes structural cleanup or legacy risk reduction.
- Add The Pragmatic Programmer when duplicated knowledge, irreversible decisions,
  missing automation, or weak feedback loops raise delivery risk.

## Attribution

These packs are adapted for `kathy-sdd-kit` from ideas and structure in
[ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books),
which is MIT licensed. They are lightweight working instructions for AI coding
agents, not official summaries of the referenced books.
