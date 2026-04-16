# Codex SDD Entrypoint

This file defines how Codex should use `kathy-sdd-kit` when the kit is mounted
as a submodule at `.sdd-kit/` in a consuming repository.

## Source Of Truth

- The SDD framework source lives in `.sdd-kit/`.
- Project-local SDD work state lives in `.ai-specs/`.
- Ticket artifacts live in `.ai-specs/changes/{TICKET}/`.
- Do not create ticket artifacts inside `.sdd-kit/ai-specs/changes/`.
- Do not modify `.sdd-kit/` unless the task is explicitly to update the kit.

## Required Context For SDD Work

Before SDD planning, implementation, review, QA, PR-report, or closure work,
read the relevant framework files from the submodule:

- `.sdd-kit/ai-specs/specs/base-standards.mdc`
- `.sdd-kit/ai-specs/specs/backend-standards.mdc` for backend work
- `.sdd-kit/ai-specs/specs/frontend-standards.mdc` for frontend work
- `.sdd-kit/ai-specs/specs/implementation-spec-template.md` when creating or validating implementation specs
- `.sdd-kit/ai-specs/skills/{skill-name}/SKILL.md` for the requested SDD workflow
- `.sdd-kit/ai-specs/.agents/{agent-name}.md` when acting as a specialized SDD agent

## Project Context Precedence

Use consuming-project context before generic kit guidance:

1. Direct user request
2. Root `AGENTS.md`
3. Root project context such as `CLAUDE.md`, `docs/doc_architecture.md`, ADRs, glossary, scripts, and package/build config
4. `.sdd-kit/CODEX.md`
5. `.sdd-kit/ai-specs/` framework standards, skills, templates, and agents

When project-specific rules conflict with generic kit guidance, follow the
project-specific rule unless it would violate safety, secrets, or explicit user
instructions.

## Workflow Expectations

- Treat acceptance criteria as delivery contract items.
- Implementation specs must map each acceptance criterion to implementation and validation evidence.
- Run the smallest relevant validation for the change.
- Preserve repository style and existing architecture.
- Keep changes limited to the requested task.
- Report created and modified files in the final response.
