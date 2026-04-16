---
name: pr-code-review
description: Use when local implementation changes need a pre-PR or review pass for correctness, security, CI/readiness, tests, risks, and template evidence.
---

# Skill: PR Code Review

## Purpose

Review implementation changes before PR handoff, focusing on defects, risks, missing tests, security impact, and PR readiness.

## Usage

```
/pr-code-review [ticket-id or implementation spec path]
```

Default output location:

` .ai-specs/changes/{TICKET}/REVIEW-{TICKET}.md `

## Required Inputs

Read, when present:

- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
- Implementation Spec(s) from `.ai-specs/changes/{TICKET}/`
- `QA-{TICKET}.md`
- `.github/pull_request_template.md`
- changed files, validation output, and CI logs provided by the user
- relevant project docs, standards, ADRs, and glossary

If no diff or changed-file context is available, state that review is limited to available evidence.

## Review Focus

Prioritize findings in this order:

1. Correctness bugs and behavioral regressions
2. Acceptance criteria gaps or contradictions with the spec
3. Security and privacy risks
4. Missing or weak tests
5. CI, validation, or release-readiness gaps
6. Architecture, contract, or maintainability risks
7. PR template/evidence gaps

## Security Impact Review

Check whether the change touches:

- authentication or authorization
- user input validation
- secrets or runtime configuration
- file upload/download
- PII or sensitive data
- external service calls
- payment, billing, permissions, or ownership

If touched, require risks, mitigations, and validation evidence. If missing, raise a review finding.

## CI / Readiness Handling

If CI logs or failing checks are available:

- inspect the failing job and step before proposing fixes
- identify the exact failed command or assertion
- map any proposed fix to the failed check
- require the closest local validation before marking resolved

If CI logs are not available, do not invent CI status.

## PR Readiness Checks

Verify that:

- changelog exists and has factual entries
- QA report exists or QA gaps are explicit
- all explicit ACs are represented in PR evidence
- `.github/pull_request_template.md` structure is preserved when generating PR content
- risks and mitigations are documented
- validation commands are recorded or gaps are stated
- generated PR content does not hide `Partial`, `Not Covered`, or `Blocked` ACs

## Output

Create or update `.ai-specs/changes/{TICKET}/REVIEW-{TICKET}.md` with:

```md
# PR Code Review: {TICKET}

## Verdict
Ready | Ready with risks | Not ready

## Findings
| Priority | Area | Finding | Evidence | Required Action |
|---|---|---|---|---|

## Security Review
- Status:
- Notes:

## Test and CI Review
- Status:
- Notes:

## PR Readiness
- Template:
- Changelog:
- QA:
- AC evidence:
- Risks:

## Recommendation
Ready | Not ready
```

## Rules

- Findings must be actionable and evidence-backed.
- Do not approve readiness when blocking findings remain.
- Do not duplicate QA; reference QA results and focus on review risks.
- Do not invent tests, CI results, or ticket links.
- Output in English.
