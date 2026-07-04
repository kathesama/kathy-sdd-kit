---
name: select-engineering-rules
description: Select optional engineering rule packs for SDD planning, implementation, QA, or review when a task touches architecture, construction quality, readability, domain modeling, enterprise patterns, refactoring, production readiness, or data consistency.
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
| Naming, routine shape, comments, test readability | `clean-code.mini.md` |
| Construction discipline, defensive programming, debugging, tuning | `code-complete.mini.md` |
| Business language, invariants, bounded contexts, aggregates | `domain-driven-design.mini.md` |
| Subdomain classification, bounded-context fit, context mapping | `domain-driven-design-distilled.mini.md` |
| Aggregate boundaries, domain events, repositories, anti-corruption layers | `implementing-domain-driven-design.mini.md` |
| Service layer, persistence pattern, transactions, DTOs, remote boundaries | `patterns-of-enterprise-application-architecture.mini.md` |
| Module depth, information hiding, interface complexity, cognitive load | `a-philosophy-of-software-design.mini.md` |
| Structural cleanup, behavior-preserving change | `refactoring.mini.md` |
| Code smell diagnosis and specific refactoring technique choice | `refactoring-guru.mini.md` |
| Weakly tested legacy code, characterization, seams, dependency breaking | `working-effectively-with-legacy-code.mini.md` |
| Source-of-truth drift, reversible decisions, automation, feedback loops | `the-pragmatic-programmer.mini.md` |
| Timeouts, retries, overload, jobs, queues, deployment, observability | `release-it.mini.md` |
| Data ownership, consistency, events, replay, schema evolution, caches, projections | `data-intensive.mini.md` |

## Output

Add an `Engineering Rule Packs` table to the plan/spec `Execution Notes for
Implementer`, and preserve selected packs in QA, review, and PR evidence:

```md
### Engineering Rule Packs

| Pack | Selection | Reason | Active Obligations | Required Validation Impact |
|---|---|---|---|---|
| clean-architecture.mini.md | Not selected | No dependency boundary or adapter decision. | N/A | N/A |
| clean-code.mini.md | Not selected | No naming, routine-shape, comment, or local-readability risk. | N/A | N/A |
| code-complete.mini.md | Not selected | No construction, defensive-programming, debugging, or tuning risk. | N/A | N/A |
| domain-driven-design.mini.md | Selected | Order lifecycle invariants are in scope. | DDD-02 | Validate aggregate invariant behavior. |
| domain-driven-design-distilled.mini.md | Not selected | No subdomain, bounded-context, or context-mapping decision. | N/A | N/A |
| implementing-domain-driven-design.mini.md | Not selected | No tactical DDD implementation boundary or event decision. | N/A | N/A |
| patterns-of-enterprise-application-architecture.mini.md | Not selected | No enterprise application pattern choice. | N/A | N/A |
| a-philosophy-of-software-design.mini.md | Not selected | No module-depth, information-hiding, or interface-complexity decision. | N/A | N/A |
| refactoring.mini.md | Not selected | No behavior-preserving structural cleanup. | N/A | N/A |
| refactoring-guru.mini.md | Not selected | No code smell diagnosis or refactoring technique selection. | N/A | N/A |
| working-effectively-with-legacy-code.mini.md | Not selected | No weakly tested legacy seam or characterization risk. | N/A | N/A |
| the-pragmatic-programmer.mini.md | Not selected | No source-of-truth drift, reversibility, automation, or feedback-loop risk. | N/A | N/A |
| release-it.mini.md | Not selected | No production dependency failure mode. | N/A | N/A |
| data-intensive.mini.md | Selected | Event replay and consistency are in scope. | DI-02 | Validate idempotency and replay behavior. |
```

## Rules

- Prefer one or two packs. Use more only when each pack changes planning,
  validation, or review decisions.
- Record every available pack exactly once in the table.
- Use the exact filenames shown in the table; validators use them for traceability.
- Choose active obligations from the selected pack's `Enforcement Contract`.
- For every `Selected` pack, include the exact filename in `Implementation Mapping`,
  `Validation Plan`, or `Delivery Plan`.
- For every active obligation, include the exact obligation ID in `Implementation Mapping`,
  `Validation Plan`, or `Delivery Plan`.
- For every `Selected` pack, preserve the exact filename and related risk notes
  in QA, review, and PR content.
- For every active obligation, preserve the exact obligation ID and contract evidence
  in QA, review, and PR content.
- Prefer DDD for business model questions and Clean Architecture for dependency
  direction questions.
- Add Clean Code when naming, local readability, comments, routine shape, or
  test clarity materially affects review risk.
- Add Code Complete when construction discipline, trust-boundary validation,
  debugging, or performance tuning is in scope.
- Add Domain-Driven Design Distilled when the main risk is deciding whether a
  richer model, subdomain split, bounded context, or context map is warranted.
- Add Implementing Domain-Driven Design when aggregate, repository, domain
  event, transaction, eventual-consistency, or anti-corruption details are in
  scope.
- Prefer Patterns of Enterprise Application Architecture for concrete service,
  persistence, transaction, DTO, or remote boundary choices.
- Add A Philosophy of Software Design when an interface, module boundary,
  wrapper, helper, or abstraction could increase or reduce cognitive load.
- Add Refactoring Guru when the task explicitly diagnoses smells or chooses a
  behavior-preserving refactoring technique.
- Add Working Effectively with Legacy Code when tests are weak, behavior must
  be characterized, or seams/dependency breaking are needed before safe change.
- Add Data Intensive when data can diverge, replay, retry, lag, or evolve.
- Add Release It when production failure, overload, recovery, or observability
  matters.
- Add Refactoring when behavior preservation or characterization is part of the
  work.
- Add The Pragmatic Programmer when duplicated knowledge, irreversible
  decisions, weak automation, hidden assumptions, or feedback-loop quality
  matters.
- Do not use rule packs to override acceptance criteria, project ADRs, or root
  repository instructions.
- Output in English.
