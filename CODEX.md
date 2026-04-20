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
- `.sdd-kit/VERSION` when generating planning artifacts
- `.sdd-kit/docs/tool-runtime.md` when shell invocation or Windows runtime is unclear
- `.sdd-kit/docs/roles-and-responsibilities.md` when role ownership is unclear
- `.sdd-kit/docs/tracker-policy.md` when project ticket policy is not defined
- `.sdd-kit/ai-specs/specs/changelog-template.md` when creating or appending ticket changelog evidence

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

- Resolve `TICKET` as the canonical ticket/work-item key for the consuming
  project. Examples: `JAP-160`, `ENG-123`, `GH-42`, `160`.
- If the user provides ambiguous shorthand, resolve it using the consuming
  project's ticket policy before creating artifacts.
- Before planning, inspect the parent work item and any linked child work items,
  subtasks, checklist items, or implementation tasks exposed by the consuming
  project's tracker.
- Plans and companion specs must include `Related Work Items`. Every in-scope
  child work item with technical requirements must map to an AC, validation
  item, or documented blocker.
- Planning artifacts must use the exact required level-2 headings from
  `implementation-spec-template.md`; do not rename sections to synonyms such as
  `AC-to-Implementation Mapping`, `Delivery Roadmap`, or
  `Completion Evidence Template`.
- In `Related Work Items`, `Scope Decision` must be exactly `In scope`,
  `Out of scope`, `No implementation impact`, or `Blocked`.
- In planning-stage `Completion Evidence`, use validator statuses only:
  `Covered`, `Partial`, or `Not Covered`; unimplemented ACs should be
  `Not Covered` with evidence like `Pending implementation after approval.`
- Kit tools are POSIX `sh` scripts. Invoke them with `sh`; on Windows, use Git
  Bash or Git for Windows `sh.exe` if `sh` is not on `PATH`.
- Keep all ticket artifacts under `.ai-specs/changes/{TICKET}/`.
- Before implementation, use the workspace resolver:
  - In a consuming repo: `sh .sdd-kit/tools/resolve-ticket-workspace.sh {TICKET}`
  - In this kit repo: `sh tools/resolve-ticket-workspace.sh {TICKET}`
- Before implementation, generate and validate:
  - `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md` or `{TICKET}-impl-frontend.md`
  - `.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md`
  - `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
- Changelog files are append-only execution evidence, not planning summaries.
  Follow `ai-specs/specs/changelog-template.md` exactly and never rewrite
  previous changelog entries.
- Record the SDD kit version from `.sdd-kit/VERSION` in generated implementation specs.
- Run `validate-impl-spec.sh {TICKET}` after planning artifacts are written.
- Run `validate-changelog.sh {TICKET}` after planning artifacts are written
  and before using changelog evidence for QA or PR reporting.
- Run `validate-pr-content.sh {TICKET}` after generating `PR-{TICKET}.md`.
- After planning validation, stop and ask for `approve`, `change`, or `deny`.
- Do not write tests, production code, migrations, or config until the user
  explicitly answers `approve`.
- Treat acceptance criteria as delivery contract items.
- Implementation specs must map each acceptance criterion to implementation and validation evidence.
- Do not mark a parent ticket ready if an in-scope child work item remains uncovered.
- Do not mark PR content ready if it has checked commands, CI status, commits, or AC coverage without matching local evidence.
- Run the smallest relevant validation for the change.
- Preserve repository style and existing architecture.
- Keep changes limited to the requested task.
- Report created and modified files in the final response.
