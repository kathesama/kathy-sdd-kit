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

- Include the parent work item and any linked child work items, subtasks, checklist items, or implementation tasks.
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

## Completion Evidence

| AC | Status | Evidence |
|---|---|---|
| AC-01 | Covered |  |

Allowed statuses:

- `Covered`
- `Partial`
- `Not Covered`

Rules:

- Do not mark the task done unless every explicit AC has final evidence
- If an AC is `Partial` or `Not Covered`, record the blocker or explicit decision
