---
name: select-engineering-rules
description: Select optional engineering rule packs for SDD planning, implementation, QA, or review when a task touches architecture, domain modeling, enterprise patterns, refactoring, production readiness, or data consistency.
---

# Skill: Select Engineering Rules

## Purpose

Choose the smallest useful set of engineering rule packs for the current SDD
task. Rule packs are optional technical lenses, not global instructions.

## Required Inputs

Read:

- `ai-specs/rules/engineering/README.md`
- the user request, story, implementation spec, or changed-file context
- relevant project architecture, ADRs, glossary, and standards

Load only the selected rule pack files from `ai-specs/rules/engineering/`.

## Selection Matrix

| Signal | Rule Pack |
|---|---|
| Dependency direction, ports, adapters, framework isolation | `clean-architecture.mini.md` |
| Business language, invariants, bounded contexts, aggregates | `domain-driven-design.mini.md` |
| Service layer, persistence pattern, transactions, DTOs, remote boundaries | `patterns-of-enterprise-application-architecture.mini.md` |
| Structural cleanup, legacy risk, behavior-preserving change | `refactoring.mini.md` |
| Timeouts, retries, overload, jobs, queues, deployment, observability | `release-it.mini.md` |
| Data ownership, consistency, events, replay, schema evolution, caches, projections | `data-intensive.mini.md` |

## Output

Add an `Engineering Rule Packs` note to the plan, QA report, review report, or
execution notes:

```md
## Engineering Rule Packs
- `domain-driven-design.mini.md`: selected because ...
- `data-intensive.mini.md`: selected because ...
```

If no pack applies, record:

```md
## Engineering Rule Packs
- None selected: no architecture, domain, data, refactoring, or production-readiness lens is needed for this task.
```

## Rules

- Prefer one or two packs. Use more only when each pack changes planning,
  validation, or review decisions.
- Prefer DDD for business model questions and Clean Architecture for dependency
  direction questions.
- Prefer Patterns of Enterprise Application Architecture for concrete service,
  persistence, transaction, DTO, or remote boundary choices.
- Add Data Intensive when data can diverge, replay, retry, lag, or evolve.
- Add Release It when production failure, overload, recovery, or observability
  matters.
- Add Refactoring when behavior preservation or characterization is part of the
  work.
- Do not use rule packs to override acceptance criteria, project ADRs, or root
  repository instructions.
- Output in English.
