---
name: close-ticket-workflow
description: Use when implementation is done and you need to close a ticket cleanly by validating the spec, checking completion evidence, and generating local PR content from .ai-specs.
---

# Skill: Close Ticket Workflow

## Purpose

Provide the correct closing order for a ticket so the agent does not skip structural validation or generate PR content from incomplete evidence.

## Usage

Use this skill near the end of a story, before saying the ticket is ready.

## Required sequence

1. Resolve the workspace:

```bash
npx tsx .sdd-kit/tools/resolve-ticket-workspace.ts [ticket-key]
```

2. Validate the implementation spec structurally:

```bash
npx tsx .sdd-kit/tools/validate-impl-spec.ts [ticket-key-or-impl-spec-path]
```

3. Review `Completion Evidence` in the implementation spec.
4. If any AC is `Partial` or `Not Covered`, surface that explicitly.
5. Generate `PR-{TICKET}.md` from the current `.ai-specs/changes/{TICKET}/` state.

## Completion rules

- Do not say the ticket is ready if structural validation fails
- Do not hide `Partial` or `Not Covered` acceptance criteria in the PR content
- Prefer the local `.ai-specs` workspace over commit history as the source of truth
- If backend and frontend implementation specs both exist, choose the one relevant to the current closure step or state the split explicitly
