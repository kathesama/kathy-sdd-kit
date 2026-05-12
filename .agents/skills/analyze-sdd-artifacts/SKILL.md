---
name: analyze-sdd-artifacts
description: Use after SDD planning or task generation when you need a read-only consistency analysis across story, implementation specs, validation plans, changelog, QA, review, and optional design-system evidence.
---

# Skill: Analyze SDD Artifacts

## Purpose

Perform a read-only cross-artifact consistency check before implementation,
QA, review, or PR reporting. This complements structural validators; it does
not replace them.

## Usage

```
/analyze-sdd-artifacts [ticket-id or implementation spec path]
```

Default output location:

` .ai-specs/changes/{TICKET}/ANALYSIS-{TICKET}.md `

## Required Inputs

Read, when present:

- `.ai-specs/changes/{TICKET}/{TICKET}-enriched.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
- `.ai-specs/changes/{TICKET}/QA-{TICKET}.md`
- `.ai-specs/changes/{TICKET}/REVIEW-{TICKET}.md`
- `ai-specs/specs/base-standards.mdc`
- `ai-specs/specs/agent-behavior-standards.mdc`
- `ai-specs/specs/design-system-standards.mdc` for frontend/UI work
- selected engineering rule packs recorded in the implementation spec
- project-local `DESIGN.md`, Storybook, UI docs, ADRs, or glossary when the
  ticket touches UI

If the ticket cannot be resolved, stop and report the missing input. Do not
create a new ticket workspace from this skill.

## Operating Constraints

- Read artifacts and write only the analysis report.
- Do not modify story, plan, implementation spec, changelog, QA, review, PR
  content, source code, tests, design tokens, or runtime configuration.
- Do not treat this report as implementation evidence.
- Do not hide validator failures. If `validate-impl-spec.sh`,
  `validate-changelog.sh`, or `validate-pr-content.sh` should be run, list them
  explicitly.

## Analysis Passes

### 1. Acceptance Criteria Consistency

- Every explicit AC from the story appears in the implementation plan and
  companion implementation spec.
- Every AC has implementation mapping, validation mapping, delivery-plan
  references, and completion evidence.
- Distinct ACs remain separate when they need different validation.
- Inferred ACs are labeled as `inferred`.

### 2. Related Work Item Coverage

- The parent work item appears in `Related Work Items`.
- Every in-scope child work item appears in ACs, implementation mapping,
  validation plan, or delivery plan.
- Out-of-scope or blocked items include an explicit reason.

### 3. Validation Quality

- Validation entries are executable or manually checkable.
- "Tests pass" is not treated as AC evidence unless the relevant test or check
  is named.
- Manual checks state viewport, browser, assistive technology, screenshot,
  Storybook state, or runtime observation as applicable.

### 4. Engineering Rule Pack Traceability

- Selected rule packs preserve exact filenames.
- Active obligations preserve exact IDs.
- Selected packs and active obligations appear in planning, QA, review, and PR
  evidence when those artifacts exist.

### 5. Design System Consistency

For frontend/UI work:

- If `DESIGN.md` exists, the plan records a `Design System Contract`.
- If local design sources exist but root `DESIGN.md` does not, the plan records
  a design-standardization gap and whether creating `DESIGN.md` is prework, in
  scope, or explicitly out of scope.
- Token/component changes map to an AC, in-scope work item, or documented risk.
- UI validation includes accessibility, responsive, and visual evidence
  appropriate for the change.
- If no durable design source exists beyond current UI code, the plan records
  the fallback and risk.

### 6. Spec-Kit-Style Quality Scan

Look for:

- unresolved markers such as unfinished-work notes, question marks, or
  needs-clarification labels
- vague requirements such as "fast", "robust", "intuitive", "secure", or
  "scalable" without measurable evidence
- terminology drift across artifacts
- tasks or changelog entries that do not map to ACs
- planned work marked as implemented
- PR/QA/review summaries that hide partial or missing coverage

## Output

Create or update `.ai-specs/changes/{TICKET}/ANALYSIS-{TICKET}.md`:

```md
# SDD Artifact Analysis: {TICKET}

## Verdict
Ready for planning approval | Ready with risks | Not ready | Blocked

## Findings
| ID | Category | Severity | Location | Summary | Required Action |
|---|---|---|---|---|---|

## AC Coverage Summary
| AC | In Story | In Plan | In Companion Spec | Validation | Evidence | Notes |
|---|---|---|---|---|---|---|

## Design System Review
- Status:
- Evidence:
- Gaps:

## Engineering Rule Packs
- Selected:
- Active obligations:
- Gaps:

## Recommended Next Actions
- 
```

Severity:

- `Critical`: explicit AC or in-scope child work item can be dropped, hidden, or
  marked complete without evidence.
- `High`: ambiguous, contradictory, or untestable requirement can cause wrong
  implementation.
- `Medium`: missing non-functional, design-system, validation, or traceability
  evidence creates rework risk.
- `Low`: wording, duplication, or documentation clarity issue.

## Rules

- Output in English.
- Keep findings evidence-backed and actionable.
- Prefer a short high-signal report over exhaustive restatement.
- Do not claim readiness if explicit ACs, selected rule packs, or design-system
  contract obligations are missing required evidence.
- If no issues are found, still report the artifact set reviewed and residual
  validation gaps.
