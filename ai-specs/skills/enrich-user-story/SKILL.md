# Skill: Enrich User Story

## Purpose

Transform a raw or incomplete user story into a decision-closed spec ready for implementation planning. No open questions allowed in the output.

## Usage

```
/enrich-us [ticket-id or free description]
```

## Output

A enriched user story document saved to `ai-specs/changes/[ID]-enriched.md` containing:

- **User Story**: persona, goal, benefit (As a... I want... So that...)
- **Acceptance Criteria**: clear, testable, numbered list
- **Edge Cases**: minimum 3 identified boundary conditions
- **Technical Considerations**: relevant constraints or architectural notes
- **Out of Scope**: explicit exclusions
- **Definition of Done**: checklist aligned with base-standards.mdc

## Rules

- All decisions must be closed — no open questions allowed in output
- If a decision cannot be made without more info, ASK before generating
- Acceptance criteria must be measurable and testable
- Always include at least 3 edge cases
- Output must be in English
