# Skill: Write PR Report

## Purpose

Generate a complete, human-readable PR description from the implemented changes and the Implementation Spec.

## Usage

```
/write-pr-report @[IMPL-spec].md
```

Default output location:

` .ai-specs/changes/{TICKET}/PR-{TICKET}.md `

## Output

A PR description generated from the current local `.ai-specs/changes/{TICKET}/` state and containing:

- **Summary**: what was implemented and why (human readable, not a commit list)
- **Changes**: files modified/created/deleted with brief explanation
- **Testing**: what tests were written and what scenarios they cover
- **Acceptance Criteria Coverage**: every AC from the Implementation Spec with status and evidence
- **Screenshots** (frontend only): before/after if UI changed
- **Definition of Done checklist**: all items from base-standards.mdc
- **Related**: link to TC and IMPL spec in Confluence

## Rules

- Summary must be human readable - not a list of commits
- Prefer `.ai-specs/changes/{TICKET}/` as the primary source of truth over commit history
- Resolve the current ticket from the provided file, or from the active branch/ticket key when no file is provided
- Use the enriched story, implementation spec, and completion evidence from the same `{TICKET}` folder
- Every change must map back to an acceptance criterion from the spec
- Never omit an acceptance criterion from the PR report
- If an acceptance criterion is partial or blocked, state it explicitly with the reason
- Always include the Confluence spec link
- Output in English
