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

If the ticket cannot be resolved from input, branch, or local `.ai-specs` state, stop and report the missing input.

## QA Method

1. Resolve the ticket workspace.
2. Read every explicit acceptance criterion from the story/spec.
3. Compare each AC against implementation mapping, completion evidence, changelog entries, and tests.
4. Verify that validation evidence is concrete: command output, test name, screenshot, manual check, or reviewer-observable behavior.
5. Identify partial coverage, missing tests, missing evidence, unaddressed risks, and follow-up work.
6. Produce a QA report in the ticket folder.

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
- Do not merge distinct ACs into one QA row.
- Do not treat "tests passed" as AC evidence unless the relevant test/check is named.
- If evidence is missing, mark the AC as `Partial`, `Not Covered`, or `Blocked`.
- Use the changelog as primary implementation evidence when present.
- Output in English.
