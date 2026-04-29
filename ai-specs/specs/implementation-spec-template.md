# Implementation Spec Template

## Story Context

- **Story / Ticket**:
- **Objective**:
- **Related Technical Contract**:
- **SDD Kit Version**:

## Related Work Items

| Key | Type | Status | Scope Decision | Plan Impact |
|---|---|---|---|---|
|  |  |  |  |  |

Rules:

- The parent ticket itself must appear as a row.
- Include the parent work item and any linked child work items, subtasks, checklist items, or implementation tasks.
- `Scope Decision` must be exactly one of: `In scope`, `Out of scope`, `No implementation impact`, `Blocked`.
- In-scope child work items that refine behavior must map to an AC, validation item, or documented blocker.
- Administrative-only child work items may be listed with `No implementation impact`.
- If a child work item is out of scope, record the explicit reason.

## Scope

### In Scope

- 

### Out of Scope

- 

## Acceptance Criteria

| ID | Criterion | Validation Type | Source |
|---|---|---|---|
| AC-01 |  | automated_test | explicit |

Allowed validation types:

- `automated_test`
- `manual_check`
- `storybook_check`
- `runtime_check`
- `review_check`

Rules:

- Every explicit AC from the story must appear here
- Every inferred AC must be clearly labeled as `inferred`
- Never merge distinct expectations into one AC if they require different validation

## Implementation Mapping

| AC | Files / Modules | Planned Change | Risk Notes |
|---|---|---|---|
| AC-01 |  |  |  |

Rules:

- Every AC must appear at least once in this table
- If an AC requires multiple files or steps, keep them grouped under the same AC

## Validation Plan

| AC | Test / Check | Command or Method | Expected Evidence |
|---|---|---|---|
| AC-01 |  |  |  |

Rules:

- Every AC must have at least one validation entry
- If validation is manual, describe the exact verification method
- If validation cannot be automated, state why

## Delivery Plan

1. Step name (`AC-01`, `AC-02`)
2. Step name (`AC-03`)

Rules:

- Every step must reference the AC IDs it covers
- Plan steps must be concrete enough to execute without reinterpretation

## Execution Notes for Implementer

### Engineering Rule Packs

| Pack | Selection | Reason | Required Validation Impact |
|---|---|---|---|
| clean-architecture.mini.md | Not selected | No dependency boundary or adapter decision. | N/A |
| domain-driven-design.mini.md | Not selected | No domain language, invariant, aggregate, or bounded-context change. | N/A |
| patterns-of-enterprise-application-architecture.mini.md | Not selected | No enterprise application pattern choice. | N/A |
| refactoring.mini.md | Not selected | No behavior-preserving structural cleanup. | N/A |
| release-it.mini.md | Not selected | No production dependency, overload, deployment, or observability risk. | N/A |
| data-intensive.mini.md | Not selected | No data ownership, consistency, event, cache, projection, or schema-evolution risk. | N/A |

Rules:

- Capture implementation-critical context that is not obvious from the ACs.
- Record all six engineering rule packs exactly once.
- `Selection` must be exactly `Selected` or `Not selected`.
- If a pack is `Selected`, `Reason` must explain why and `Required Validation Impact` must name the validation it adds.
- If a pack is `Selected`, reference the pack filename in `Implementation Mapping`, `Validation Plan`, or `Delivery Plan`.
- Include exact package/module targets when names are abbreviated elsewhere.
- Identify pilot services, first migration targets, feature flags, adapters, or runtime handoff assumptions.
- Record explicit non-goals that prevent scope creep during execution.
- Do not duplicate the Delivery Plan; this section should reduce ambiguity for a different agent executing the spec later.

## Completion Evidence

| AC | Status | Evidence |
|---|---|---|
| AC-01 | Not Covered | Pending implementation after approval. |

Allowed statuses:

- `Covered`
- `Partial`
- `Not Covered`

Rules:

- Do not mark the task done unless every explicit AC has final evidence
- During planning, use `Not Covered` with evidence such as `Pending implementation after approval.`
- Do not use unchecked placeholders such as `[Pending]`, `Todo`, `Done`, `N/A`, or `-`
- If an AC is `Partial` or `Not Covered`, record the blocker or explicit decision

## Validator Contract

The structural validator matches headings and enum values literally. Do not
rename these sections or replace them with synonyms.

Required level-2 sections:

1. `## Related Work Items`
2. `## Acceptance Criteria`
3. `## Implementation Mapping`
4. `## Validation Plan`
5. `## Delivery Plan`
6. `## Execution Notes for Implementer`
7. `## Completion Evidence`

Do not use alternate section names such as `AC-to-Implementation Mapping`,
`Delivery Roadmap`, `Completion Evidence Template`, or `Related Tickets`.
