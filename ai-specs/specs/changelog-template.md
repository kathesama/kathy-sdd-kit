# Ticket Changelog Template

The changelog is append-only execution evidence. It is not a second
implementation plan, QA report, PR report, or design summary.

Path:

```text
.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md
```

Initial file:

```md
# {TICKET} {short ticket title}

## {TICKET}-PLANNING: Create and validate implementation plan
**Status:** Done
**Commit message:** Not committed; repository rules forbid agent commits unless explicitly requested.
### Files created
- `.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md` or `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`
- `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
### Files modified
- None
### Summary
- Created SDD planning artifacts for `{TICKET}`.
- Ran `validate-impl-spec.sh {TICKET}` and recorded the result in the approval gate.
### Notes
- Implementation remains pending explicit approval.
---
```

Required entry format:

```md
## {SUBTASK_KEY}: {subtask title}
**Status:** Done
**Commit message:** Not committed; repository rules forbid agent commits unless explicitly requested.
### Files created
### Files modified
### Summary
### Notes
---
```

Rules:

- Append new sections; do not rewrite or reorder previous sections.
- Record facts only: files created, files modified, validation results, risks, follow-ups, and concise implementation notes.
- Do not use the changelog as a planning summary, design document, QA report, PR description, or acceptance criteria matrix.
- Do not mark planned work as implemented.
- During planning, create one factual planning entry only.
- During execution, append one entry per completed subtask.
- Use `Not committed; repository rules forbid agent commits unless explicitly requested.` when no commit exists.
- Do not include real secrets, tokens, passphrases, API keys, or credentials.
