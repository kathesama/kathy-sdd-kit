# Skill: Write PR Report

## Purpose

Generate a complete, human-readable PR description from the implemented changes and the Implementation Spec.

## Usage

```
/write-pr-report @[IMPL-spec].md
```

## Output

A PR description containing:

- **Summary**: what was implemented and why (human readable, not a commit list)
- **Changes**: files modified/created/deleted with brief explanation
- **Testing**: what tests were written and what scenarios they cover
- **Acceptance Criteria Coverage**: every AC from the Implementation Spec with status and evidence
- **Screenshots** (frontend only): before/after if UI changed
- **Definition of Done checklist**: all items from base-standards.mdc
- **Related**: link to TC and IMPL spec in Confluence

## Rules

- Summary must be human readable - not a list of commits
- Every change must map back to an acceptance criterion from the spec
- Never omit an acceptance criterion from the PR report
- If an acceptance criterion is partial or blocked, state it explicitly with the reason
- Always include the Confluence spec link
- Output in English
