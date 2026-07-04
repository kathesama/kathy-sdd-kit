---
name: execute-task-train
description: Use when a user asks Codex to plan, run, continue, or close a sequential train of related tickets, stories, subtasks, or Jira work items under one anchor ticket/workspace, especially when each train member must keep its own acceptance criteria, changelog entry, tracker status, validation, review gate, and consolidated PR evidence.
---

# Skill: Execute Task Train

## Purpose

Run a sequential train of related work items without losing per-story contract
traceability. The train uses one anchor ticket/workspace for SDD artifacts while
each train member keeps its real ticket identity, acceptance criteria, subtasks,
validation evidence, changelog entry, tracker transition, and review gate.

## Required Inputs

Before planning or executing a train, resolve:

- the anchor ticket that owns the SDD workspace
- the ordered train member list
- the tracker source of truth, or the user-provided train list when tracker
  tools are unavailable
- child work items, subtasks, checklist items, and blockers for each train
  member
- branch/workspace policy from the consuming repository
- PR template and PR content policy from the consuming repository
- tracker transition policy for `In Progress`, `In Revision`, `Done`, or local
  project equivalents

Read the local kit and project rules before writing artifacts:

- `AGENTS.md`, `CODEX.md`, or the active tool entrypoint
- `ai-specs/specs/base-standards.mdc`
- `ai-specs/specs/agent-behavior-standards.mdc`
- `ai-specs/specs/changelog-template.md`
- `ai-specs/skills/plan-backend-ticket/SKILL.md` for backend stories
- `ai-specs/skills/plan-frontend-ticket/SKILL.md` for frontend stories
- `ai-specs/skills/qa-ticket/SKILL.md`
- `ai-specs/skills/pr-code-review/SKILL.md`
- `ai-specs/skills/write-pr-report/SKILL.md`
- `ai-specs/skills/validate-pr-content/SKILL.md`
- project-local ADRs, glossary, design contract, API contract, and build/test
  configuration when relevant

If tracker tools are available, inspect the anchor, every train member, and
their children from the tracker. Do not simulate tracker access. If tracker
tools are unavailable, use the user-provided train list and record the tracker
validation gap.

## Anchor Workspace Rules

Use the anchor ticket as the only SDD workspace:

```text
.ai-specs/changes/{ANCHOR_TICKET}/
```

Do not create `.ai-specs/changes/{STORY_TICKET}/` for train members unless the
user explicitly changes the workspace policy.

Recommended train manifest:

```text
.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-task-train.md
```

The manifest records train order, current status, tracker state, blocking
dependencies, and the artifact paths used for each train member.

Use the anchor changelog file:

```text
.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-CHANGELOG.md
```

Use one consolidated train PR content file:

```text
.ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md
```

Each changelog entry heading must use the real train member ticket, for example:

```md
## JAP-1034-PLANNING: Repo structure planning
## JAP-1034-IMPLEMENTATION: Repo structure implementation
## JAP-1034-QA: Repo structure QA
```

Append only. Never rewrite prior train entries.

## Sequential Execution

Process train members in the declared order.

For each train member:

1. Confirm the member ticket, title, acceptance criteria, child work items, and
   blockers.
2. Transition the member to `In Progress` when tracker write tools are available
   and project policy allows it. If not available, record the manual transition
   needed.
3. Create or update train planning artifacts inside the anchor workspace only.
4. Apply the normal SDD planning gate for the current member:
   - generate backend and/or frontend plan content as appropriate
   - generate or update the companion implementation spec content
   - map every explicit member AC and every in-scope child requirement
   - append a factual planning entry to the anchor changelog
   - run the relevant implementation-spec validator against the exact member
     plan path, and the changelog validator against the exact anchor changelog
     path
   - stop for `approve`, `change`, or `deny`
5. After explicit approval, implement only the approved current member.
6. Complete every approved AC, subtask contract, validation item, and required
   changelog entry for the current member before touching the next member.
7. Run QA and code review for the current member using the anchor workspace
   evidence.
8. Transition the member to `In Revision` when tracker write tools are
   available and the member is ready for user supervision. If not available,
   record the manual transition needed.
9. Stop and report the current member result. Do not advance to the next member
   until the user explicitly tells you to continue.

## Planning Artifact Policy

Use filenames that keep the anchor workspace clear and preserve member identity.
For member-specific artifacts inside the anchor workspace, prefer one of:

```text
{STORY_TICKET}-impl-backend.md
{STORY_TICKET}-impl-frontend.md
{STORY_TICKET}-implementation-spec.md
QA-{STORY_TICKET}.md
REVIEW-{STORY_TICKET}.md
```

If an existing consuming repository has a train naming convention, follow it.
If validators only accept anchor-ticket filenames, keep the validator-facing
files named with `{ANCHOR_TICKET}` and record the active member in the train
manifest and changelog.

When member-specific files are named with `{STORY_TICKET}` inside the anchor
workspace, call validators with file paths instead of ticket keys so the tool
does not resolve `.ai-specs/changes/{STORY_TICKET}/`:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh .ai-specs/changes/{ANCHOR_TICKET}/{STORY_TICKET}-impl-backend.md
sh .sdd-kit/tools/validate-changelog.sh .ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-CHANGELOG.md
```

Never collapse multiple train members into a single generic plan unless the user
explicitly requests a train-level planning artifact and each member still keeps
separate AC coverage.

## Changelog Rules

The anchor changelog is the primary execution evidence for the whole train.

For each train member, append entries that include:

- the real train member ticket in the heading
- files created and modified
- AC-specific validation evidence
- tracker transition evidence or manual transition gap
- blocker and dependency notes
- residual risks and follow-ups

Do not use the changelog as a second plan, QA report, PR report, or AC matrix.
Use only factual evidence and the required changelog sections.

## Consolidated Train PR

When the user asks to close, prepare PR content, or hand off a task train,
generate one consolidated local PR report for the anchor ticket:

```text
.ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md
```

Do not generate one PR report per train member unless the user explicitly
changes the train policy. The consolidated PR must cover all executed train members,
not only the most recent or currently active member.

Before writing the consolidated PR:

1. Validate the anchor changelog.
2. Validate every executed member's implementation spec or validator-facing
   plan path.
3. Confirm every executed member has QA and code-review evidence, or record the
   explicit gap.
4. Read the active repository PR template from the consuming project root when
   it exists.

The consolidated PR must include:

- a `Train Coverage` or equivalent table listing every executed member ticket,
  title, status, QA/review evidence, tracker state, and residual notes
- acceptance-criteria coverage for every executed member, preserving the member
  ticket beside each AC so duplicate `AC-01` IDs do not merge across stories
- files created, modified, and deleted across the train, with duplicate file
  paths collapsed only when member attribution remains clear
- validation commands and results for each executed member and train-level
  validators
- selected engineering rule packs, active obligations, design-system evidence,
  blockers, simplification debt, and follow-ups from each executed member when
  present
- pending, blocked, or not-yet-executed train members in a separate section, not
  represented as completed work

After writing `PR-{ANCHOR_TICKET}.md`, run the PR content validator against the
anchor PR path when the local validator supports the train artifact layout:

```bash
sh .sdd-kit/tools/validate-pr-content.sh .ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md
```

If the consuming repository is the kit itself, use:

```bash
sh tools/validate-pr-content.sh .ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md
```

If validation cannot cover member-specific train files, record that validator
gap in the PR content and manually verify the `Train Coverage` and
member-by-member AC coverage against the manifest, changelog, QA, and review
files before handoff.

## Blockers And Dependencies

If the current member is blocked by another repo, API contract, gateway route,
human decision, missing tracker access, or failing prerequisite:

- stop on the current member
- record the blocker in the train manifest and anchor changelog
- do not workaround the dependency unless the user explicitly changes scope
- do not start the next train member if the blocker invalidates order or shared
  foundation work

## Output

When starting or continuing a train, report:

- anchor ticket and anchor workspace
- ordered train members and current member
- tracker source used or validation gap
- current member AC count and child work items considered
- artifacts created or modified
- validations run and results
- tracker transition performed or needed
- consolidated PR path and validation status when closing or handing off the
  train
- next gate: `approve`, `change`, `deny`, or user supervision before continuing

Keep the progress view compact. A table with `Pending`, `In Progress`,
`In Revision`, `Blocked`, and `Done` is enough.

## Rules

- Preserve the anchor workspace unless the user explicitly changes it.
- Preserve each train member's real ticket identity in ACs, changelog entries,
  QA, review, and tracker transitions.
- Treat child work items and subtasks as in-scope contract unless explicitly
  documented out of scope.
- Complete one train member before starting the next.
- Stop at every planning approval gate.
- Stop after moving a completed member to review/supervision.
- Do not create commits or PRs unless the user explicitly asks.
- Generate only one consolidated local train PR report under the anchor
  workspace when PR content is requested.
- Do not omit executed train members from the consolidated PR, even when their
  files or AC IDs overlap with another member.
- Do not invent tracker state when tracker tools are unavailable.
- Output in English.
