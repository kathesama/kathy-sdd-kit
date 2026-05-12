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
- **Acceptance Criteria**: clear, testable, numbered list with stable IDs (`AC-01`, `AC-02`, ...)
- **Edge Cases**: minimum 3 identified boundary conditions
- **Technical Considerations**: relevant constraints or architectural notes
- **Out of Scope**: explicit exclusions
- **Definition of Done**: checklist aligned with base-standards.mdc

Each acceptance criterion must include:

- **ID**: stable identifier (`AC-01`, `AC-02`, ...)
- **Criterion**: concise, testable statement
- **Validation Type**: one of `automated_test`, `manual_check`, `storybook_check`, `runtime_check`, `review_check`
- **Source**: `explicit` when copied from the ticket, `inferred` when derived to make the story implementable

## Requirement Quality Scan

Before writing the enriched story, perform a short clarification scan inspired
by spec-kit's specification quality checks. Ask only when ambiguity blocks a
safe, decision-closed output.

Check:

- user roles and permissions
- primary user journeys and independent testability
- error, empty, loading, permission, and boundary states
- accessibility and localization notes for UI work
- security and privacy requirements when data, auth, ownership, or sensitive
  display is involved
- performance, reliability, observability, and scale expectations when they
  materially affect validation
- external dependencies and failure modes
- terminology consistency with project docs or glossary
- unresolved placeholders such as `TODO`, `TBD`, `???`, or
  `[NEEDS CLARIFICATION]`

If a decision can be made safely from project context or common defaults, record
it under assumptions or technical considerations. If multiple reasonable
interpretations would change scope, validation, security, privacy, or UX, ask
before generating the enriched story.

## Rules

- All decisions must be closed — no open questions allowed in output
- If a decision cannot be made without more info, ASK before generating
- Acceptance criteria must be measurable and testable
- Acceptance criteria are a delivery contract, not background context
- Always include at least 3 edge cases
- Never merge multiple distinct expectations into one AC if they need different validation
- If an AC is inferred, label it as inferred explicitly
- Do not let generic adjectives such as "fast", "secure", "robust",
  "intuitive", or "scalable" survive unless they are converted into measurable
  acceptance criteria, assumptions, or explicit validation notes
- Output must be in English
