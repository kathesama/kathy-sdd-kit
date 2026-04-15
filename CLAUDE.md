# Claude Configuration

> Single source of truth: ai-specs/
> This file is the entry point for Claude Code in any project using kathy-sdd-kit.

@ai-specs/specs/base-standards.mdc
@ai-specs/specs/backend-standards.mdc
@ai-specs/specs/frontend-standards.mdc

## Project Context

Load project-specific context from:
@docs/doc_architecture.md

## Available Skills

- `/enrich-us [description]` -> Enrich a user story with acceptance criteria and edge cases
- `/plan-backend-ticket [ID]` -> Generate a backend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/plan-frontend-ticket [ID]` -> Generate a frontend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/validate-impl-spec [ID or path]` -> Run the structural validator for implementation specs
- `/verify-ac-enforcement` -> Verify that the kit still blocks AC coverage regressions
- `/develop-backend @[plan].md` -> Implement following the backend plan
- `/develop-frontend @[plan].md` -> Implement following the frontend plan
- `/write-pr-report @[IMPL].md` -> Generate PR description from spec

## Rules

- Never write code without a validated Implementation Spec
- Always follow TDD: RED -> GREEN -> REFACTOR
- Treat acceptance criteria as delivery contract items with explicit evidence
- All commits must follow Conventional Commits
- Keep PRs small and focused
