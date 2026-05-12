---
name: agent-work-discipline
description: Apply baseline agent behavior discipline for SDD work when writing, editing, reviewing, or validating code or framework artifacts: surface assumptions, keep changes simple and surgical, and define verifiable success criteria.
---

# Skill: Agent Work Discipline

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
