---
name: qa-ticket
description: Use when implementation is complete or near complete and you need to validate story/spec acceptance criteria, evidence, tests, and risks before PR readiness.
---

# Skill: QA Ticket

## Purpose

Validate that an implementation satisfies the story and Implementation Spec end-to-end using evidence, not assumptions.

## Usage

```
/qa-ticket [ticket-id or implementation spec path]
```

Default output location:

` .ai-specs/changes/{TICKET}/QA-{TICKET}.md `

## Required Inputs

Read, when present:

- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`
- enriched story from `.ai-specs/changes/{TICKET}/`
- completion evidence and validation output from `.ai-specs/changes/{TICKET}/`
- relevant project docs, ADRs, glossary, or standards referenced by the spec
- `agent-behavior-standards.mdc` from the kit when reviewing scope, simplicity, and verification discipline
- `ai-specs/skills/complexity-review/SKILL.md` from the kit when reviewing
  over-engineering and acceptance-criteria scope discipline
- `design-system-standards.mdc` from the kit when reviewing frontend/UI work
- root `DESIGN.md` or project-local design-system context when referenced by
  the frontend plan
- selected engineering rule packs recorded in the implementation spec, plan, or changelog
- active engineering rule obligations recorded in the implementation spec or plan
- `.sdd-kit/ai-specs/specs/changelog-template.md` or `ai-specs/specs/changelog-template.md` when changelog structure is unclear

If the ticket cannot be resolved from input, branch, or local `.ai-specs` state, stop and report the missing input.

## QA Method

1. Resolve the ticket workspace.
2. Read every explicit acceptance criterion from the story/spec.
3. Compare each AC against implementation mapping, completion evidence, changelog entries, and tests.
4. Verify that validation evidence is concrete: command output, test name, screenshot, manual check, or reviewer-observable behavior.
5. Apply selected engineering rule packs as risk lenses when they were recorded in the plan/spec; if none were recorded but a clear architecture, domain, data, refactoring, or production-readiness risk exists, note the missing selection as a QA gap.
   Preserve the exact selected pack filenames and active obligation IDs in QA evidence.
6. For frontend/UI work, compare implementation evidence against the recorded
   `Design System Contract`, root `DESIGN.md` when present, accessibility
   requirements, responsive behavior, and visual evidence such as Storybook
   states or screenshots. Also verify new visible UI units are named component
   tags in their own files with typed, reusable props instead of inline
   component definitions or one-off inline UI blocks. When the repository has
   Storybook and component tests, verify each new visible component has a story
   and colocated test or a documented validation gap. Verify state ownership and
   data flow use props/callbacks for local composition, feature context/hooks or
   stores for cross-tree client state, React Query for server state, form
   tooling for form state, and URL/search params for shareable navigation
   state.
7. Run a regression-oriented pass over the changed behavior, independent of the plan's assumptions.
8. Run an automatic complexity review pass over the changed files and planned
   implementation evidence. Flag custom code, dependencies, abstractions,
   configuration, components, state, or extension points that exceed AC scope or
   duplicate existing codebase behavior, standard library, native platform,
   existing component, or already-installed dependency behavior. Do not flag
   validation, security, accessibility, error handling, or architecture
   boundaries required by SDD.
9. If `sdd-simplification:` markers appear in ticket-scoped files, verify that
   each marker has a concrete upgrade path and that a debt-harvest changelog
   entry exists or is listed as a QA gap.
10. Identify partial coverage, missing tests, missing evidence, unaddressed risks, and follow-up work.
11. Produce a QA report in the ticket folder.

## Task Train Scope

When QA runs for a task train, run it against the consolidated anchor plan after
the approved plan execution is ready for review. Do not create per-member QA
reports as part of the normal train flow.

For a train:

- use `{ANCHOR_TICKET}-impl-backend.md` or `{ANCHOR_TICKET}-impl-frontend.md`
  and `{ANCHOR_TICKET}-implementation-spec.md` as the source of truth
- create or update `QA-{ANCHOR_TICKET}.md`
- evaluate every train member represented in the consolidated plan/spec
- preserve the member ticket beside each AC in the QA coverage table
- mark only ACs with execution evidence from their own member as `Covered`
- keep pending, blocked, or unexecuted member ACs visible with truthful status
- report a QA gap if AC rows in the consolidated plan/spec do not preserve the
  member ticket beside the AC ID

Use the consolidated anchor plan/spec as the source of truth, and keep member
status explicit inside the consolidated QA report.

## Regression QA Pass

QA must verify not only "does this match the plan?" but also "what did this plan fail to consider?"

For each changed behavior, compare the previous and new execution paths and check for regressions in:

- memory and large-input materialization
- batching, streaming, pagination, and backpressure
- latency, CPU/GPU work, and extra inference/model calls
- metric label cardinality and side-effect ordering
- idempotency, retries, partial failures, and race windows when relevant
- unchanged public API, persisted schema, event schema, and response contracts

When the implementation changes batching, streaming, pagination, tokenization,
chunking, cleanup loops, retry loops, query limits, or side-effect-only
instrumentation, require at least one targeted boundary/scale-shaped test or
record a concrete residual risk. Do not mark `Pass` solely because the plan's
expected tests pass.

## Verdicts

- `Pass`: every explicit AC is covered with concrete evidence and no blocking risk remains.
- `Pass with risks`: ACs are covered, but non-blocking risks, gaps, or follow-ups remain.
- `Blocked`: QA cannot complete because required evidence, spec, environment, or dependency is missing.
- `Fail`: one or more explicit ACs are not covered or evidence contradicts the expected behavior.

## Output

Create or update `.ai-specs/changes/{TICKET}/QA-{TICKET}.md` with:

```md
# QA Report: {TICKET}

## Verdict
Pass | Pass with risks | Blocked | Fail

## Acceptance Criteria Coverage
| AC | Status | Evidence | Notes |
|---|---|---|---|

## Test Evidence
- Unit:
- Integration:
- E2E:
- Manual:

## Risk Review
- Risk:
- Impact:
- Mitigation:

## Complexity Review
- Status:
- Findings:
- Debt markers:

## Engineering Rule Packs
- Selected:
- Notes:

## Design System Review
- Status:
- Evidence:
- Gaps:

## Gaps
- Missing test:
- Missing evidence:
- Partial AC:
- Follow-up:

## Recommendation
Ready | Not ready
```

## Rules

- Do not mark `Pass` without concrete evidence for every explicit AC.
- In task trains, "every explicit AC" means every explicit AC in the
  consolidated anchor plan, grouped by member ticket with truthful status.
- Do not merge distinct ACs into one QA row.
- Do not treat "tests passed" as AC evidence unless the relevant test/check is named.
- Do not let the implementation plan's proposed approach suppress regression review; plans can contain incomplete assumptions.
- Do not let the implementation plan's proposed approach suppress complexity
  review; plans can contain unnecessary custom code, dependencies, or
  abstractions.
- Apply selected engineering rule packs as additional risk checks; do not use them to override explicit acceptance criteria or project ADRs.
- Mention each selected engineering rule pack by exact filename and include a related risk or validation note.
- Mention each active engineering rule obligation ID and include contract evidence keywords from the selected pack.
- For frontend/UI tickets, mention whether a Design System Contract was present
  and whether the evidence covers tokens/components, accessibility, responsive
  behavior, and visual review needs.
- For frontend/UI tickets, flag new inline component definitions or one-off
  inline UI blocks as QA gaps unless the plan explicitly documents an accepted
  exception.
- For frontend/UI tickets, flag missing stories or colocated component tests for
  new visible components when the repository has those surfaces.
- For frontend/UI tickets, flag prop drilling through passive parents, duplicated
  server state in client stores, global stores used for local form/component
  state, or atomic components importing stores/API hooks without an explicit
  connected-component decision.
- Flag speculative features, broad refactors, or unrelated changes that violate `agent-behavior-standards.mdc`.
- Flag over-engineering that violates the Complexity Decision Ladder, including
  custom code where existing codebase behavior, standard library, native
  platform, existing components, or already-installed dependencies would
  satisfy the AC.
- Do not mark performance/observability side-channel changes as `Pass` until memory, batching, cardinality, and side-effect timing have been considered.
- If evidence is missing, mark the AC as `Partial`, `Not Covered`, or `Blocked`.
- Use the changelog as primary implementation evidence when present.
- Treat changelog sections that look like planning summaries, design documents, QA reports, PR reports, or AC matrices as invalid evidence unless they also follow the required changelog entry format.
- Do not rewrite the changelog during QA; report malformed changelog evidence as a gap.
- Do not run `/debt-harvest` during QA; report missing or malformed debt
  harvest evidence as a gap.
- Output in English.
