# Claude Configuration

> SDD framework source: `.sdd-kit/`
> Project-local SDD workspace: `.ai-specs/`
> This file complements the consuming project's root `CLAUDE.md`.

@.sdd-kit/ai-specs/specs/base-standards.mdc
@.sdd-kit/ai-specs/specs/agent-behavior-standards.mdc
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

Reusable kit references:

- `.sdd-kit/VERSION` for the version to record in generated specs
- `.sdd-kit/docs/tool-runtime.md` for shell runtime guidance
- `.sdd-kit/docs/roles-and-responsibilities.md` for role boundaries
- `.sdd-kit/docs/tracker-policy.md` for provider-neutral ticket key policy
- `.sdd-kit/ai-specs/specs/changelog-template.md` for ticket changelog structure
- `.sdd-kit/ai-specs/rules/engineering/README.md` for optional engineering rule pack selection

## Available Skills

- `/enrich-us [description]` -> Enrich a user story with acceptance criteria and edge cases
- `/plan-backend-ticket [ID]` -> Generate a backend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/plan-frontend-ticket [ID]` -> Generate a frontend implementation plan with AC-to-implementation and AC-to-validation mapping
- `/resolve-ticket-workspace [ID]` -> Resolve the current local `.ai-specs` workspace from input or branch
- `/select-engineering-rules [context]` -> Select optional engineering rule packs for planning, QA, or review
- `/agent-work-discipline` -> Apply baseline agent behavior discipline for scoped, simple, verifiable changes
- `/validate-impl-spec [ID or path]` -> Run the structural validator for implementation specs
- `sh .sdd-kit/tools/validate-changelog.sh [ID or path]` -> Run the structural validator for ticket changelog evidence
- `/close-ticket-workflow [ID]` -> Apply the correct closure order before generating PR content
- `/verify-ac-enforcement` -> Verify that the kit still blocks AC coverage regressions
- `/develop-backend @[plan].md` -> Implement following the backend plan
- `/develop-frontend @[plan].md` -> Implement following the frontend plan
- `/write-pr-report @[IMPL].md` -> Generate PR description from spec

Skill sources live under `.sdd-kit/ai-specs/skills/`.

## Rules

- Never write code without a validated Implementation Spec
- Follow `agent-behavior-standards.mdc`: surface material assumptions, keep changes simple and surgical, and verify before claiming completion
- Load engineering rule packs only through task-scoped selection; do not treat every pack as always-on context
- `TICKET` is the canonical ticket/work-item key for the consuming project; resolve ambiguous shorthand before creating artifacts
- Before planning, inspect the parent work item and linked child work items, subtasks, checklist items, or implementation tasks exposed by the consuming project's tracker
- Plans and companion specs must include `Related Work Items`; every in-scope child work item with technical requirements must map to an AC, validation item, or documented blocker
- Planning artifacts must use the exact required level-2 headings from `implementation-spec-template.md`; do not rename sections to synonyms such as `AC-to-Implementation Mapping`, `Delivery Roadmap`, or `Completion Evidence Template`
- In `Related Work Items`, `Scope Decision` must be exactly `In scope`, `Out of scope`, `No implementation impact`, or `Blocked`
- In planning-stage `Completion Evidence`, use validator statuses only: `Covered`, `Partial`, or `Not Covered`; unimplemented ACs should be `Not Covered` with evidence like `Pending implementation after approval.`
- Generate `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md` or `{TICKET}-impl-frontend.md`
- Generate `.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md`
- Record the SDD kit version from `.sdd-kit/VERSION` in generated specs
- Create `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md` before implementation
- Changelog files are append-only execution evidence, not planning summaries; follow `ai-specs/specs/changelog-template.md` exactly and never rewrite previous changelog entries
- Run `/validate-impl-spec [TICKET]` after planning
- Run `sh .sdd-kit/tools/validate-changelog.sh [TICKET]` after planning and before PR reporting
- Run `sh .sdd-kit/tools/validate-pr-content.sh [TICKET]` after generating `PR-{TICKET}.md`
- Stop after planning and ask for `approve`, `change`, or `deny`; implementation requires explicit `approve`
- Always follow TDD: RED -> GREEN -> REFACTOR
- Treat acceptance criteria as delivery contract items with explicit evidence
- Do not mark PR content ready when checked commands, CI status, commits, or AC coverage lack matching local evidence
- All commits must follow Conventional Commits
- Keep PRs small and focused
- Keep ticket artifacts in `.ai-specs/changes/`, not in `.sdd-kit/ai-specs/changes/`
