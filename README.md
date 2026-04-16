# kathy-sdd-kit

Portable **Spec-Driven Development (SDD)** kit for personal projects.
Based on the [LIDR Academy](https://github.com/LIDR-academy/manual-SDD) framework.

## What is included?

- Development standards: base, backend, and frontend
- Specialized agents for Claude Code, Cursor, and Codex
- Reusable skills: `enrich-user-story`, `plan-backend-ticket`, `plan-frontend-ticket`, `resolve-ticket-workspace`, `validate-impl-spec`, `qa-ticket`, `pr-code-review`, `close-ticket-workflow`, `verify-ac-enforcement`, and `write-pr-report`
- Acceptance criteria enforcement as a verifiable delivery contract
- Per-project architecture context template
- Structure ready to import into any project

## Structure

```text
ai-specs/                    <- canonical source of truth
  specs/
    base-standards.mdc       <- general rules
    backend-standards.mdc    <- Java/Spring Boot standards
    frontend-standards.mdc   <- React/TypeScript standards
    implementation-spec-template.md <- canonical plan template
  .agents/
    backend-agent.md
    frontend-agent.md
    analyst-agent.md
  .commands/                 <- utility prompts (add as needed)
  skills/
    enrich-user-story/       <- /enrich-us
    plan-backend-ticket/     <- /plan-backend-ticket
    plan-frontend-ticket/    <- /plan-frontend-ticket
    resolve-ticket-workspace/ <- resolve current ticket workspace paths
    validate-impl-spec/      <- run structural validation for implementation specs
    qa-ticket/               <- validate AC evidence, tests, risks, and readiness
    pr-code-review/          <- pre-PR review for correctness, security, CI, and readiness
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
      QA-{TICKET}.md
      REVIEW-{TICKET}.md
      PR-{TICKET}.md
```

Recommended usage:

- `.sdd-kit/` remains the shared framework and source of truth
- `.ai-specs/` is local working state for the current repository
- `PR-{TICKET}.md` is generated locally from the current `.ai-specs` state and does not need to be committed
- Root `AGENTS.md` activates the kit for Codex and compatible agents
- Root `CLAUDE.md` remains the project-specific Claude Code context and should link `.sdd-kit/CLAUDE.md`
- Never replace an existing root `CLAUDE.md` with the kit file; append the kit include instead

## How to use it in a new project

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

## Full SDD flow

```text
1. /enrich-us [description]           -> enrich the user story and close decisions
2. Create TC in Confluence            -> Technical Contract approved
3. /plan-backend-ticket [ID]          -> generate Implementation Spec in .ai-specs/changes/{TICKET}/ using .sdd-kit templates
4. /develop-backend @[plan].md        -> implement following the spec
5. /resolve-ticket-workspace [ID]     -> resolve current ticket paths from input or branch
6. /validate-impl-spec [ID or path]   -> validate AC mapping before execution/QA/PR
7. /qa-ticket [ID or IMPL].md         -> validate AC evidence, tests, and risks
8. /pr-code-review [ID or IMPL].md    -> review correctness, security, CI/readiness, and PR evidence
9. /write-pr-report @[IMPL].md        -> generate PR-{TICKET}.md from local .ai-specs state
10. /close-ticket-workflow [ID]       -> perform final closure sequence before PR
11. PR -> Review -> Merge             -> feature published
```

## Available commands

| Command | Description |
|---|---|
| `/enrich-us [desc]` | Enrich a user story |
| `/plan-backend-ticket [ID]` | Generate a backend implementation plan |
| `/plan-frontend-ticket [ID]` | Generate a frontend implementation plan |
| `/resolve-ticket-workspace [ID]` | Resolve local `.ai-specs` paths from input or branch |
| `/validate-impl-spec [ID or path]` | Validate structural AC coverage of an implementation spec |
| `/qa-ticket [ID or path]` | Validate implementation evidence against story/spec acceptance criteria |
| `/pr-code-review [ID or path]` | Review local changes for correctness, security, tests, CI/readiness, and PR evidence |
| `/close-ticket-workflow [ID]` | Apply the correct end-of-ticket validation and PR sequence |
| `/verify-ac-enforcement` | Validate that the kit still enforces AC coverage end-to-end |
| `/develop-backend @[plan].md` | Implement following the backend plan |
| `/develop-frontend @[plan].md` | Implement following the frontend plan |
| `/write-pr-report @[IMPL].md` | Generate PR description |

## Acceptance Criteria Contract

- Every story must have acceptance criteria with stable IDs (`AC-01`, `AC-02`, ...)
- The plan must map each AC to explicit implementation and validation
- A task cannot be marked done without evidence per AC
- The PR report must include status and evidence for every acceptance criterion

## Based on

- [LIDR ai-specs](https://github.com/LIDR-academy/ai-specs)
- [LIDR manual-SDD](https://github.com/LIDR-academy/manual-SDD)
- [claude-mem](https://github.com/thedotmack/claude-mem)
- [superpowers](https://github.com/obra/superpowers)
