# kathy-sdd-kit

Portable **Spec-Driven Development (SDD)** kit for personal projects.
Based on the [LIDR Academy](https://github.com/LIDR-academy/manual-SDD) framework.

Current kit version: `0.4.1` (`VERSION`).

## What is included?

- Development standards: base, backend, and frontend
- Agent behavior standards for assumption management, simplicity, surgical changes, and verification discipline
- Optional engineering rule packs for architecture, DDD, enterprise patterns, refactoring, production readiness, and data-intensive work
- Specialized agents for Claude Code, Cursor, and Codex
- Reusable skills: `enrich-user-story`, `plan-backend-ticket`, `plan-frontend-ticket`, `select-engineering-rules`, `agent-work-discipline`, `resolve-ticket-workspace`, `validate-impl-spec`, `qa-ticket`, `pr-code-review`, `close-ticket-workflow`, `verify-ac-enforcement`, and `write-pr-report`
- Acceptance criteria enforcement as a verifiable delivery contract
- Per-project architecture context template
- Structure ready to import into any project

## Structure

```text
ai-specs/                    <- canonical source of truth
  specs/
    base-standards.mdc       <- general rules
    agent-behavior-standards.mdc <- agent work discipline for scoped, simple, verifiable changes
    backend-standards.mdc    <- Java/Spring Boot standards
    frontend-standards.mdc   <- React/TypeScript standards
    implementation-spec-template.md <- canonical plan template
  rules/
    engineering/             <- optional on-demand engineering rule packs
  .agents/
    backend-agent.md
    frontend-agent.md
    analyst-agent.md
  .commands/                 <- utility prompts (add as needed)
  skills/
    enrich-user-story/       <- /enrich-us
    plan-backend-ticket/     <- /plan-backend-ticket
    plan-frontend-ticket/    <- /plan-frontend-ticket
    select-engineering-rules/ <- choose task-scoped rule packs
    agent-work-discipline/   <- baseline agent behavior discipline
    resolve-ticket-workspace/ <- resolve current ticket workspace paths
    validate-impl-spec/      <- run structural validation for implementation specs
    validate-pr-content/     <- validate generated PR content against local evidence
    qa-ticket/               <- validate AC evidence, regression risks, tests, and readiness
    pr-code-review/          <- pre-PR review for correctness, regressions, security, CI, and readiness
    close-ticket-workflow/   <- correct closure order before PR
    verify-ac-enforcement/   <- kit self-check for AC coverage regressions
    write-pr-report/         <- /write-pr-report
  changes/                   <- canonical examples/templates, not per-ticket workspace

.claude/                     <- Claude Code configuration
.cursor/                     <- Cursor configuration
.codex/                      <- Codex / Copilot configuration
.github/
  pull_request_template.md   <- optional PR template to copy into consuming repositories

docs/
  doc_architecture.md        <- project technical context
  tool-runtime.md            <- shell runtime and Windows guidance
  roles-and-responsibilities.md <- human and agent role boundaries
  tracker-policy.md          <- generic ticket/work-item key policy examples
  adopting-sdd-kit.md        <- professional guide for adding the kit to an existing repo

examples/
  backend-ticket/            <- complete backend planning example
  frontend-ticket/           <- complete frontend planning example
  pr-content/                <- valid and invalid generated PR content examples
  invalid/                   <- fixtures expected to fail validation
  review-fix-ticket/         <- pattern for turning review findings into ACs

AGENTS.md                    <- agent bootstrap to copy into consuming repository root
CLAUDE.md                    <- Claude Code SDD bootstrap loaded from the submodule
CODEX.md                     <- Codex SDD bootstrap loaded from AGENTS.md
```

## Local workspace convention

Projects that consume this kit should keep ticket artifacts in a local, gitignored workspace:

```text
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
- `agent-behavior-standards.mdc` is always-on discipline for scoped, simple, verifiable agent work
- `ai-specs/rules/engineering/` rule packs are optional and loaded only when selected for the task
- `{TICKET}` is the canonical ticket/work-item key for the consuming project
- Examples: `JAP-160`, `ENG-123`, `GH-42`, `160`, `task-160`
- If a user gives ambiguous shorthand, resolve it using the consuming project's ticket policy before writing artifacts
- Before planning, inspect the parent work item and any linked child work items, subtasks, checklist items, or implementation tasks
- Plans and companion specs must include `Related Work Items`; in-scope child work items with technical requirements must map to ACs, validation, or blockers
- Do not use branch names or branch descriptions in artifact paths
- `PR-{TICKET}.md` is generated locally from the current `.ai-specs` state and does not need to be committed
- Root `AGENTS.md` activates the kit for Codex and compatible agents
- Root `AGENTS.md` may contain consuming-project overrides. Do not overwrite it blindly after installation.
- Root `CLAUDE.md` remains the project-specific Claude Code context and should link `.sdd-kit/CLAUDE.md`
- Never replace an existing root `CLAUDE.md` with the kit file; append the kit include instead

## Tool runtime

The kit assumes Git is installed. Shell tools are POSIX `sh` scripts and should
be invoked explicitly with `sh`:

```bash
sh .sdd-kit/tools/resolve-ticket-workspace.sh {TICKET}
sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
sh .sdd-kit/tools/validate-pr-content.sh {TICKET}
sh .sdd-kit/tools/validate-engineering-rules.sh
```

On Windows, Git for Windows provides `sh.exe` through Git Bash. Avoid relying on
direct script execution from PowerShell; invoke tools through `sh`.

See `docs/tool-runtime.md` for supported shell environments and PowerShell
examples.

## How to use it in a new project

For existing repositories, start with `docs/adopting-sdd-kit.md`. It describes
the recommended rollout, entrypoint merge strategy, ticket policy, local
workspace handling, and pilot-ticket checklist.

**Option A - git submodule (recommended for updates)**
```bash
cd your-project
git submodule add https://github.com/kathesama/kathy-sdd-kit .sdd-kit
cp .sdd-kit/AGENTS.md ./AGENTS.md
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

7. If the project uses PR report generation, confirm
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
- **SDD Kit Version**: 0.4.1
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
6. /plan-backend-ticket [TICKET]      -> generate plan/spec/changelog in .ai-specs/changes/{TICKET}/
7. /validate-impl-spec [TICKET]       -> validate AC mapping in plan and companion spec
8. Approval gate                       -> stop and ask approve/change/deny
9. /develop-backend @[plan].md         -> only after explicit approve
10. /qa-ticket [ID or IMPL].md          -> validate AC evidence, regression risks, tests, and readiness
11. /pr-code-review [ID or IMPL].md     -> review correctness, regressions, security, CI/readiness, and PR evidence
12. /write-pr-report @[IMPL].md        -> generate PR-{TICKET}.md from local .ai-specs state
13. /validate-pr-content [TICKET]      -> verify PR content does not invent evidence
14. /close-ticket-workflow [ID]        -> perform final closure sequence before PR
15. PR -> Review -> Merge              -> feature published
```

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
| `/validate-impl-spec [ID or path]` | Validate structural AC coverage of the implementation plan and companion spec |
| `/validate-pr-content [ID or path]` | Validate generated PR content against local SDD evidence |
| `/qa-ticket [ID or path]` | Validate implementation evidence against story/spec acceptance criteria, including regression-oriented risks |
| `/pr-code-review [ID or path]` | Review local changes for correctness, regressions, security, tests, CI/readiness, and PR evidence |
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
- Checked PR validation and CI items must have matching evidence in the local ticket folder

## Agent Behavior and Engineering Rule Packs

`agent-behavior-standards.mdc` is the baseline behavior layer for agents. It
requires agents to surface material assumptions, avoid speculative work, keep
changes surgical, and verify before claiming completion.

Engineering rule packs live under `ai-specs/rules/engineering/` and are loaded
on demand through `select-engineering-rules`. They provide focused technical
lenses for Clean Architecture, Domain-Driven Design, Patterns of Enterprise
Application Architecture, Refactoring, Release It!, and Designing
Data-Intensive Applications. They do not override acceptance criteria, ADRs, or
project-local instructions.

Implementation specs must list all six packs in the `Engineering Rule Packs`
table under `Execution Notes for Implementer`. Selected packs require active
obligation IDs from the pack's `Enforcement Contract`, a non-`N/A` validation
impact, and traceability through implementation mapping, validation, QA, review,
and PR content. The validators block selected packs or active obligations that
are not carried through the evidence chain.

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
