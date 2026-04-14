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

- `/enrich-us [description]` → Enrich a user story with acceptance criteria and edge cases
- `/plan-backend-ticket [ID]` → Generate a backend implementation plan
- `/plan-frontend-ticket [ID]` → Generate a frontend implementation plan
- `/develop-backend @[plan].md` → Implement following the backend plan
- `/develop-frontend @[plan].md` → Implement following the frontend plan
- `/write-pr-report @[IMPL].md` → Generate PR description from spec

## Rules

- Never write code without a validated Implementation Spec
- Always follow TDD: RED → GREEN → REFACTOR
- All commits must follow Conventional Commits
- Keep PRs small and focused
