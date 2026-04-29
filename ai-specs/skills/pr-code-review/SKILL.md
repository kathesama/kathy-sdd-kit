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
- `agent-behavior-standards.mdc` from the kit when reviewing diff scope and verification discipline
- selected engineering rule packs recorded in the implementation spec, plan, QA report, or changelog
- active engineering rule obligations recorded in the implementation spec, plan, or QA report

If no diff or changed-file context is available, state that review is limited to available evidence.

## Review Focus

Prioritize findings in this order:

1. Correctness bugs and behavioral regressions
2. Acceptance criteria gaps or contradictions with the spec
3. Security and privacy risks
4. Missing or weak tests
5. CI, validation, or release-readiness gaps
6. Architecture, contract, or maintainability risks
7. Engineering rule pack risks selected for the ticket
8. PR template/evidence gaps

## Mandatory Regression Review

Code review must challenge the implementation plan, not only verify compliance
with it. Treat the plan as a hypothesis and inspect the actual diff for
behavior that may regress compared with the previous implementation.

For every changed behavior, ask:

- What used to succeed that could now fail?
- Did the change alter batching, streaming, pagination, chunking, tokenization, or cleanup loop boundaries?
- Did the change materialize a full input set that was previously processed incrementally?
- Did the change add CPU/GPU work, extra inference, model/tokenizer loads, blocking I/O, or N+1 calls?
- Did an observability-only change add metric cardinality, side-effect timing, or failure modes that can break the request path?
- Did a side-channel or internal contract change accidentally leak into a public API, persisted schema, or event schema?

When a performance or side-effect AC claims "no meaningful degradation",
"no external contract change", or similar, require evidence that covers memory,
batching/streaming behavior, and side-effect failure timing, not just the happy
path metric or response assertion.

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
- performance/observability claims have regression evidence or explicit risk notes for memory, batching, cardinality, and side-effect timing

Run the PR content validator when `PR-{TICKET}.md` exists:

```bash
sh .sdd-kit/tools/validate-pr-content.sh {TICKET}
```

If the validator fails, treat the failure as a PR-readiness finding.

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

## Engineering Rule Packs
- Selected:
- Notes:

## Recommendation
Ready | Not ready
```

## Rules

- Findings must be actionable and evidence-backed.
- Do not approve readiness when blocking findings remain.
- Do not duplicate QA; reference QA results and focus on review risks.
- Do not approve solely because the implementation follows the plan; plans may contain incomplete assumptions.
- Apply selected engineering rule packs as review lenses; if an obvious architecture, domain, data, refactoring, or production-readiness risk lacks a selected pack, record that as a review gap.
- Mention each selected engineering rule pack by exact filename and include a related risk or validation note.
- Mention each active engineering rule obligation ID and include contract evidence keywords from the selected pack.
- Flag speculative features, drive-by refactors, formatting churn, and unrelated cleanup that violate `agent-behavior-standards.mdc`.
- Treat full-input materialization, lost batching/streaming behavior, unbounded loops, and metric cardinality growth as review risks even when tests pass.
- Do not invent tests, CI results, or ticket links.
- Output in English.
