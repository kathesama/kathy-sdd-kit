---
name: execute-task-train
description: Use when a user asks Codex to plan, run, continue, or close a sequential train of related tickets, stories, subtasks, or Jira work items under one anchor ticket/workspace, especially when all train members must be planned in one implementation plan while each member keeps its own acceptance criteria, changelog entry, tracker status, validation, review gate, and consolidated PR evidence.
---

# Skill: Execute Task Train

## Purpose

Run a sequential train of related work items without losing per-story contract
traceability. The train uses one anchor ticket/workspace and one consolidated
implementation plan for all train members while each member keeps its real
ticket identity, acceptance criteria, subtasks, validation evidence, changelog
entry, tracker transition, and review gate.

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
dependencies, and the consolidated train artifact paths.

Use one consolidated implementation plan file for the whole train:

```text
.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-impl-backend.md
.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-impl-frontend.md
```

Create only the backend or frontend plan file that matches the train's primary
surface. If the train truly spans both surfaces, keep one primary
validator-facing `-impl-` file and add explicit per-surface sections inside it
unless the user explicitly approves a split plan. Do not create
`{STORY_TICKET}-impl-backend.md` or `{STORY_TICKET}-impl-frontend.md` files for
individual train members.

Use one companion implementation spec for the whole train:

```text
.ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-implementation-spec.md
```

The consolidated plan and companion spec must include every train member and
every acceptance criterion from each member. Preserve the member ticket beside
each AC so duplicate IDs such as `AC-01` cannot merge across members.

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

## Planning And Approval

Plan the whole train before implementation starts.

1. Confirm the anchor ticket, ordered member tickets, titles, acceptance
   criteria, child work items, blockers, and dependencies.
2. Create or update the train manifest inside the anchor workspace.
3. Create one consolidated `{ANCHOR_TICKET}-impl-backend.md` or
   `{ANCHOR_TICKET}-impl-frontend.md` file that covers all train members.
4. Create one consolidated `{ANCHOR_TICKET}-implementation-spec.md` companion
   spec that covers all train members.
5. Map every explicit member AC and every in-scope child requirement to
   implementation, validation, completion evidence, and blocker status.
6. Append only a factual planning entry to the anchor changelog.
7. Run the implementation-spec validator against the consolidated anchor plan
   path or anchor ticket, and run the changelog validator against the anchor
   changelog.
8. Stop once for `approve`, `change`, or `deny`.

An explicit `approve` approves the full consolidated train plan exactly as
written. It applies to every train member, AC, validation item, and delivery
step defined in that plan. Do not ask for another planning approval before each
member unless the plan changes, a blocker changes scope, or the user explicitly
requests another gate.

If the user answers `change`, revise the consolidated train plan/spec first and
present the single approval gate again. If the user answers `deny`, stop the
train and do not implement any member.

## Sequential Execution

After the consolidated train plan is approved, process train members in the
declared order.

For each train member:

1. Transition the member to `In Progress` when tracker write tools are available
   and project policy allows it. If not available, record the manual transition
   needed.
2. Implement only the approved scope for that member from the consolidated plan.
3. Complete or explicitly block every approved AC, subtask contract, validation
   item, and dependency for the member before touching the next member.
4. Run the member's validation, QA, and code review using anchor workspace
   evidence.
5. Append a factual changelog entry for the completed member immediately after
   finishing that member. The entry must use the real member ticket and must
   include files changed, AC-specific evidence, validation results, tracker
   transition evidence or manual gap, residual risks, and follow-ups.
6. Validate the anchor changelog after the member entry is appended.
7. Transition the member to `In Revision` or the project-equivalent review state
   when tracker write tools are available and project policy allows it. If not
   available, record the manual transition needed.
8. Continue to the next member only when the current member has complete or
   blocked evidence and the changelog entry is valid.

## Planning Artifact Policy

Use filenames that keep the anchor workspace clear and preserve member identity
without scattering train planning into per-member implementation plans.

Required train-level artifacts:

```text
{ANCHOR_TICKET}-task-train.md
{ANCHOR_TICKET}-impl-backend.md or {ANCHOR_TICKET}-impl-frontend.md
{ANCHOR_TICKET}-implementation-spec.md
{ANCHOR_TICKET}-CHANGELOG.md
PR-{ANCHOR_TICKET}.md
```

Allowed member-specific execution evidence:

```text
QA-{STORY_TICKET}.md
REVIEW-{STORY_TICKET}.md
```

Do not create member-specific `{STORY_TICKET}-impl-*` or
`{STORY_TICKET}-implementation-spec.md` files unless the user explicitly changes
the train artifact policy. Member identity belongs inside the consolidated
anchor plan/spec, the train manifest, QA/review files, and changelog entries.

Validate the consolidated train plan with the anchor ticket or path:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh .ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-impl-backend.md
sh .sdd-kit/tools/validate-changelog.sh .ai-specs/changes/{ANCHOR_TICKET}/{ANCHOR_TICKET}-CHANGELOG.md
```

Use the frontend plan path instead of the backend path when the train's primary
surface is frontend.

Never collapse multiple train members into a generic checklist. A single train
plan is required, but each member must retain separate ticket identity, AC
coverage, validation mapping, dependency notes, and completion evidence.

## Changelog Rules

The anchor changelog is the primary execution evidence for the whole train.

For each train member, append entries that include:

- the real train member ticket in the heading
- files created and modified
- AC-specific validation evidence
- tracker transition evidence or manual transition gap
- blocker and dependency notes
- residual risks and follow-ups

Every train member must have its own changelog entry when it finishes, even
though the train uses one consolidated implementation plan. Do not wait until
the end of the train to write all member entries.

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
2. Validate the consolidated anchor implementation plan and companion spec.
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
- next gate: the single train approval gate before implementation, or the
  current member execution status after approval

Keep the progress view compact. A table with `Pending`, `In Progress`,
`In Revision`, `Blocked`, and `Done` is enough.

## Rules

- Preserve the anchor workspace unless the user explicitly changes it.
- Preserve each train member's real ticket identity in ACs, changelog entries,
  QA, review, and tracker transitions.
- Treat child work items and subtasks as in-scope contract unless explicitly
  documented out of scope.
- Plan all train members in one consolidated anchor `-impl-` file and one
  consolidated anchor implementation spec.
- Do not create per-member implementation plan files for a train unless the
  user explicitly changes the artifact policy.
- Treat one explicit `approve` as approval for every train member and AC defined
  in the consolidated plan.
- Do not ask for per-member planning approval inside an already approved train
  unless scope changes.
- Complete one train member before starting the next.
- Append and validate a changelog entry after each train member finishes.
- Do not create commits or PRs unless the user explicitly asks.
- Generate only one consolidated local train PR report under the anchor
  workspace when PR content is requested.
- Do not omit executed train members from the consolidated PR, even when their
  files or AC IDs overlap with another member.
- Do not invent tracker state when tracker tools are unavailable.
- Output in English.
