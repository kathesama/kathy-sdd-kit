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
sh .sdd-kit/tools/resolve-ticket-workspace.sh [ticket-key]
```

2. Validate the implementation spec structurally:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh [ticket-key-or-impl-plan-path]
```

3. Review `Completion Evidence` in the implementation spec.
4. Validate `{TICKET}-CHANGELOG.md`:

```bash
sh .sdd-kit/tools/validate-changelog.sh [ticket-key-or-changelog-path]
```

Malformed planning summaries or AC matrices are not valid implementation evidence.
5. Scan ticket-scoped files listed in changelog `### Files created` and
   `### Files modified` entries for `sdd-simplification:` markers. If any are
   found, run `/debt-harvest [ticket-key]` before QA or PR review. This modifies
   only the ticket changelog.
6. If `/debt-harvest` appends a changelog entry, validate `{TICKET}-CHANGELOG.md`
   again before continuing.
7. If any AC is `Partial` or `Not Covered`, surface that explicitly.
8. Run `/qa-ticket [ticket-key-or-impl-spec-path]` to validate implementation evidence against the story/spec.
9. Run `/pr-code-review [ticket-key-or-impl-spec-path]` to review correctness, risk, security, complexity, and PR readiness.
10. Generate `PR-{TICKET}.md` from the current `.ai-specs/changes/{TICKET}/` state.
11. Validate generated PR content:

```bash
sh .sdd-kit/tools/validate-pr-content.sh [ticket-key]
```

## Completion rules

- Do not say the ticket is ready if structural validation fails
- Do not say the ticket is ready if PR content validation fails
- Do not say the ticket is ready if QA verdict is `Fail` or `Blocked`
- Do not hide unresolved `pr-code-review` findings
- Do not hide unresolved complexity review findings from QA or PR code review
- Do not hide `Partial` or `Not Covered` acceptance criteria in the PR content
- Do not use malformed changelog sections as implementation evidence
- Do not leave ticket-scoped `sdd-simplification:` markers without a validated
  debt-harvest changelog entry
- Prefer the local `.ai-specs` workspace over commit history as the source of truth
- If backend and frontend implementation specs both exist, choose the one relevant to the current closure step or state the split explicitly
