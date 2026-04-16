# Agent Entrypoint

This repository uses `kathy-sdd-kit` as a portable SDD framework.

When this file is copied to the root of a consuming project, the consuming
project must keep the kit mounted at:

```text
.sdd-kit/
```

The kit is the framework source. Project-specific ticket artifacts must live in
the consuming repository under:

```text
.ai-specs/changes/
```

Do not write ticket artifacts under `.sdd-kit/ai-specs/changes/`.

## Tool-Specific Bootstrap

- If you are Codex, load and follow `.sdd-kit/CODEX.md`.
- If you are Claude Code and this file is loaded, also load and follow `.sdd-kit/CLAUDE.md`.
- If the tool cannot auto-load referenced files, read the relevant file directly before starting SDD work.

## SDD Framework References

Before planning, implementing, reviewing, or closing SDD work, use the kit files
from the submodule:

- `.sdd-kit/ai-specs/specs/base-standards.mdc`
- `.sdd-kit/ai-specs/specs/backend-standards.mdc` for backend work
- `.sdd-kit/ai-specs/specs/frontend-standards.mdc` for frontend work
- `.sdd-kit/ai-specs/specs/implementation-spec-template.md` for implementation specs
- `.sdd-kit/ai-specs/skills/` for reusable SDD workflows
- `.sdd-kit/ai-specs/.agents/` for role-specific agent guidance

Use project-local context from the consuming repository first when it exists:

- `CLAUDE.md` for Claude Code project context
- `docs/doc_architecture.md`
- `docs/adr/`
- `docs/GLOSSARY.md`
- local package, build, test, and script configuration

# Common Agent Rules

## SDD Ticket Identity

- `TICKET` is the canonical ticket/work-item key for the consuming project.
- It must be stable, unique within the project, and filesystem-safe.
- Examples: `JAP-160`, `ENG-123`, `GH-42`, `160`, `task-160`.
- If the user gives an ambiguous shorthand such as "160", resolve it using the consuming project's ticket policy before creating artifacts.
- Never use the branch name, branch slug, summary, or description as `TICKET`.
- Never append branch descriptions to `.ai-specs/changes/{TICKET}/` paths.
- The current branch may be recorded as secondary metadata only.
- Consuming projects may override this section with a stricter policy, such as requiring Jira keys like `JAP-160`.

## SDD Tool Runtime

- Kit tools are POSIX `sh` scripts under `.sdd-kit/tools/`.
- Invoke them explicitly with `sh`, not by executing the file directly.
- On Windows, run them from Git Bash, or call Git for Windows `sh.exe` if `sh` is not on `PATH`.

## Mandatory SDD Planning Gate

Before creating or modifying production code, tests, migrations, generated
runtime artifacts, or service configuration for a ticket, agents MUST complete
the planning gate.

1. Resolve `TICKET`.
2. Resolve the workspace with the kit tool:

   ```powershell
   sh .sdd-kit/tools/resolve-ticket-workspace.sh {TICKET}
   ```

   If the kit is being edited directly, use:

   ```powershell
   sh tools/resolve-ticket-workspace.sh {TICKET}
   ```

3. Create `.ai-specs/changes/{TICKET}/` if missing.
4. Generate the implementation plan for the requested surface:
   - Backend: `.ai-specs/changes/{TICKET}/{TICKET}-impl-backend.md`
   - Frontend: `.ai-specs/changes/{TICKET}/{TICKET}-impl-frontend.md`
5. Generate `.ai-specs/changes/{TICKET}/{TICKET}-implementation-spec.md`.
6. Create `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md` if missing.
7. Validate that every explicit acceptance criterion appears in both specs:

   ```powershell
   sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
   ```

8. Present the plan summary and STOP for approval.

Generating a plan is not approval to execute the plan. Implementation is
forbidden until the user explicitly answers `approve`.

Allowed planning gate responses:

- `approve` — execute the plan exactly as written.
- `change` — revise the plan/spec first, then present the approval gate again.
- `deny` — stop ticket execution and do not modify code.

If the response is `change` or anything other than an explicit `approve`, do not
start implementation.

## Repository Discovery

- Before editing, inspect the repository structure and existing conventions.
- Prefer local docs, existing scripts, package config, and nearby code over assumptions.
- If the repository has framework-specific instructions, follow them before generic rules.
- If project-specific ADRs exist, check relevant ADRs before changing architecture, contracts, or cross-service behavior.

## Optional Naming Glossary

- If the repository has `docs/GLOSSARY.md`, read it before naming any class, field, or concept that crosses a service boundary.
- Canonical names defined there are mandatory when the glossary exists.
- Prohibited variants listed there must not appear in new code when the glossary exists.
- If a cross-boundary concept is missing from an existing glossary, add it before implementation.
- If the repository does not have `docs/GLOSSARY.md`, continue without blocking on glossary checks.

## Execution

- Keep changes limited to the requested task.
- Do not touch unrelated services, modules, or packages unless the task requires it.
- Do not refactor unrelated files.
- Do not update generated files unless the task or tooling requires it.
- Preserve repository style, naming, formatting, logging, and error-handling conventions.
- Do not ask for unnecessary confirmations.
- Execute validation commands directly when needed.
- Only interrupt on real blocking errors.
- Do not create commits or pull requests unless explicitly requested.
- Do not run git commands except `git diff` or `git status` unless explicitly requested or required for recovery.

## Validation

- Run the smallest relevant validation command for the change.
- Prefer repository-provided scripts over ad hoc commands.
- If validation cannot be run, document why and what should be run manually.
- Do not claim work is complete without either running validation or stating the validation gap.

## Secrets and Safety

- Never print, commit, or persist secrets, tokens, passphrases, API keys, or credentials.
- Do not add real credentials to examples, tests, fixtures, or documentation.
- Use placeholders for secrets.
- Before destructive operations, confirm the intended target path, branch, or resource.

## Optional Project Files

- If `.github/pull_request_template.md` exists, preserve its structure when generating PR descriptions.
- If `docs/GLOSSARY.md` exists, use it for cross-boundary naming.
- If ADRs exist, use them when changing architecture, contracts, persistence, messaging, or deployment behavior.
- If a test, lint, validation, or preflight script exists, prefer it over raw tool commands.

## Branch Task Log

- At the end of each subtask, update `.ai-specs/changes/{TICKET}/{TICKET}-CHANGELOG.md`.
- If the file does not exist, create it with the branch header.
- `TICKET` comes from the resolved canonical ticket/work-item key.
- Do not derive changelog paths from the branch name.
- Never overwrite previous sections; append only.
- Use the changelog as the primary implementation evidence for PR reports when present.
- Keep changelog entries factual: files changed, validation results, risks, follow-ups, and concise implementation notes.

Required structure:

```md
# {TICKET} {branch description}

## {SUBTASK_KEY}: {subtask title}
**Status:** Done
**Commit message:** {TICKET} tipo(scope): descripcion corta
### Files created
### Files modified
### Summary
### Notes
---
```
