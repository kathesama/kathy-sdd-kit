# Claude Configuration

> SDD framework source: `.sdd-kit/`
> Project-local SDD workspace: `.ai-specs/`
> This file complements the consuming project's root `CLAUDE.md`.

@.sdd-kit/ai-specs/specs/base-standards.mdc
@.sdd-kit/ai-specs/specs/backend-standards.mdc
@.sdd-kit/ai-specs/specs/frontend-standards.mdc

## Project Context

Load project-specific context from the consuming repository when present:

- Root `CLAUDE.md`
- `docs/doc_architecture.md`
- `docs/adr/`
- `docs/GLOSSARY.md`
- local package, build, test, and script configuration

The root `CLAUDE.md` should own project architecture and ADR context. This file
owns reusable SDD workflow guidance.

## Available Skills

- `/enrich-us [description]` -> Enrich a user story with acceptance criteria and edge cases
- `/plan-backend-ticket [ID]` -> Generate a backend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/plan-frontend-ticket [ID]` -> Generate a frontend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/resolve-ticket-workspace [ID]` -> Resolve the current local `.ai-specs` workspace from input or branch
- `/validate-impl-spec [ID or path]` -> Run the structural validator for implementation specs
- `/close-ticket-workflow [ID]` -> Apply the correct closure order before generating PR content
- `/verify-ac-enforcement` -> Verify that the kit still blocks AC coverage regressions
- `/develop-backend @[plan].md` -> Implement following the backend plan
- `/develop-frontend @[plan].md` -> Implement following the frontend plan
- `/write-pr-report @[IMPL].md` -> Generate PR description from spec

Skill sources live under `.sdd-kit/ai-specs/skills/`.

## Rules

- Never write code without a validated Implementation Spec
- Always follow TDD: RED -> GREEN -> REFACTOR
- Treat acceptance criteria as delivery contract items with explicit evidence
- All commits must follow Conventional Commits
- Keep PRs small and focused
- Keep ticket artifacts in `.ai-specs/changes/`, not in `.sdd-kit/ai-specs/changes/`
