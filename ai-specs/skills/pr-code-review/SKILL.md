---
name: pr-code-review
description: Use when local implementation changes need a pre-PR or review pass for correctness, security, CI/readiness, tests, risks, and template evidence.
---

# Skill: PR Code Review

## TDD, Evidence and Design

For contract-1 reports, include the label `TDD and Design Evidence` inside an
appropriate existing report section, preserving any repository PR template.
Follow it with a table: `AC | Applicability | Evidence | Design review`, one
row per AC. Reference actual observations or explicit missing-evidence blockers;
the report label and table never prove runtime execution by themselves.

Read `ai-specs/specs/tdd-evidence-contract.md`,
`ai-specs/specs/engineering-quality-contract.md` and, when running the optional
controller, `ai-specs/specs/harness-evidence-contract.md`.

- New plans and companion specs require `SDD Evidence Contract: 1` and the
  identical per-AC `### TDD and Design Contract` table from the template.
- Require behavior-specific RED before implementation, unchanged tests at
  GREEN, and fresh regression verification. Characterization and non-executable
  reviews use the applicability rules; missing setup is not an exemption.
- Review applicable SRP, OCP, LSP, ISP and DIP without speculative abstractions.
- Preserve evidence kind, observer, command, identity, chronology and freshness.
  A structural validator or agent assertion cannot establish runtime success.
- Keep Covered / Partial / Not Covered. Required missing, stale, contradictory
  or unknown evidence blocks completion, including every in-scope child AC.
- An unchanged approved scope reuses its explicit human approval on resume;
  material scope/check changes require a revised plan and approval. Preserve
  project overrides. No approval, Git or tracker write is inferred from this skill.
- Optional `run-sdd-harness` and `converge-sdd` add bounded execution and gap
  reporting. Convergence never replaces TDD or authorizes new requirements.

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
- `ai-specs/skills/complexity-review/SKILL.md` from the kit when reviewing
  over-engineering and acceptance-criteria scope discipline
- `design-system-standards.mdc` from the kit when reviewing frontend/UI work
- root `DESIGN.md` or project-local design-system context when referenced by
  the frontend plan
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
7. Design-system, accessibility, responsive, and visual evidence risks for UI
   changes
8. Engineering rule pack risks selected for the ticket
9. Complexity and over-engineering risks
10. PR template/evidence gaps

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

## Mandatory Complexity Review

Code review must also run an over-engineering pass over the actual diff and
implementation evidence.

For every added or changed implementation choice, ask:

- Does the acceptance criterion require this code, dependency, abstraction,
  configuration, component, state, or extension point?
- Does existing codebase behavior, the standard library, language runtime,
  native platform, existing component, or already-installed dependency already
  satisfy the need?
- Is a port, interface, adapter, component extraction, or state boundary
  required by hexagonal architecture, frontend standards, ADRs, selected
  engineering rule packs, or validation needs?
- If a `sdd-simplification:` marker exists, does it name a bounded shortcut and
  concrete upgrade path?

Flag unnecessary complexity as a finding, but do not recommend removing
validation, security, accessibility, error handling, tests, or required
architecture boundaries.

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
- frontend/UI claims have design-system evidence when the plan references
  `DESIGN.md`, tokens, Storybook, screenshots, or manual visual checks
- `sdd-simplification:` markers in ticket-scoped files have a debt-harvest
  changelog entry or are called out as a PR-readiness gap

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

## Complexity Review
- Status:
- Findings:
- Debt markers:

## Design System Review
- Status:
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
- Run the mandatory complexity review pass and include the result in
  `## Complexity Review`.
- For frontend/UI tickets, verify that visual changes respect the recorded
  Design System Contract or explicitly document a scoped design-system change.
- For frontend/UI tickets, flag new inline component definitions or one-off
  inline UI blocks. New visible UI units should be named component tags in
  their own files with typed props and parameterization when reuse is plausible.
- For frontend/UI tickets, flag missing stories or colocated component tests for
  new visible components when the repository has Storybook and component tests.
- For frontend/UI tickets, review state ownership and data flow. Flag prop
  drilling through passive parents, duplicated server state in client stores,
  global stores used for local form/component state, or atomic components that
  import stores/API hooks without an explicit connected-component decision.
- Flag speculative features, drive-by refactors, formatting churn, and unrelated cleanup that violate `agent-behavior-standards.mdc`.
- Flag custom code, dependencies, abstractions, configuration, components,
  state, or extension points that violate the Complexity Decision Ladder.
  Existing codebase behavior should be considered before adding new code.
- Treat full-input materialization, lost batching/streaming behavior, unbounded loops, and metric cardinality growth as review risks even when tests pass.
- Do not invent tests, CI results, or ticket links.
- Output in English.
