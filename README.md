# kathy-sdd-kit

Portable **Spec-Driven Development (SDD)** kit for personal projects.
Based on the [LIDR Academy](https://github.com/LIDR-academy/manual-SDD) framework.

Current kit version: `0.6.0` (`VERSION`).

## What is included?

- SDD standards for base workflow, backend, frontend, agent behavior,
  changelogs, implementation specs, and project-local design contracts.
- Frontend guardrails for Component-Driven UI Architecture, State Ownership &
  Data Flow, API contract consumption, accessibility, validation, and
  design-system evidence.
- Optional engineering rule packs for Clean Architecture, DDD, enterprise
  patterns, module design, clean-code construction discipline, refactoring,
  pragmatic delivery judgment, legacy-code change safety, production readiness,
  and data-intensive work.
- Root `DESIGN.md` support for standardizing project-local visual identity
  contracts, with `docs/design-system/MASTER.md` as the preferred detailed
  design-system source.
- API contract workflows for syncing backend contract artifacts into UI repos
  and consuming those artifacts without inventing endpoints or payload fields.
- Reusable SDD skills: `agent-work-discipline`, `analyze-sdd-artifacts`,
  `api-contract-sync`, `close-ticket-workflow`, `consume-api-contract`,
  `complexity-review`, `debt-harvest`, `execute-task-train`,
  `enrich-user-story`,
  `plan-backend-ticket`, `plan-frontend-ticket`, `pr-code-review`,
  `qa-ticket`, `resolve-ticket-workspace`,
  `select-engineering-rules`, `standardize-design-contract`,
  `validate-impl-spec`, `validate-pr-content`, `verify-ac-enforcement`, and
  `write-pr-report`.
- Tool-specific skill exposure for Codex, Claude Code, and Cursor through
  `.agents/skills/`, `.claude/skills/`, `.cursor/skills/`, and `.codex/`
  links, while `ai-specs/skills/` remains the single editable source.
- Entrypoints for Codex-compatible agents (`AGENTS.md` and `CODEX.md`) and
  Claude Code (`CLAUDE.md` include target).
- Validation tools for ticket workspace resolution, implementation specs,
  changelogs, engineering rule packs, PR content, and skill exposure sync.
- Examples and negative fixtures for backend/frontend planning, PR content,
  engineering rule enforcement, invalid specs, and review-fix workflows.
- Starter PR template and kit CI workflow.
- Documentation for adoption, runtime, roles, tracker-neutral ticket policy,
  architecture context, and AC enforcement pressure scenarios.

## Structure

```text
VERSION                      <- current kit version
AGENTS.md                    <- root agent bootstrap copied to consuming repos
CODEX.md                     <- Codex bootstrap loaded from AGENTS.md
CLAUDE.md                    <- Claude Code SDD include target
README.md

ai-specs/                    <- canonical SDD framework source
  specs/
    agent-behavior-standards.mdc <- assumption, scope, and verification discipline
    backend-standards.mdc    <- backend implementation standards
    base-standards.mdc       <- SDD workflow and AC contract rules
    changelog-template.md    <- append-only ticket changelog template
    design-md-template.md    <- starter root DESIGN.md template
    design-system-standards.mdc <- DESIGN.md and visual identity contract rules
    frontend-standards.mdc   <- frontend, component, state, API, a11y standards
    implementation-spec-template.md <- canonical plan template
  rules/
    engineering/
      README.md
      a-philosophy-of-software-design.mini.md
      clean-architecture.mini.md
      clean-code.mini.md
      code-complete.mini.md
      data-intensive.mini.md
      domain-driven-design.mini.md
      domain-driven-design-distilled.mini.md
      implementing-domain-driven-design.mini.md
      patterns-of-enterprise-application-architecture.mini.md
      refactoring.mini.md
      refactoring-guru.mini.md
      release-it.mini.md
      the-pragmatic-programmer.mini.md
      working-effectively-with-legacy-code.mini.md
  .agents/
    analyst-agent.md
    backend-agent.md
    frontend-agent.md
  .commands/
    .gitkeep                 <- reserved for future command prompts
  changes/
    .gitkeep                 <- framework placeholder, not per-ticket workspace
  skills/
    agent-work-discipline/
    analyze-sdd-artifacts/
    api-contract-sync/
      scripts/
        sync-api-contract.ps1
        sync-api-contract.sh
    close-ticket-workflow/
    complexity-review/
    consume-api-contract/
    debt-harvest/
    execute-task-train/
    enrich-user-story/
    plan-backend-ticket/
    plan-frontend-ticket/
    pr-code-review/
    qa-ticket/
    resolve-ticket-workspace/
    select-engineering-rules/
    standardize-design-contract/
    validate-impl-spec/
    validate-pr-content/
    verify-ac-enforcement/
    write-pr-report/

docs/
  ac-enforcement-pressure-scenarios.md <- regression scenarios for kit workflow changes
  adopting-sdd-kit.md        <- guide for adding the kit to an existing repo
  doc_architecture.md        <- project technical context
  roles-and-responsibilities.md <- human and agent role boundaries
  tool-runtime.md            <- shell runtime and Windows guidance
  tracker-policy.md          <- generic ticket/work-item key policy examples

examples/
  backend-ticket/            <- complete backend planning example
  engineering-rules/         <- valid and invalid engineering rule evidence fixtures
  frontend-ticket/           <- complete frontend planning example
  invalid/                   <- fixtures expected to fail validation
  pr-content/                <- valid and invalid generated PR content examples
  review-fix-ticket/         <- pattern for turning review findings into ACs

tools/
  resolve-ticket-workspace.sh
  sync-agent-skills.sh       <- expose SDD skills to .agents/.claude/.cursor
  sync-codex-skills.sh       <- compatibility wrapper for sync-agent-skills.sh
  validate-changelog.sh
  validate-engineering-rules.sh
  validate-impl-spec.sh
  validate-pr-content.sh

.agents/
  skills/                    <- Codex skill exposure, junctions to ai-specs/skills
.claude/
  agents -> ../ai-specs/.agents
  commands/                  <- Claude command exposure placeholder
  skills -> ../ai-specs/skills
.codex/
  agents -> ../ai-specs/.agents
  skills -> ../ai-specs/skills
.cursor/
  agents -> ../ai-specs/.agents
  rules/
    agent-behavior-standards.mdc
  skills -> ../ai-specs/skills
.github/
  pull_request_template.md   <- starter PR template for consuming repos
  workflows/
    sdd-kit.yml              <- kit repository validation workflow
```

## Local workspace convention

Projects that consume this kit should keep ticket artifacts in a local, gitignored workspace:

```text
AGENTS.md
DESIGN.md                    <- optional root visual identity contract for frontend/UI projects
docs/design-system/MASTER.md <- optional detailed design-system source for UI projects
docs/contracts/              <- optional API contract artifacts and sync config
.sdd-kit/                    <- mounted kathy-sdd-kit framework
.agents/skills/              <- Codex-local SDD skill exposure
.claude/skills/              <- Claude-local SDD skill exposure when needed
.cursor/skills/              <- Cursor-local SDD skill exposure when needed
.ai-specs/
  changes/
    {TICKET}/
      {TICKET}-enriched.md
      {TICKET}-impl-backend.md
      {TICKET}-impl-frontend.md
      {TICKET}-implementation-spec.md
      {TICKET}-CHANGELOG.md
      QA-{TICKET}.md
      REVIEW-{TICKET}.md
      PR-{TICKET}.md
```

Recommended usage:

- `.sdd-kit/` remains the shared framework and source of truth
- `.ai-specs/` is local working state for the current repository
- Root `DESIGN.md`, when present, is project-local visual identity context for
  frontend/UI work and should remain in the consuming repository root
- `agent-behavior-standards.mdc` is always-on discipline for scoped, simple, verifiable agent work
- `ai-specs/rules/engineering/` rule packs are optional and loaded only when selected for the task
- Frontend/UI work follows Component-Driven UI Architecture and State Ownership
  & Data Flow from `frontend-standards.mdc`
- `docs/contracts/`, when present, contains optional API contract artifacts
  and should be consumed before API-backed UI planning
- `{TICKET}` is the canonical ticket/work-item key for the consuming project
- Examples: `JAP-160`, `ENG-123`, `GH-42`, `160`, `task-160`
- If a user gives ambiguous shorthand, resolve it using the consuming project's ticket policy before writing artifacts
- Before planning, inspect the parent work item and any linked child work items, subtasks, checklist items, or implementation tasks
- Plans and companion specs must include `Related Work Items`; in-scope child work items with technical requirements must map to ACs, validation, or blockers
- Do not use branch names or branch descriptions in artifact paths
- `PR-{TICKET}.md` is generated locally from the current `.ai-specs` state and does not need to be committed
- Root `AGENTS.md` activates the kit for Codex and compatible agents
- Root `AGENTS.md` may contain consuming-project overrides. Do not overwrite it blindly after installation.
- For Codex, expose SDD skills into `.agents/skills/` with
  `.sdd-kit/tools/sync-agent-skills.sh` so QA, review, and PR workflows do not
  fall back to global homonymous skills.
- Root `CLAUDE.md` remains the project-specific Claude Code context and should link `.sdd-kit/CLAUDE.md`
- Never replace an existing root `CLAUDE.md` with the kit file; append the kit include instead

## Tool runtime

The kit assumes Git is installed. Shell tools are POSIX `sh` scripts and should
be invoked explicitly with `sh`:

```bash
sh .sdd-kit/tools/resolve-ticket-workspace.sh {TICKET}
sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
sh .sdd-kit/tools/validate-changelog.sh {TICKET}
sh .sdd-kit/tools/validate-pr-content.sh {TICKET}
sh .sdd-kit/tools/validate-engineering-rules.sh
sh .sdd-kit/tools/sync-agent-skills.sh --check
```

On Windows, Git for Windows provides `sh.exe` through Git Bash. Avoid relying on
direct script execution from PowerShell; invoke tools through `sh`.

See `docs/tool-runtime.md` for supported shell environments and PowerShell
examples.

## How to use it in a new project

For existing repositories, start with `docs/adopting-sdd-kit.md`. It describes
the recommended rollout, entrypoint merge strategy, ticket policy, local
workspace handling, and pilot-ticket checklist.

After mounting the kit and merging root `AGENTS.md`, expose the SDD skills for
the local tools:

```bash
sh .sdd-kit/tools/sync-agent-skills.sh --write
```

This exposes the SDD workflows under `.agents/skills/`, `.claude/skills/`, and
`.cursor/skills/` from the single source in `.sdd-kit/ai-specs/skills/`.

**Option A - git submodule (recommended for updates)**
```bash
cd your-project
git submodule add https://github.com/kathesama/kathy-sdd-kit .sdd-kit
cp .sdd-kit/AGENTS.md ./AGENTS.md
sh .sdd-kit/tools/sync-agent-skills.sh --write
mkdir -p .github
cp .sdd-kit/.github/pull_request_template.md ./.github/pull_request_template.md
# For Claude Code, DO NOT replace an existing CLAUDE.md.
# Add this line to the root CLAUDE.md:
# @.sdd-kit/CLAUDE.md
#
# If the project has no CLAUDE.md yet, create one with project context plus that include.
```

**Option B - direct copy**
```bash
cd your-project
git clone https://github.com/kathesama/kathy-sdd-kit .sdd-kit
cp .sdd-kit/AGENTS.md ./AGENTS.md
sh .sdd-kit/tools/sync-agent-skills.sh --write
mkdir -p .github
cp .sdd-kit/.github/pull_request_template.md ./.github/pull_request_template.md
# For Claude Code, DO NOT replace an existing CLAUDE.md.
# Add this line to the root CLAUDE.md:
# @.sdd-kit/CLAUDE.md
#
# If the project has no CLAUDE.md yet, create one with project context plus that include.
```

## Updating The Kit

When updating the `.sdd-kit` submodule, review the consumer entrypoints too.

Recommended update checklist:

1. Update the submodule pointer in the consuming repository:

   ```bash
   git submodule update --remote .sdd-kit
   git status --short
   git diff --submodule
   ```

   If the consuming repository pins the kit to a specific commit:

   ```bash
   git -C .sdd-kit fetch
   git -C .sdd-kit checkout <kit-commit>
   git status --short
   git diff --submodule
   ```

   Commit the resulting `.sdd-kit` pointer change in the consuming repository
   according to that repository's normal review process.

2. If the kit was installed as a direct clone instead of a submodule, update it:

   ```bash
   git -C .sdd-kit pull --ff-only
   ```

3. Review `.sdd-kit/AGENTS.md` against the repository root `AGENTS.md`.
4. If the root `AGENTS.md` has no project-specific overrides, refresh it:

   ```bash
   cp .sdd-kit/AGENTS.md ./AGENTS.md
   ```

5. If the root `AGENTS.md` has project-specific overrides, merge the kit changes
   manually and preserve the local override sections.
6. Do not replace root `CLAUDE.md`. Confirm it still includes:

   ```md
   @.sdd-kit/CLAUDE.md
   ```

7. Refresh the project-local SDD skill exposure:

   ```bash
   sh .sdd-kit/tools/sync-agent-skills.sh --write
   sh .sdd-kit/tools/sync-agent-skills.sh --check
   ```

8. If the project uses PR report generation, confirm
   `.github/pull_request_template.md` exists or intentionally remains absent.

The kit does not provide an automatic entrypoint updater by default because
consumer repositories may customize `AGENTS.md`. Blind replacement can remove
local ticket policy, security, workflow, or repository-specific rules.

Do not make durable framework changes inside a consuming repository's mounted
`.sdd-kit/` folder. Make those changes in the `kathy-sdd-kit` source repository,
publish/review them there, and then update each consuming repository's
submodule pointer.

## Agent entrypoints

The kit is designed so consuming projects copy only the root entrypoints they
need and keep reusable SDD assets inside `.sdd-kit/`.

### Codex and compatible agents

Copy `.sdd-kit/AGENTS.md` to the consuming repository root:

```text
<PROJECT_ROOT>/AGENTS.md
```

`AGENTS.md` tells Codex to load `.sdd-kit/CODEX.md` and to use framework files
from `.sdd-kit/ai-specs/`.

Then expose SDD skills into the repository-local tool skill directories:

```bash
sh .sdd-kit/tools/sync-agent-skills.sh --write
```

This keeps `ai-specs/skills/` as the single editable source and avoids
accidental fallback to global skills with the same workflow names.

If the consuming project adds local rules to root `AGENTS.md`, keep them in a
clearly marked project override section and preserve them when updating the kit.

### Claude Code

Claude Code loads the consuming repository's root `CLAUDE.md` automatically.
That file should remain project-specific: architecture, ADRs, services, ports,
stack, and local constraints.

Do not overwrite an existing root `CLAUDE.md` with `.sdd-kit/CLAUDE.md`.
Replacing it would remove project context. To add the reusable SDD workflow,
append this include to the root `CLAUDE.md`:

```md
## SDD Kit

This project uses kathy-sdd-kit.

@.sdd-kit/CLAUDE.md
```

If the consuming project has no `CLAUDE.md`, create one at the root with the
project context first and the kit include after it:

```md
# Project Context

Describe the architecture, ADRs, services, stack, and local constraints here.

## SDD Kit

@.sdd-kit/CLAUDE.md
```

## Versioning

The kit source has a `VERSION` file. Plans and implementation specs should
record the SDD kit version used to create them:

```md
- **SDD Kit Version**: 0.6.0
```

This helps teams diagnose behavior differences when repositories update the
submodule at different times.

## Roles

The expected human and agent roles are documented in
`docs/roles-and-responsibilities.md`.

In short:

- Human approver owns scope and approval decisions.
- Planner creates and validates plan/spec/changelog, then stops.
- Developer executes only after approval.
- QA validates behavior against the delivery contract.
- Code review validates technical quality.
- PR report agent generates PR content from local evidence only.

## Ticket Tracker Policy

The default ticket policy is provider-agnostic. `{TICKET}` means the canonical
work-item key for the consuming project. See `docs/tracker-policy.md` for
examples across Jira, Linear, GitHub Issues, Salesforce work items, Azure DevOps,
Shortcut, YouTrack, Asana, Trello, and internal trackers.

### Local ticket workspace

Do not copy `.sdd-kit/ai-specs/` into the project root for normal submodule
usage. The submodule copy is the framework source. Create only project-local
ticket artifacts under:

```text
<PROJECT_ROOT>/.ai-specs/changes/
```

## PR template

The kit includes `.github/pull_request_template.md` as a starter template.

GitHub and `/write-pr-report` use the template from the consuming repository root:

```text
<PROJECT_ROOT>/.github/pull_request_template.md
```

If the kit is installed as `.sdd-kit`, the template inside `.sdd-kit/.github/` is only a source copy. Copy it to the project root `.github/` folder if you want GitHub and `/write-pr-report` to use it.

The starter template uses `Suggested commit messages`, not `Key commits`,
because agents often prepare PR content before commits exist. Use real commit
hashes only when they are available.

## Full SDD flow

```text
1. /enrich-us [description]           -> enrich the user story and close decisions
2. Create TC in Confluence            -> Technical Contract approved
3. /resolve-ticket-workspace [TICKET] -> resolve canonical ticket paths
4. Inspect parent + child work items   -> map subtasks/checklists into scope, ACs, validation, or blockers
5. /select-engineering-rules [context] -> choose optional task-scoped technical lenses
6. /api-contract-sync                 -> optional cross-repo API contract sync when backend contracts changed
7. /standardize-design-contract       -> optional/prework for frontend UI repos missing DESIGN.md
8. /consume-api-contract              -> required before planning API-consuming frontend/UI work when contract artifacts exist
9. /plan-backend-ticket [TICKET]      -> generate backend plan/spec/changelog in .ai-specs/changes/{TICKET}/
10. /plan-frontend-ticket [TICKET]     -> generate frontend plan/spec/changelog in .ai-specs/changes/{TICKET}/
11. /validate-impl-spec [TICKET]       -> validate AC mapping in plan and companion spec
12. /analyze-sdd-artifacts [TICKET]    -> optional semantic consistency analysis
13. Approval gate                      -> stop and ask approve/change/deny
14. /develop-backend @[plan].md        -> only after explicit approve
15. /develop-frontend @[plan].md       -> only after explicit approve
16. /qa-ticket [ID or IMPL].md         -> validate AC evidence, regression risks, tests, and readiness
17. /pr-code-review [ID or IMPL].md    -> review correctness, regressions, security, CI/readiness, and PR evidence
18. /write-pr-report @[IMPL].md        -> generate PR-{TICKET}.md from local .ai-specs state
19. /validate-pr-content [TICKET]      -> verify PR content does not invent evidence
20. /close-ticket-workflow [ID]        -> perform final closure sequence before PR
21. PR -> Review -> Merge              -> feature published
```

For sequential trains of related stories or tickets, run
`/execute-task-train [ANCHOR_TICKET]` before planning the first train member.
The train uses `.ai-specs/changes/{ANCHOR_TICKET}/` as the single workspace,
with one consolidated `{ANCHOR_TICKET}-impl-backend.md` or
`{ANCHOR_TICKET}-impl-frontend.md` file and one consolidated
`{ANCHOR_TICKET}-implementation-spec.md` covering every train member and every
member AC. Each member still keeps its own ticket identity, AC coverage,
changelog entry, tracker transition, and QA/review evidence.
The train has one planning approval gate: `approve` authorizes everything
defined in the consolidated train plan, not one task at a time. After approval,
execute members sequentially and append a factual changelog entry when each
member finishes.
When PR content is requested for the train, generate one consolidated
`.ai-specs/changes/{ANCHOR_TICKET}/PR-{ANCHOR_TICKET}.md` that includes every
executed train member and separates pending or blocked members from completed
work.

## Planning Approval Gate

Planning and implementation are separate phases.

`/plan-backend-ticket` and `/plan-frontend-ticket` must create:

```text
.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md
.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md
.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md
.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md
```

Only the relevant backend or frontend plan is required for a single-surface
ticket. The companion `{TICKET}-implementation-spec.md` and changelog are always
required.

After these files are generated, run:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
```

Then stop and ask the user for one of:

- `approve` - execute the plan exactly as written
- `change` - revise the planning artifacts, then present the gate again
- `deny` - stop ticket execution

Generating the plan is not approval to execute the plan. Agents must not write
tests, production code, migrations, styles, or configuration until the user
explicitly answers `approve`.

Planning must also show the parent and related child work items considered. Any
in-scope child work item that refines behavior must map to an AC, validation
entry, or documented blocker before the approval gate.

## Available commands

| Command | Description |
|---|---|
| `/enrich-us [desc]` | Enrich a user story |
| `/plan-backend-ticket [ID]` | Generate a backend implementation plan |
| `/plan-frontend-ticket [ID]` | Generate a frontend implementation plan |
| `/select-engineering-rules [context]` | Select optional engineering rule packs for planning, QA, or review |
| `/agent-work-discipline` | Apply baseline agent behavior discipline for scoped, simple, verifiable changes |
| `/resolve-ticket-workspace [ID]` | Resolve local `.ai-specs` paths from input or branch |
| `/api-contract-sync` | Sync API contract artifacts from an API repo into a frontend/UI repo |
| `/consume-api-contract` | Map API-consuming UI behavior to documented contract artifacts before planning or implementation |
| `/validate-impl-spec [ID or path]` | Validate structural AC coverage of the implementation plan and companion spec |
| `/validate-pr-content [ID or path]` | Validate generated PR content against local SDD evidence |
| `/standardize-design-contract` | Create or update root `DESIGN.md` from local design sources, asking when the primary source is unclear |
| `/analyze-sdd-artifacts [ID or path]` | Read-only semantic analysis across story, specs, changelog, QA, review, rule packs, and optional design-system evidence |
| `/qa-ticket [ID or path]` | Validate implementation evidence against story/spec acceptance criteria, including regression-oriented risks |
| `/pr-code-review [ID or path]` | Review local changes for correctness, regressions, security, tests, CI/readiness, and PR evidence |
| `/complexity-review` | Run a read-only over-engineering review of the current implementation diff |
| `/debt-harvest [ID]` | Append validated `sdd-simplification:` marker evidence to the ticket changelog |
| `/execute-task-train [ANCHOR]` | Orchestrate a sequential ticket train under one anchor workspace, one consolidated implementation plan, and one consolidated PR report without losing per-story evidence |
| `/close-ticket-workflow [ID]` | Apply the correct end-of-ticket validation and PR sequence |
| `/verify-ac-enforcement` | Validate that the kit still enforces AC coverage end-to-end |
| `/develop-backend @[plan].md` | Implement following the backend plan |
| `/develop-frontend @[plan].md` | Implement following the frontend plan |
| `/write-pr-report @[IMPL].md` | Generate PR description |

## Acceptance Criteria Contract

- Every story must have acceptance criteria with stable IDs (`AC-01`, `AC-02`, ...)
- Parent and child work items must be inspected before planning when the tracker exposes them
- In-scope child work items that refine behavior must be represented in ACs, validation, or blockers
- The plan must map each AC to explicit implementation and validation
- A task cannot be marked done without evidence per AC
- The PR report must include status and evidence for every acceptance criterion
- Task-train PR reports must consolidate every executed member under the anchor
  PR file while preserving each member ticket beside its AC evidence
- Task-train implementation plans must consolidate all train members under the
  anchor `-impl-` file; one `approve` applies to the whole consolidated plan
- Each completed train member must append its own factual changelog entry under
  the anchor changelog
- Checked PR validation and CI items must have matching evidence in the local ticket folder

## Agent Behavior and Engineering Rule Packs

`agent-behavior-standards.mdc` is the baseline behavior layer for agents. It
requires agents to surface material assumptions, avoid speculative work, keep
changes surgical, and verify before claiming completion.

Engineering rule packs live under `ai-specs/rules/engineering/` and are loaded
on demand through `select-engineering-rules`. They provide focused technical
lenses for Clean Architecture, Clean Code, Code Complete, Domain-Driven
Design, Domain-Driven Design Distilled, Implementing Domain-Driven Design,
Patterns of Enterprise Application Architecture, A Philosophy of Software
Design, Refactoring, Refactoring Guru, Working Effectively with Legacy Code,
The Pragmatic Programmer, Release It!, and Designing Data-Intensive
Applications. They do not override acceptance criteria, ADRs, or project-local
instructions.

Implementation specs must list every available pack in the `Engineering Rule
Packs` table under `Execution Notes for Implementer`. Selected packs require active
obligation IDs from the pack's `Enforcement Contract`, a non-`N/A` validation
impact, and traceability through implementation mapping, validation, QA, review,
and PR content. The validators block selected packs or active obligations that
are not carried through the evidence chain.

## Design System Contract

Frontend/UI work can use a project-local visual identity contract without making
the kit product-specific. Root `DESIGN.md` is the design agent contract; the
detailed human-facing source should live at `docs/design-system/MASTER.md` when
the project has one.

- If a consuming repository has root `DESIGN.md`, agents treat it as the visual
  identity contract for planning, implementation, QA, and review.
- If `DESIGN.md` is absent, agents inspect local Storybook, token files,
  Tailwind config, shadcn theme, UI docs, ADRs, screenshots, and existing
  components before planning visual changes.
- If those local design sources already exist, they should be used to create or
  update root `DESIGN.md`. Using them directly is a temporary fallback, not the
  preferred steady state.
- Use `/standardize-design-contract` when `DESIGN.md` must be created or
  refreshed. The skill reads the most authoritative local source first, such as
  a user-named master document, `docs/design-system/MASTER.md`,
  `docs/design/MASTER.md`, existing `design-system/**/MASTER.md`, Storybook,
  tokens, Tailwind, shadcn, shared components, docs, ADRs, or screenshots. If
  the primary source is unclear, it asks before writing.
- For new frontend/UI documentation, prefer `docs/design-system/MASTER.md` as
  the detailed human-facing source. Root `DESIGN.md` remains the agent-facing
  summary and should point to the master source.
- If no durable design source exists beyond current UI code, frontend plans
  record the fallback convention and residual risk.
- The starter template lives at `ai-specs/specs/design-md-template.md` and is
  copied to the consuming repository root during frontend/UI adoption.
- `design-system-standards.mdc` defines the generic planning, implementation,
  and validation rules.

## Frontend Architecture Patterns

`frontend-standards.mdc` defines two required frontend patterns for UI work:

- **Component-Driven UI Architecture**: build UI as a component library made of
  primitives, composed components, feature components, and pages. Pages and
  routes compose named component tags and wire data; they should not define new
  visible UI as inline JSX blocks. New visible components need typed props,
  parameterization when reuse is plausible, colocated tests, and Storybook
  stories when the repository has that tooling.
- **State Ownership & Data Flow**: keep state at the closest owner that needs
  it. Use props/callbacks for local parent-child composition, feature
  context/hooks or existing client stores for cross-tree client state, React
  Query for server state, form tooling for form state, and URL/search params for
  shareable navigation state. Avoid prop drilling through passive parents and
  avoid duplicating server state in client stores.

Frontend plans must record componentization and state ownership decisions in
`Execution Notes for Implementer`. QA and review must flag inline UI,
missing stories/tests, prop drilling, inappropriate global store usage, and
server-state duplication.

## API Contract Workflows

The kit supports API-backed frontend work without making the UI repository the
source of truth for backend contracts.

- `api-contract-sync` runs from an API/backend repository with
  `docs/contracts/api-contract-sync.json` and copies configured contract
  artifacts into a frontend/UI repository. If this file is absent, API
  contract sync is disabled/no-op.
- Recommended copied artifacts are `docs/contracts/api-contract.md`,
  `docs/contracts/capabilities.json`, `docs/contracts/api-contract.yml`, and
  `docs/contracts/api-contract-source.json`.
- `consume-api-contract` runs in the frontend/UI repository before planning or
  implementing API-consuming screens, hooks, forms, permissions, mocks, or
  capability-gated UI.
- Frontend agents must not invent endpoints, payload fields, auth rules,
  capability names, status codes, or response shapes. Missing behavior is a
  contract gap or blocker.
- Generated or copied API contract files in the UI repository are read-only;
  update the API source and rerun `api-contract-sync` when the contract must
  change.

## Examples

Reference examples live under `examples/`:

- `examples/backend-ticket/JAP-100/`
- `examples/frontend-ticket/WEB-42/`
- `examples/pr-content/valid/`
- `examples/pr-content/invalid/`
- `examples/invalid/missing-related-work-items/`
- `examples/review-fix-ticket/JAP-160/`
- `examples/engineering-rules/JAP-210-rule-selection.md`
- `examples/engineering-rules/valid/`
- `examples/engineering-rules/invalid/`

They are documentation examples, not local ticket artifacts. Do not copy them
into `.ai-specs/changes/` unless adapting them for a real ticket.

## Kit CI

The kit source includes `.github/workflows/sdd-kit.yml`. It validates shell
syntax, valid examples, and negative fixtures expected to fail. This CI belongs
to the kit repository itself; consuming projects do not need to copy it.

## Based on

- [LIDR ai-specs](https://github.com/LIDR-academy/ai-specs)
- [LIDR manual-SDD](https://github.com/LIDR-academy/manual-SDD)
- [claude-mem](https://github.com/thedotmack/claude-mem)
- [superpowers](https://github.com/obra/superpowers)
- [agent-rules-books](https://github.com/ciembor/agent-rules-books)
- [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)
- [google-labs-code/design.md](https://github.com/google-labs-code/design.md)
- [github/spec-kit](https://github.com/github/spec-kit)
- [ponytail](https://github.com/DietrichGebert/ponytail)

See `docs/upstream-sources.md` for audited revisions, incorporated surfaces,
candidate sources, and follow-up import decisions.
