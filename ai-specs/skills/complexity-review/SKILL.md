---
name: complexity-review
description: Review the current implementation diff for over-engineering without replacing SDD QA or PR review.
---

# Complexity Review Skill

## Purpose

Review the current implementation diff for over-engineering.
This is a read-only, complexity-only lens, not a replacement for
`pr-code-review`.

## When to Use

Use only when explicitly requested, such as:

- `run complexity review`
- `/complexity-review`

Never run automatically or as part of the standard SDD workflow.

## Required Inputs

Read:

- the current implementation diff or changed-file context
- the relevant implementation spec or acceptance criteria when available
- `ai-specs/specs/agent-behavior-standards.mdc`
- relevant ADRs, architecture notes, or selected engineering rule packs when
  they define required boundaries

If no diff or changed-file context is available, state that the review is
limited to available evidence.

## What It Checks

- Custom code where the standard library, native platform, or an
  already-installed dependency would suffice
- Abstractions with one implementation and no planned second consumer
- Files that exist only to wrap a one-liner
- Dependencies added for functionality already available in the stack
- Code that exceeds its acceptance-criteria scope

## What It Does Not Check

- Security, validation, accessibility, or error handling; those are covered by
  `qa-ticket` and `pr-code-review`
- Port or interface presence required by hexagonal architecture; that is
  covered by `pr-code-review`
- Test existence, execution, or coverage; those are covered by the Validation
  Plan, `qa-ticket`, `pr-code-review`, and repository test scripts
- ADR compliance; that is covered by `pr-code-review`

## Output Format

For each finding:

- `FILE`: path
- `LINE`: range
- `FINDING`: what the over-engineering is
- `SUGGESTION`: simpler alternative, such as standard library, native feature,
  removal, or shrink
- `RISK`: what breaks if simplified

End with a summary line:

`Net lines removable if all suggestions are accepted: <N>.`

If there are no findings, say that no over-engineering findings were found and
stop.

## Rules

- Report only; do not modify files.
- Do not recommend removing validation, security, accessibility, error handling,
  or architecture boundaries required by SDD, ADRs, or selected rule packs.
- Do not treat shorter code as better when it weakens acceptance-criteria
  evidence or production safety.
- Output in English.

## Source and Attribution

This complexity-minimization lens is adapted from ideas in
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), MIT
licensed, and rewritten for SDD gates, acceptance-criteria evidence, and review
rules.
