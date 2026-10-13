---
name: agent-work-discipline
description: Apply baseline agent behavior discipline for SDD work when writing, editing, reviewing, or validating code or framework artifacts: surface assumptions, keep changes simple and surgical, and define verifiable success criteria.
---

# Skill: Agent Work Discipline

## TDD, Evidence and Design

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

Apply the baseline behavior rules that keep agent work scoped, simple, and
verifiable across Codex, Claude Code, Cursor, and compatible agents.

## Required Inputs

Read:

- `ai-specs/specs/agent-behavior-standards.mdc`
- the user request and the relevant SDD plan, story, or review context
- project-local instructions, ADRs, glossary, scripts, and standards when relevant

## Workflow

1. State assumptions only when they affect scope, safety, contracts, or validation.
2. Convert the request into concrete success criteria before editing.
3. Choose the smallest change that satisfies the success criteria and project rules.
4. Keep the diff surgical: touch only requested files and cleanup caused by the change.
5. Validate with the smallest relevant command first, then broader checks when risk warrants.
6. Record validation evidence or explicit gaps in the appropriate SDD artifact.

## Review Lens

During QA or code review, flag:

- speculative features, abstractions, configuration, or extension points
- drive-by refactors, formatting churn, or unrelated cleanup
- changed behavior without named acceptance criteria or validation evidence
- completion claims that lack fresh local evidence
- tests or checks that do not map to the acceptance criteria they claim to cover

## Rules

- Do not use this skill to weaken the SDD planning gate.
- Do not ask for confirmation unless ambiguity blocks safe progress.
- Do not expand scope to fix unrelated issues.
- Do not claim completion without fresh validation evidence or a documented gap.
- Output in English.
