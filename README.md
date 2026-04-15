# kathy-sdd-kit

Portable **Spec-Driven Development (SDD)** kit for personal projects.
Based on the [LIDR Academy](https://github.com/LIDR-academy/manual-SDD) framework.

## What is included?

- Development standards: base, backend, and frontend
- Specialized agents for Claude Code, Cursor, and Codex
- Reusable skills: `enrich-user-story`, `plan-backend-ticket`, `plan-frontend-ticket`, `resolve-ticket-workspace`, `validate-impl-spec`, `close-ticket-workflow`, `verify-ac-enforcement`, and `write-pr-report`
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
    close-ticket-workflow/   <- correct closure order before PR
    verify-ac-enforcement/   <- kit self-check for AC coverage regressions
    write-pr-report/         <- /write-pr-report
  changes/                   <- canonical examples/templates, not per-ticket workspace

.claude/                     <- Claude Code configuration
.cursor/                     <- Cursor configuration
.codex/                      <- Codex / Copilot configuration

docs/
  doc_architecture.md        <- project technical context

CLAUDE.md                    <- Claude Code entry point
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
      PR-{TICKET}.md
```

Recommended usage:

- `.sdd-kit/` remains the shared framework and source of truth
- `.ai-specs/` is local working state for the current repository
- `PR-{TICKET}.md` is generated locally from the current `.ai-specs` state and does not need to be committed

## How to use it in a new project

**Option A - git submodule (recommended for updates)**
```bash
cd your-project
git submodule add https://github.com/kathesama/kathy-sdd-kit .sdd-kit
cp -r .sdd-kit/ai-specs ./
cp -r .sdd-kit/.claude ./
cp .sdd-kit/CLAUDE.md ./
cp .sdd-kit/docs/doc_architecture.md ./docs/
# Edit docs/doc_architecture.md with the real project architecture
```

**Option B - direct copy**
```bash
git clone https://github.com/kathesama/kathy-sdd-kit
cp -r kathy-sdd-kit/ai-specs your-project/
cp -r kathy-sdd-kit/.claude your-project/
cp kathy-sdd-kit/CLAUDE.md your-project/
cp kathy-sdd-kit/docs/doc_architecture.md your-project/docs/
# Edit docs/doc_architecture.md with the real project architecture
```

## Full SDD flow

```text
1. /enrich-us [description]           -> enrich the user story and close decisions
2. Create TC in Confluence            -> Technical Contract approved
3. /plan-backend-ticket [ID]          -> generate Implementation Spec in .ai-specs/changes/{TICKET}/ using .sdd-kit templates
4. /develop-backend @[plan].md        -> implement following the spec
5. /resolve-ticket-workspace [ID]     -> resolve current ticket paths from input or branch
6. /validate-impl-spec [ID or path]   -> validate AC mapping before execution/QA/PR
7. /write-pr-report @[IMPL].md        -> generate PR-{TICKET}.md from local .ai-specs state
8. /close-ticket-workflow [ID]        -> perform final closure sequence before PR
9. PR -> Review -> Merge              -> feature published
```

## Available commands

| Command | Description |
|---|---|
| `/enrich-us [desc]` | Enrich a user story |
| `/plan-backend-ticket [ID]` | Generate a backend implementation plan |
| `/plan-frontend-ticket [ID]` | Generate a frontend implementation plan |
| `/resolve-ticket-workspace [ID]` | Resolve local `.ai-specs` paths from input or branch |
| `/validate-impl-spec [ID or path]` | Validate structural AC coverage of an implementation spec |
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
