# PRBAD-200 Implementation Spec

## Story Context

- **Story / Ticket**: PRBAD-200
- **Objective**: Provide an invalid PR content example for the SDD kit.
- **Related Technical Contract**: Example only.
- **SDD Kit Version**: 0.4.1

## Acceptance Criteria

| ID | Criterion | Validation Type | Source |
|---|---|---|---|
| AC-01 | Invalid PR content should fail when checked command has no evidence | automated_test | explicit |

## Completion Evidence

| AC | Status | Evidence |
|---|---|---|
| AC-01 | Covered | Validator negative fixture expects failure |
