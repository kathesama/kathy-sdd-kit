---
name: write-pr-report
description: Use when local SDD evidence is ready for PR content, including single-ticket PR reports and consolidated task-train PR reports from an anchor workspace.
---

# Skill: Write PR Report

## Purpose

Generate a complete, human-readable PR description from implemented SDD evidence while preserving the repository PR template structure. Support both single-ticket reports and consolidated task-train reports.

## Usage

```
/write-pr-report @[IMPL-spec].md
/write-pr-report @[ANCHOR-task-train].md
```

Default output location:

` .ai-specs/changes/{TICKET}/PR-{TICKET}.md `

Primary input:

` .ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md `

## Output

A PR description generated from the current local `.ai-specs/changes/{TICKET}/` state, especially `{TICKET}-CHANGELOG.md`, and written into the repository PR template structure.

When `.github/pull_request_template.md` exists, the output must preserve that template exactly:

- Keep all headings in the same order
- Keep checklist items and comments unless filling them requires replacing
  template blanks
- Fill existing sections instead of inventing a different report layout
- Do not rename template headings

If no repository PR template exists, create a fallback PR report containing:

- **Summary**: what was implemented and why (human readable, not a commit list)
- **Changes**: files created/modified/deleted with brief explanation, grouped from changelog sections
- **Testing**: what tests were written and what scenarios they cover
- **Acceptance Criteria Coverage**: every AC from the Implementation Spec with status and evidence
- **Screenshots** (frontend only): before/after if UI changed
- **Design System Evidence** (frontend only): DESIGN.md, token, Storybook, screenshot, or manual visual evidence when UI changed
- **Definition of Done checklist**: all items from base-standards.mdc
- **Related**: link to TC and IMPL spec in Confluence

## Source Priority

1. Active project PR template: `<PROJECT_ROOT>/.github/pull_request_template.md`
2. `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`
3. Implementation Spec and enriched story from `.ai-specs/changes/{TICKET}/`
4. Completion evidence, validation output, screenshots, or supporting notes from the same folder
5. Design System Contract, root `DESIGN.md`, screenshots, Storybook states, or
   manual visual checks when frontend/UI work is in scope
6. Selected engineering rule packs and their risk notes from the plan, QA report, or review report
7. Commit history only as a fallback for missing details, never as the main structure

`PROJECT_ROOT` is the repository being worked on. If this kit is installed as `.sdd-kit`, do not resolve the PR template path inside `.sdd-kit/.github/`; use the consuming repository's `.github/pull_request_template.md`. The kit's `.github/pull_request_template.md` is a starter template that must be copied to the consuming repository root to be active.

## Task Train Mode

Use task train mode when any of these are true:

- the input is `{ANCHOR_TICKET}-task-train.md`
- `.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-task-train.md` exists
- `execute-task-train` is closing or handing off a train

In task train mode, generate one consolidated PR report:

```text
.ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md
```

Do not create `PR-{STORY_TICKET}.md` files for individual train members unless
the user explicitly changes the train policy.

Use these sources in addition to the normal PR report sources:

1. `{ANCHOR_TICKET}-task-train.md`
2. the consolidated `{ANCHOR_TICKET}-impl-backend.md` or
   `{ANCHOR_TICKET}-impl-frontend.md`
3. the consolidated `{ANCHOR_TICKET}-implementation-spec.md`
4. `{ANCHOR_TICKET}-CHANGELOG.md`
5. consolidated `QA-{ANCHOR_TICKET}.md` and `REVIEW-{ANCHOR_TICKET}.md`
6. tracker transition notes and blocker notes recorded in the manifest or
   changelog

The consolidated PR must include all executed train members. Preserve each
member ticket beside its AC rows because multiple members may reuse IDs such as
`AC-01`.

Minimum train PR content:

- **Train Coverage**: member ticket, title, status, QA evidence, review
  evidence, tracker state, and notes
- **Acceptance Criteria Coverage**: one row or bullet per member AC, including
  member ticket, AC ID, status, and evidence
- **Changes**: merged file list across all executed members, with member
  attribution when the same file appears in multiple entries
- **Testing / Validation**: per-member and train-level commands, including
  validator output or explicit validation gaps
- **Pending / Blocked Members**: train members not represented as completed
  work

Only mark ACs as covered for the member whose execution evidence actually
completed them. Do not summarize only the last train member. Do not collapse
duplicate AC IDs across members. Do not mark pending train members or their ACs
as done.

## Template Processing

When `<PROJECT_ROOT>/.github/pull_request_template.md` exists:

1. Load the template before writing the report
2. Populate the template sections with SDD evidence
3. Preserve the template shape even if the SDD evidence is richer than the template
4. Put extra detail inside the most relevant existing section instead of adding new top-level sections
5. If a required SDD concept has no matching template section, add it under the closest existing section as a short labeled paragraph

Common template mappings:

- **Ticket**: extracted ticket key and link/reference when available; `N/A` when no ticket exists
- **Summary**: concise implementation explanation from changelog summaries and implementation spec
- **Change Type**: selected from implemented work, not from commit prefixes alone
- **Scope**: affected areas such as Java, Python, CI/CD, Docs, Infrastructure, Config, Tests
- **Tickets / References**: ticket key/reference and suggested commit messages or real commit traceability when available
- **What was done**: concise behavior/module implementation bullets
- **Changes**: files created, modified, and deleted with brief explanations from changelog sections
- **Testing / Validation**: validation commands, test files, and covered scenarios from changelog and evidence files
- **Acceptance Criteria Coverage**: every AC from the Implementation Spec with status and evidence
- **Screenshots**: before/after evidence for frontend work; `N/A` for non-frontend changes
- **Design System Evidence**: token/component evidence, `DESIGN.md` lint/diff,
  Storybook state, screenshot, or manual visual check for frontend/UI changes
- **Related**: TC, IMPL, and Confluence links
- **Definition of Done checklist**: mark only items supported by evidence

For the template currently used by this kit:

- **Ticket**: fill the `AUTO-TICKET` block only when a ticket key/reference can be detected; otherwise keep `N/A`
- **Target branch**: check exactly one target branch when it can be inferred; otherwise leave unchecked
- **Summary**: fill the `AUTO-SUMMARY` block with 2-4 concise technical bullets or one short paragraph
- **Change Type**: check every applicable type and leave non-applicable items unchecked
- **Scope**: check every affected scope and leave non-applicable items unchecked
- **Tickets / References**: fill `Issue / Task` with the ticket key/reference when available and include TC/IMPL links when available; use `Suggested commit messages` for changelog commit-message suggestions unless real commit hashes are available
- **What was done**: put concise behavior/module implementation bullets here, sourced from changelog `Summary`
- **Changes**: group detailed file-level changes under `Files created`, `Files modified`, and `Files deleted`
- **Testing**: summarize test files, assertions, and scenarios covered
- **Acceptance Criteria Coverage**: list every AC from the Implementation Spec with status and evidence
- **Screenshots**: include before/after screenshots for frontend changes; keep `N/A` for non-frontend changes
- **Design System Evidence**: include the Design System Contract result under
  Screenshots, Testing, Risks, or the closest existing visual evidence section
- **How to test**: check only commands that were actually run or are explicitly required; put unrun relevant commands under `Other:` with status such as `Not run`
- **Risks and mitigation**: summarize real risks, migrations, config impacts, rollout concerns, and mitigations from changelog `Notes`; write `None identified` only when evidence supports it
- **Engineering rule packs**: include selected packs and resulting risk notes under risks, validation, or the closest existing template section
- **Related**: include TC, IMPL, and Confluence links when available
- **Pre-merge checklist**: check an item only when the changelog/evidence supports it; leave uncertain items unchecked
- **Definition of Done checklist**: mark all applicable DoD items from `base-standards.mdc` when evidence supports them

## PR Content Validation

After writing `PR-{TICKET}.md`, run:

```bash
sh .sdd-kit/tools/validate-pr-content.sh {TICKET}
```

If running inside the kit repository itself, use:

```bash
sh tools/validate-pr-content.sh {TICKET}
```

Fix any validation failure before reporting the PR content as ready.

## Rules

- Summary must be human readable - not a list of commits
- Strictly adhere to `<PROJECT_ROOT>/.github/pull_request_template.md` when it exists; this means the repository being worked on, not the `.sdd-kit` copy
- Do not replace a repository template with the fallback SDD report layout
- Prefer `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md` as the primary source of truth over commit history
- Resolve the current ticket from the provided file, or from the active branch/ticket key when no file is provided
- If `{TICKET}-CHANGELOG.md` is missing, state that the PR report is based on the remaining ticket folder evidence
- Read every changelog subtask section and merge duplicate file entries into a single Changes section
- Ignore changelog content that is not in the required subtask-entry format from `ai-specs/specs/changelog-template.md`; report malformed changelog sections as a source evidence gap
- Use changelog `Summary` and `Notes` sections to explain intent, risks, and follow-up work
- Preserve selected engineering rule pack notes when they explain architecture, domain, data, refactoring, production-readiness, or review risk
- Mention each selected engineering rule pack by exact filename in PR content so `validate-pr-content.sh` can trace plan -> QA -> review -> PR continuity
- Mention each active engineering rule obligation ID and related contract evidence in PR content so `validate-pr-content.sh` can trace obligation coverage
- For frontend/UI tickets, preserve design-system evidence from QA/review:
  whether `DESIGN.md` was used, what tokens/components were affected, and what
  screenshot, Storybook, lint/diff, or manual visual evidence supports the UI
  claim
- Use changelog `Commit message` entries only for traceability, not as PR summary prose
- Do not present suggested commit messages as real commits. Use the template's `Suggested commit messages` field unless real commit hashes are available.
- Use the enriched story, implementation spec, and completion evidence from the same `{TICKET}` folder
- Every change must map back to an acceptance criterion from the spec
- Never omit an acceptance criterion from the PR report
- If an acceptance criterion is partial or blocked, state it explicitly with the reason
- Check only validation commands and CI items with matching evidence in the ticket folder
- Always include the Confluence spec link
- Output in English
